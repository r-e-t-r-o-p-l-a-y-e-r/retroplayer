# Privacy policy

Retro Player is a local audio player for Android. This policy applies to every
build of the app (Google Play, F-Droid, Accrescent and GitHub releases).

## Data the app collects

None. Retro Player does not collect, store on a server, share or sell any
personal or usage data.

- The app has no network access: it does not declare the Android `INTERNET`
  permission, so it cannot send anything off your device.
- There are no ads, analytics, crash reporting or tracking libraries.
- There are no accounts or logins.

## Data on your device

To work, the app keeps the following on your device only, in its private
storage:

- the folders you added (as access grants from the system folder picker),
- the library index built from those folders (file names and audio tags),
- playback positions, the queue, favorites and your settings.

Uninstalling the app or clearing its data removes all of this. Removing a
folder from the library only removes the app's index and access grant for it.

## Your files

The app reads only the folders you pick with the Android system folder picker.
It never changes, moves, renames or deletes your audio files or folders. The
only files it writes are M3U playlists you create in the app, saved in a
library folder you chose.

## Permissions

- Foreground service for media playback and wake lock: to keep playing when the
  screen is off or another app is open.
- Notifications: for the playback controls notification.
- Run at startup (`RECEIVE_BOOT_COMPLETED`): added by Android's WorkManager,
  which the home-screen widget library uses; the app does no work of its own
  at boot.

## Donations

The project accepts donations through [Liberapay](https://liberapay.com/retroplayer).
Opening that link takes you to Liberapay's website in your browser; the app
itself sends nothing.

## Changes and contact

Changes to this policy are published in this file in the
[source repository](https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer).
Questions: open an issue there.
