# Manual steps for the first store release

Steps that need the maintainer's accounts or signing key, in order. The
release process itself is in [RELEASE.md](RELEASE.md). The app is published
on F-Droid and as GitHub Releases; it is not published on Google Play.

## 1. Signing key

- [x] Create the keystore (RSA 4096, PKCS12):
  ```bash
  keytool -genkeypair -v -storetype PKCS12 -keystore retroplayer-release.jks \
    -alias retroplayer -keyalg RSA -keysize 4096 -validity 36500 \
    -dname "CN=Retro Player"
  ```

- [x] Keep two offline backups of the keystore and the passwords in a password
  manager. Losing the key means no more updates on F-Droid.
- [x] Note the certificate SHA-256 for F-Droid (lowercase hex, no colons):
  ```bash
  keytool -list -v -keystore retroplayer-release.jks -alias retroplayer | grep SHA256
  ```

## 2. GitHub secrets

The release workflow (`.github/workflows/release.yml`) signs the builds on
GitHub's servers, so it needs the keystore and its passwords. GitHub stores
secrets encrypted, never shows them again after saving, hides them in logs,
and does not give them to workflows started from pull requests by forks.

| Secret | Value |
|--------|-------|
| `RELEASE_KEYSTORE_BASE64` | The keystore file as one line of text (base64), because secrets can only hold text |
| `RELEASE_KEYSTORE_PASSWORD` | The password you typed for the keystore in step 1 |
| `RELEASE_KEY_ALIAS` | `retroplayer` (the `-alias` from step 1) |
| `RELEASE_KEY_PASSWORD` | The same password as `RELEASE_KEYSTORE_PASSWORD`: a PKCS12 keystore made with keytool uses one password for the store and the key |

In the browser (needs admin rights on the repository):

1. Open the repository on GitHub → **Settings** → **Secrets and variables** →

   **Actions** → **New repository secret**.
2. Name `RELEASE_KEYSTORE_BASE64`; value: the output of
   ```bash
     base64 -w0 retroplayer-release.jks     # Linux; on macOS: base64 -i retroplayer-release.jks
   ```

     Copy the whole line (several thousand characters, no line breaks).
3. Add the other three secrets the same way.

Or with the GitHub CLI (`gh auth login` first); `gh` asks for the values, so
the passwords do not end up in the shell history:

```bash
base64 -w0 retroplayer-release.jks | gh secret set RELEASE_KEYSTORE_BASE64
gh secret set RELEASE_KEYSTORE_PASSWORD
gh secret set RELEASE_KEY_ALIAS          # type: retroplayer
gh secret set RELEASE_KEY_PASSWORD
gh secret list                           # shows the four names, not the values
```

- [x] `RELEASE_KEYSTORE_BASE64`
- [x] `RELEASE_KEYSTORE_PASSWORD`
- [x] `RELEASE_KEY_ALIAS`
- [x] `RELEASE_KEY_PASSWORD`
- [x] Optional: protect `v*` tags (Settings → Rules → Rulesets → New tag
  ruleset, target `v*`, restrict creations) so only you can start a signed
  release. Anyone with write access can push a tag otherwise.

If a value is wrong, the workflow fails at "Signed APK" (wrong
password or alias) or prints an empty certificate; set the secret again with
the same name to overwrite it. Wrong secrets never produce a build signed with
another key.

## 3. Remove the old 1.0.0

- [x] Delete the remote tag: `git push origin :refs/tags/v1.0.0`, and delete
  any GitHub Release on that tag.
- [x] On phones with the old build: `adb uninstall app.retroplayer`. It has
  versionCode 2, so Android refuses to install 0.1.0 (versionCode 1) over it.

## 4. Publish the rewritten history, merge, tag 0.1.0

The local history was rewritten so every commit shows
`freier-fall <273219319+freier-fall@users.noreply.github.com>` instead of a
real name and private addresses. GitHub still has the old commits until the
branches are force-pushed. Push **before** merging: merging first would put
the old commits onto `main`, and the rewrite would have to be redone.

