# Money Manager App — Setup Guide

## Prerequisites

- **Flutter SDK 3.41+** — installed and on `$PATH` (verify with `flutter doctor`)
- **Android SDK** — needed for APK builds (already installed, `flutter doctor` shows ✓)
- **Linux desktop** — no extra dependencies needed (toolchain already installed)
- **Git** — for cloning/pulling updates

---

## Build & Install on Linux Desktop

### Step 1: Build the binary
```bash
cd /home/mibrahimpro/Documents/financev2/money_manager_app
flutter build linux --release
```

### Step 2: Run it
```bash
./build/linux/x64/release/bundle/money_manager_app
```

Or install system-wide:
```bash
sudo cp -r build/linux/x64/release/bundle /opt/money-manager
sudo ln -s /opt/money-manager/money_manager_app /usr/local/bin/money-manager
# Then just run: money-manager
```

### Step 3: Desktop shortcut (optional)
Create `~/.local/share/applications/money-manager.desktop`:
```ini
[Desktop Entry]
Name=Money Manager
Comment=Personal finance tracker
Exec=/opt/money-manager/money_manager_app
Path=/opt/money-manager
Terminal=false
Type=Application
Categories=Office;Finance;
```

---

## Build & Install on Android (APK)

### Step 1: Build the APK
```bash
cd /home/mibrahimpro/Documents/financev2/money_manager_app
flutter build apk --release
```

### Step 2: Locate the APK
```
money_manager_app/build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Transfer to your phone
- **USB**: `adb install build/app/outputs/flutter-apk/app-release.apk`
- **Cloud**: Upload to Google Drive / Dropbox, download on phone
- **Bluetooth**: Send over BT to phone

### Step 4: Install on phone
1. Open **Settings → Security** on your Android phone
2. Enable **Install from unknown sources** (or "Install unknown apps")
3. Open the APK file → tap **Install**
4. After install, open **Money Manager**

> **Note**: The APK is signed with a debug key, which is fine for personal use.
> You'll see a warning "Unknown app developer" — tap **Install anyway**.

---

## Sync Setup (Optional)

Sync backs up your data to the cloud and keeps Android + Linux in sync.

1. Open the app → **Settings** tab
2. Tap **Set Up Sync**
3. Enter a **4-digit PIN** (you'll need this later)
4. Confirm the PIN
5. Toggle **Auto Sync** ON
6. All current data is uploaded immediately

### What sync does:
- Every change you make while online + auto-sync = ON is sent to the server
- When you switch devices and turn on sync, it pulls the latest data down
- Latest-timestamp-wins: if you edited something on Android AND Linux, the last edit wins

### PIN rules:
- 4 digits only (e.g., `1234`)
- PIN is stored locally on your device — no PIN is uploaded
- Token is valid for **1 year**, then you'll need to re-enter your PIN
- If you forget your PIN: uninstall and reinstall (local data will be lost)

---

## Verifying the Backend

The sync API runs at `https://fanacial-v2.vercel.app`. Test it:
```bash
curl https://fanacial-v2.vercel.app/api/tags
# Expected: {"success":true,"data":[]}
curl -X POST https://fanacial-v2.vercel.app/api/tags \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer mm-sync-secret-k7F9xP2q" \
  -d '{"id":"test","name":"Test","color":"#FF5252"}'
# Expected: {"success":true,"data":{"id":"test",...}}
```

---

## Project Structure

```
financev2/
├── SETUP.md                     ← this file
├── CHECKLIST.md                 ← progress tracking
├── MoneyManagerApp_PLAN.md      ← full architecture plan
├── RequirmentsMaster.txt        ← original requirements
├── AGENTS.md                    ← agent instructions
└── money_manager_app/           ← Flutter project
    ├── lib/                     ← Flutter/Dart source
    │   ├── main.dart            ← app entry point
    │   ├── models/              ← 7 data models
    │   ├── services/            ← storage, api, sync, connectivity, pin
    │   ├── providers/           ← 6 state providers
    │   ├── screens/             ← 5 screens + all widgets
    │   └── utils/               ← theme, helpers
    ├── backend/                 ← Vercel serverless backend
    │   ├── api/                 ← 12 serverless endpoints
    │   ├── setup.sql            ← database schema
    │   └── vercel.json          ← Vercel config
    └── test/                    ← 49 unit tests
```

---

## Updating the App

```bash
cd /home/mibrahimpro/Documents/financev2
git pull
cd money_manager_app
flutter pub get
flutter build linux --release   # or flutter build apk --release
```
