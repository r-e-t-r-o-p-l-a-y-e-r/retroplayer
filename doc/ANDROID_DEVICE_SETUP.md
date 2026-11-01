# Android-Testgerät einrichten

So aktivierst du die Entwickleroptionen und installierst Retro Player auf einem physischen Android-Gerät.

## 1. Entwickleroptionen freischalten

1. Öffne **Einstellungen → Über das Telefon** (auch: *Über das Gerät* / *Mein Gerät*).
2. Suche **Build-Nummer** (oft unter **Softwareinformationen**).
3. Tippe die **Build-Nummer etwa siebenmal**, bis eine Meldung kommt, dass du jetzt Entwickler bist.
4. Zurück zu den Einstellungen — dort erscheint **Entwickleroptionen** (häufig unter **System** oder oben in der Liste).
5. Aktiviere **USB-Debugging**.

### Hersteller-Hinweise

| Gerät | Wo die Build-Nummer oft liegt |
|-------|-------------------------------|
| Samsung | Einstellungen → Über das Telefon → Softwareinformationen → Build-Nummer |
| Google Pixel / Stock Android | Einstellungen → Über das Telefon → Build-Nummer |
| Xiaomi / HyperOS | Zusätzlich ggf. „USB-Debugging (Sicherheitseinstellungen)“ |

## 2. USB verbinden und prüfen

1. Telefon per USB an den Rechner anschließen.
2. Am Telefon den Dialog **USB-Debugging zulassen?** mit **Zulassen** bestätigen (optional Häkchen „Immer von diesem Computer“).
3. Am Rechner prüfen:

```bash
adb devices
flutter devices
```

Das Gerät muss mit einer ID erscheinen und **nicht** als `unauthorized`.  
Wenn `unauthorized` steht: Kabel neu stecken, Dialog am Telefon erneut bestätigen, ggf. „USB-Debugging-Berechtigungen widerrufen“ in den Entwickleroptionen und neu verbinden.

## 3. App installieren / starten

Im Projektroot:

```bash
cd /data/develop/apps/retroplayer   # bzw. dein Checkout-Pfad
flutter pub get
dart run scripts/stamp_build_info.dart   # erzeugt gitignored lib/build_info.dart
```

### Debug (Hot Reload, DevTools)

```bash
flutter run -d <device-id>
```

Oder ohne ID, wenn nur ein Android-Gerät verbunden ist:

```bash
flutter run
```

**Hinweis:** Debug-/Profile-Builds deklarieren `INTERNET` für Flutter Hot Reload / VM Service. Das ist Tooling, keine App-Telemetrie. Siehe [README Privacy](../README.md#privacy).

### Release (näher am Nutzer-Build, ohne `INTERNET`)

Empfohlen — baut Release-APK, wählt das Gerät (oder fragt nach) und installiert:

```bash
./scripts/install-android-release.sh
./scripts/install-android-release.sh -d <serial>    # festes Gerät
./scripts/install-android-release.sh --no-launch  # nur installieren
```

Manuell:

```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Für Privacy-Checks (kein Netzwerk) die **Release**-APK verwenden.

## 4. Häufige Probleme

| Symptom | Was tun |
|---------|---------|
| `adb devices` leer | Anderes Kabel/USB-Port; am Telefon USB-Modus „Dateiübertragung“; `adb kill-server && adb start-server` |
| `unauthorized` | Dialog am Telefon bestätigen; RSA-Keys zurücksetzen in Entwickleroptionen |
| Gerät fehlt in `flutter devices` | `flutter doctor`; Android SDK / Platform-Tools prüfen |
| Installation schlägt fehl | Alte App deinstallieren; Signing/Debug vs Release beachten |
| Release-Build: `integration_test` / `IntegrationTestPlugin` in `GeneratedPluginRegistrant` | Nach Tests/`flutter pub get` zuerst `flutter build apk --config-only`, dann Release bauen — oder `./scripts/build-android.sh` / `./scripts/install-android-release.sh` (macht das automatisch) |
| Mini-Player expandiert bei Wisch von unten (System-Navigation) | Nur am **Griff** nach oben ziehen; der untere System-Gesten-Streifen verhält sich wie der linke Rand bei Favoriten (kein extra Abstand am Bildschirmrand) |
| `JAVA_HOME is set to an invalid directory` | Android-Builds brauchen ein vollständiges JDK (typisch **17**). Prüfen: `ls "$JAVA_HOME/bin/java"`. Auf Fedora oft Temurin: `export JAVA_HOME=/usr/lib/jvm/java-17-temurin-jdk` (in `~/.bashrc` setzen, neues Terminal öffnen). |

### JAVA_HOME für den aktuellen Shell-Prozess

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-temurin-jdk
export PATH="$JAVA_HOME/bin:$PATH"
flutter build apk --release
```

## Wiedergabe: Hintergrund vs. App schließen

- **Sperrbildschirm / andere App:** Musik läuft weiter (Foreground-Media-Service + Notification).
- **App wirklich schließen** (App aus den letzten Apps / Recents wegwischen): Wiedergabe stoppt, Notification verschwindet.
- **Ordner-Navigation:** System-Zurück / Wisch von links geht in den übergeordneten Bibliotheksordner; auf der Bibliotheks-Root-Ansicht bleibt die App offen (kein Beenden über Zurück).
- **Playlist „Titel hinzufügen“:** In-App-Auswahl nur aus Bibliotheksordnern (Mehrfachauswahl).
- **Ordner hinzufügen:** System-Ordnerdialog startet auf Android am gemeinsamen Speicher-Root, nicht im zuletzt genutzten Playlist-Picker-Pfad.

## Siehe auch

- Root [README.md](../README.md) — Build-Befehle und Privacy
- [AUTOMATED_TESTING.md](AUTOMATED_TESTING.md) — automatisierte Tests