- [x] Replace all branches on GitHub (the open pull request updates itself):
  ```bash
  git push --force --all origin
  ```

- [x] Check that only the new identity is left (plus `GitHub` for web merges
  and `dependabot[bot]`):
  ```bash
  git fetch origin --prune
  git log --all --format='%an <%ae>%n%cn <%ce>' | sort | uniq -c
  ```

- [x] Merge the pull request from `feat/native-android` into `main`.
- [x] Delete the local backup with the old history:
  `rm -rf /data/develop/apps/retroplayer-backup-2026-11-04.git`
- [x] Optional: the pull request's timeline keeps links to the commits from
  before the force-push. To remove them, ask GitHub Support
  ([support.github.com](https://support.github.com)) to "remove cached views
  and unreachable commits" for the repository.
- [x] Dry run of the release (tests the secrets and signing without
  publishing anything): GitHub → **Actions** → **Release** → **Run workflow**
  on `main`, or `gh workflow run release.yml --ref main`. The run must be
  green; its artifact `release-dry-run` holds the signed APK and
  `SHA256SUMS`, and the "Signature and checksums" log shows your
  certificate's SHA-256 (it must match step 1).
- [x] `git tag v0.1.0 && git push origin v0.1.0`
- [x] Check that the Release workflow publishes `retroplayer-0.1.0.apk` and
  `SHA256SUMS`.

## 5. F-Droid

F-Droid builds the app itself from the public source at the tag, compares its
build with `retroplayer-X.Y.Z.apk` from the GitHub Release and, if they match
(see "Reproducible builds" in [RELEASE.md](RELEASE.md)), ships **your** signed
APK. Listing text, images and changelogs come straight from
`fastlane/metadata/android/` in the repository; nothing is entered on a
website. Inclusion goes through a merge request to the
[fdroiddata](https://gitlab.com/fdroid/fdroiddata) repository on GitLab.

Before you start:

- [ ] The GitHub repository is public, `v0.1.0` is tagged and its GitHub
  Release has `retroplayer-0.1.0.apk` (step 4). F-Droid only builds from
  source it can clone without an account.
- [ ] The release APK is reproducible: an unsigned build of the tag from a
  fresh clone, like F-Droid makes, must match it apart from the signature.
  Works with a private repository too (clones the local one). Download
  `retroplayer-0.1.0.apk` from the GitHub Release first, then:
  ```bash
  pip install --user apksigcopier
  git clone --branch v0.1.0 /data/develop/apps/retroplayer /tmp/rp-check
  cd /tmp/rp-check && ./gradlew --no-build-cache :app:assembleRelease
  apksigcopier compare ~/Downloads/retroplayer-0.1.0.apk \
    --unsigned app/build/outputs/apk/release/app-release-unsigned.apk && echo reproducible
  ```
  The clone has no `keystore.properties`, so its build is unsigned, as on
  F-Droid. On a mismatch, `diffoscope` on the two APKs shows the difference
  (see "Reproducible builds" in [RELEASE.md](RELEASE.md)); do not open the
  merge request until it matches.
- [ ] A [GitLab](https://gitlab.com/users/sign_up) account. The username is
  public; the email is not. In GitLab → Preferences → Emails, set the commit
  email to the private `…@users.noreply.gitlab.com` address and use it in the
  fdroiddata clone (`git config user.email`), so your private address does
  not appear in fdroiddata's public history.

Prepare the merge request:

- [ ] On GitLab, open [fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata)
  → **Fork**. Clone your fork (it is large; `--depth 1` is enough) and create
  a branch:
  ```bash
  git clone --depth 1 https://gitlab.com/<gitlab-user>/fdroiddata.git
  cd fdroiddata
  git config user.name freier-fall
  git config user.email <id>-<gitlab-user>@users.noreply.gitlab.com
  git checkout -b app.retroplayer
  ```

- [ ] Create `metadata/app.retroplayer.yml`:
  ```yaml
  Categories:
    - Multimedia
  License: GPL-3.0-or-later
  SourceCode: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer
  IssueTracker: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer/issues
  Liberapay: retroplayer

  RepoType: git
  Repo: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer.git
  Binaries: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer/releases/download/v%v/retroplayer-%v.apk

  Builds:
    - versionName: 0.1.0
      versionCode: 1
      commit: v0.1.0
      subdir: app
      gradle:
        - yes

  AllowedAPKSigningKeys: <certificate SHA-256 from step 1>

  AutoUpdateMode: Version
  UpdateCheckMode: Tags
  CurrentVersion: 0.1.0
  CurrentVersionCode: 1
  ```
  What the fields do:
  | Field | Meaning |
  |-------|---------|
  | `Categories`, `License`, `SourceCode`, `IssueTracker` | Shown in the F-Droid client; the license must match `LICENSE` |
  | `Liberapay` | Adds a donate button pointing at liberapay.com/retroplayer |
  | `Repo`, `RepoType` | Where F-Droid clones the source |
  | `Binaries` | Your signed APK; `%v` becomes the versionName. F-Droid only publishes it if its own build matches |
  | `Builds` | One entry per release: the tag to build, the module folder (`subdir: app`), `gradle: [yes]` = the default build (no flavors) |
  | `AllowedAPKSigningKeys` | SHA-256 of your certificate (step 1), lowercase, no colons; F-Droid refuses APKs signed with another key |
  | `AutoUpdateMode`, `UpdateCheckMode` | F-Droid's bot watches for new `v*` tags and adds the next `Builds` entry by itself |
  | `CurrentVersion`, `CurrentVersionCode` | The version F-Droid recommends; the bot updates them |
  No summary or description fields: F-Droid takes them from
  `fastlane/metadata/android/` in the app repository.

Test locally (optional but saves review rounds; needs the Android SDK, which
is already set up here, and Python):

- [ ] Install fdroidserver: `pip install --user fdroidserver`
- [ ] In the fdroiddata folder:
  ```bash
  fdroid readmeta                              # the YAML parses
  fdroid rewritemeta app.retroplayer           # formats the file the way reviewers expect
  fdroid lint app.retroplayer                  # field and style checks
  fdroid build --verbose --latest app.retroplayer   # clones the tag, builds it, compares with Binaries
  ```
  `fdroid build` takes several minutes. It ends with a line saying the
  unsigned build matches the APK from `Binaries`. If it reports a mismatch,
  the build is not reproducible; compare the two APKs with `diffoscope` (see
  [RELEASE.md](RELEASE.md)).

Open the merge request:

- [ ] `git add metadata/app.retroplayer.yml && git commit -m "New app: Retro Player"`,
  then `git push -u origin app.retroplayer`.
- [ ] GitLab prints a link to open a merge request; target
  `fdroid/fdroiddata` branch `master`. Pick the template **"App inclusion"**
  and tick its checklist: the app is free software, has no tracking or ads,
  and you are the developer.
- [ ] GitLab CI runs lint and a test build on the merge request. Fix what it
  reports by pushing to the same branch.
- [ ] A volunteer reviews it; that can take days to a few weeks. Answer
  questions in the merge request.
- [ ] After the merge, F-Droid's build server builds the app. It shows up in
  the F-Droid client usually one to three days later.

Later releases: tag `vX.Y.Z` with a higher `versionCode` and let the release
workflow publish the APK. F-Droid's bot notices the tag and builds it; nothing
to do on GitLab unless a build fails. Failed builds are listed on
[monitor.f-droid.org](https://monitor.f-droid.org/builds); check there if a
new version does not appear within a few days.

Optional, instead of all of the above: open a "Request for Packaging" issue at
[fdroid/rfp](https://gitlab.com/fdroid/rfp/-/issues) and wait for a volunteer
to write the metadata. Slower and less predictable than your own merge request.
