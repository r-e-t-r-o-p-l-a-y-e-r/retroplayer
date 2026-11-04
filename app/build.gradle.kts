import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
    alias(libs.plugins.roborazzi)
}

android {
    namespace = "app.retroplayer"
    compileSdk = 37

    defaultConfig {
        applicationId = "app.retroplayer"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "0.9.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        // Every device test starts from a fresh install state (no roots, no grants).
        testInstrumentationRunnerArguments["clearPackageData"] = "true"

        fun git(vararg args: String) = providers.exec {
            commandLine("git", *args)
            isIgnoreExitValue = true
        }.standardOutput.asText.get().trim().ifEmpty { "unknown" }
        // Only values fixed by the commit: F-Droid rebuilds a tag in a detached, possibly shallow
        // clone and must get the same APK (no branch, clock or describe output; fixed hash length).
        val gitCommit = git("rev-parse", "--short=12", "HEAD")
        val buildTime = git("log", "-1", "--format=%ct").toLongOrNull() ?: 0L
        buildConfigField("String", "GIT_COMMIT", "\"$gitCommit\"")
        buildConfigField("long", "BUILD_TIME", "${buildTime}L")
    }

    // keystore.properties (local) or RELEASE_* variables (CI). Without them release builds stay
    // unsigned, which is how F-Droid builds them before it checks and copies our signature.
    val releaseKey = rootProject.file("keystore.properties").takeIf { it.isFile }
        ?.let { file -> Properties().apply { file.inputStream().use(::load) } }
        ?.let { p -> listOf("storeFile", "storePassword", "keyAlias", "keyPassword").map { p.getProperty(it) } }
        ?: listOf("RELEASE_KEYSTORE", "RELEASE_KEYSTORE_PASSWORD", "RELEASE_KEY_ALIAS", "RELEASE_KEY_PASSWORD")
            .map { providers.environmentVariable(it).orNull }
    val releaseSigning = releaseKey.takeIf { values -> values.all { !it.isNullOrBlank() } }?.let { (store, storePass, alias, keyPass) ->
        signingConfigs.create("release") {
            storeFile = rootProject.file(store!!)
            storePassword = storePass
            keyAlias = alias
            keyPassword = keyPass
            enableV1Signing = false
            enableV2Signing = true
            enableV3Signing = true
        }
    }

    dependenciesInfo {
        // F-Droid rejects the encrypted dependency blob Google Play reads.
        includeInApk = false
        includeInBundle = false
    }

    buildTypes {
        // Test builds install next to the release app.
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            manifestPlaceholders["appLabel"] = "Retro Player test"
            isPseudoLocalesEnabled = true
        }
        release {
            manifestPlaceholders["appLabel"] = "@string/app_name"
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = releaseSigning
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    androidResources {
        generateLocaleConfig = false
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
        managedDevices {
            val matrix = listOf(
                Triple("pixel2Api27", "Pixel 2", 27),
                Triple("pixel4Api30", "Pixel 4", 30),
                Triple("pixel7Api33", "Pixel 7", 33),
                Triple("pixel9Api35", "Pixel 9", 35),
                Triple("pixelTabletApi35", "Pixel Tablet", 35),
                Triple("pixelFoldApi35", "Pixel Fold", 35),
            )
            matrix.forEach { (name, model, api) ->
                localDevices.create(name) {
                    device = model
                    apiLevel = api
                    // ATD images lack DocumentsUI, the folder picker the smoke tests drive.
                    systemImageSource = "aosp"
                    testedAbi = if (api < 30) "x86" else "x86_64"
                }
            }
            groups {
                create("phones") {
                    listOf("pixel2Api27", "pixel7Api33", "pixel9Api35").forEach { targetDevices.add(localDevices[it]) }
                }
                create("fullMatrix") {
                    matrix.forEach { targetDevices.add(localDevices[it.first]) }
                }
            }
        }
    }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

roborazzi {
    outputDir.set(file("src/test/screenshots"))
}

abstract class PrivacyCheckTask : DefaultTask() {
    @get:InputFile
    abstract val mergedManifest: RegularFileProperty

    @get:Input
    abstract val dependencyIds: ListProperty<String>

    @get:Input
    abstract val forbiddenPermissions: ListProperty<String>

    @get:Input
    abstract val forbiddenDependencyPrefixes: ListProperty<String>

    @TaskAction
    fun verify() {
        val manifest = mergedManifest.get().asFile.readText()
        val problems = mutableListOf<String>()
        forbiddenPermissions.get().filter { "\"$it\"" in manifest }
            .forEach { problems += "release manifest declares $it" }
        dependencyIds.get().forEach { id ->
            if (forbiddenDependencyPrefixes.get().any { id.startsWith(it) }) {
                problems += "release classpath contains $id"
            }
        }
        if (problems.isNotEmpty()) {
            throw GradleException("Privacy check failed:\n" + problems.joinToString("\n"))
        }
    }
}

androidComponents {
    onVariants(selector().withBuildType("release")) { variant ->
        val runtime = configurations.named("${variant.name}RuntimeClasspath")
        val task = tasks.register<PrivacyCheckTask>("verify${variant.name.replaceFirstChar(Char::uppercase)}Privacy") {
            group = "verification"
            description = "Fails when the release build could reach the network or ships tracking SDKs."
            mergedManifest.set(variant.artifacts.get(com.android.build.api.artifact.SingleArtifact.MERGED_MANIFEST))
            dependencyIds.set(
                runtime.flatMap { config ->
                    config.incoming.resolutionResult.rootComponent.map { root ->
                        val seen = mutableSetOf<String>()
                        fun walk(component: org.gradle.api.artifacts.result.ResolvedComponentResult) {
                            component.dependencies
                                .filterIsInstance<org.gradle.api.artifacts.result.ResolvedDependencyResult>()
                                .forEach { dep ->
                                    val id = dep.selected.moduleVersion?.let { "${it.group}:${it.name}" }
                                    if (id != null && seen.add(id)) walk(dep.selected)
                                }
                        }
                        walk(root)
                        seen.sorted()
                    }
                },
            )
            forbiddenPermissions.set(
                listOf(
                    "android.permission.INTERNET",
                    "android.permission.ACCESS_NETWORK_STATE",
                    "android.permission.ACCESS_WIFI_STATE",
                    "com.google.android.gms.permission.AD_ID",
                ),
            )
            forbiddenDependencyPrefixes.set(
                listOf(
                    "com.google.android.gms:",
                    "com.google.firebase:",
                    "com.google.android.play:",
                    "com.squareup.okhttp",
                    "io.ktor:",
                    "io.coil-kt.coil3:coil-network",
                    "androidx.media3:media3-datasource-okhttp",
                    "androidx.media3:media3-datasource-cronet",
                    "com.android.billingclient:",
                    "io.sentry:",
                    "com.crashlytics",
                ),
            )
        }
        tasks.named("check") { dependsOn(task) }
    }
}

dependencies {
    implementation(project(":playback"))

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.kotlinx.serialization.json)
    implementation(libs.kotlinx.coroutines.guava)

    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.compose.foundation)
    implementation(libs.compose.material3)
    implementation(libs.compose.material.icons)
    implementation(libs.compose.ui.tooling.preview)
    debugImplementation(libs.compose.ui.tooling)
    debugImplementation(libs.compose.ui.test.manifest)

    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)
    implementation(libs.hilt.navigation.compose)

    implementation(libs.coil.compose)
    implementation(libs.reorderable)
    implementation(libs.glance.appwidget)
    implementation(libs.glance.material3)

    testImplementation(testFixtures(project(":data")))
    testImplementation(libs.junit)
    testImplementation(libs.truth)
    testImplementation(libs.turbine)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
    testImplementation(libs.room.runtime)
    testImplementation(libs.media3.exoplayer)
    testImplementation(libs.media3.test.utils)
    testImplementation(libs.glance.appwidget.testing)
    testImplementation(libs.media3.test.utils.robolectric)
    testImplementation(platform(libs.compose.bom))
    testImplementation(libs.compose.ui.test.junit4)
    testImplementation(libs.roborazzi)
    testImplementation(libs.roborazzi.compose)
    testImplementation(libs.roborazzi.junit.rule)

    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(platform(libs.compose.bom))
    androidTestImplementation(libs.compose.ui.test.junit4)
    androidTestImplementation(libs.androidx.test.uiautomator)
    androidTestImplementation(libs.truth)
    androidTestUtil(libs.androidx.test.orchestrator)
    androidTestUtil(libs.androidx.test.services)
}
