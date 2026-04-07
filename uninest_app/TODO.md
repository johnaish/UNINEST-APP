# Uninest App Firestore Setup & Fix Task

## Step 1: Enable Firestore Database (User Action Required)
- Visit: https://console.cloud.google.com/firestore/datastore/setup?project=uninest-app-1
- Select **Production mode** (or Test mode for dev)
- Choose region (recommend: `us-central` or `nam5 (us-central1)`)
- Click **Done** - this creates the `(default)` database

**Status: ⏳ Pending user confirmation**

## Step 2: Initialize Firestore Collections
```bash
cd uninest_app
dart run bin/init_firestore.dart
```
Expected output: Collections created (users, properties, bookings, messages, conversations)

**Status: ⏳ Waiting for Step 1**

## Step 3: Set Test Landlord Role (Optional)
```bash
dart run bin/set_landlord_role.dart
```
Creates landlord user with UID `0cOf5IsWDzgPhREDAKLFiPh0Io52`

**Status: ⏳**

## Step 4: Rebuild & Test App
```bash
flutter clean
flutter build apk --release
```
Install `build/app/outputs/flutter-apk/app-release.apk` and test.

**Status: ⏳**

## Step 5: Update Rules (if needed)
Deploy rules:
```bash
cd ..
firebase deploy --only firestore:rules
```

**Status: ⏳**

---

*Track progress by marking ✅ when complete.*

