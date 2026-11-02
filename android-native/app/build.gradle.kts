plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
}

android {
    namespace = "app.retroplayer"
    compileSdk = 37

    defaultConfig {
        applicationId = "app.retroplayer"
        minSdk = 26
        targetSdk = 36
        versionCode = 2
        versionName = "2.0.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
    }

    androidResources {
        generateLocaleConfig = false
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
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
    testImplementation(platform(libs.compose.bom))
    testImplementation(libs.compose.ui.test.junit4)

    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(platform(libs.compose.bom))
    androidTestImplementation(libs.compose.ui.test.junit4)
}
