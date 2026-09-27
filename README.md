# Expense Tracker

A lightweight, feature-first, MVVM-architected personal expense tracking application built with Flutter and Firebase.

## Implemented Features
- **Anonymous Authentication:** Users are silently authenticated to keep their expenses private without requiring a login screen.
- **Google Account Linking:** Securely link a Google account to permanently backup your data and seamlessly sync preferences (Dark Mode, Currency, Budget) across all your devices.
- **Add/Edit/Delete Expenses:** Full CRUD capabilities for expense records with swipe-to-delete functionality.
- **Categorization & Filtering:** Assign categories and filter your expense list by category, specific dates, or search text.
- **Monthly Totals & Budget:** Dynamically calculates total expenditure for the selected month against a customizable Budget Limit progress bar.
- **Category Summary Chart:** Visualizes category-wise spending using an animated pie chart (`fl_chart`).
- **Dynamic Currency & Precision:** Choose your preferred currency symbol from Settings. All financial data is stored and calculated as integers (cents) to guarantee zero floating-point errors.
- **Theme Syncing:** Toggle Dark Mode in Settings. If signed in with Google, your theme preference is automatically synced across devices.

## Architecture Data Flow
This app follows a strict, lightweight feature-first MVVM (Model-View-ViewModel) architecture.

`View` → `ViewModel` → `ExpenseRepository` → `Firestore`

1. **View (`Widgets`)**: Exclusively responsible for rendering the UI and forwarding user intents. No direct Firebase imports exist in the Views.
2. **ViewModel (`ChangeNotifier`)**: Owns presentation state, manages monthly totals, handles filters, and exposes user-facing failures. It listens to the Repository and notifies the View on changes.
3. **Repository (`ExpenseRepository`)**: Owns all actual data access (Firestore reads, writes, snapshots). 
4. **Model (`Expense`)**: Pure data structures with factory constructors for serialization/deserialization. Completely independent of widgets and Firebase internals.

## Technologies & Packages
- **Flutter:** `sdk: flutter`
- **Firebase Core:** `firebase_core: ^3.13.0`
- **Firebase Auth:** `firebase_auth: ^5.7.0`
- **Cloud Firestore:** `cloud_firestore: ^5.6.12`
- **State Management / DI:** `provider: ^6.1.5+1`
- **Charts:** `fl_chart: ^1.2.0`
- **Google Sign-In:** `google_sign_in: ^7.2.0`

## Setup & Running the App

### Prerequisites
- Flutter SDK `^3.13.4` installed.
- Android Studio or appropriate emulators installed.

### Firebase Configuration
1. Install the [Firebase CLI](https://firebase.google.com/docs/cli) and login (`firebase login`).
2. Run `dart pub global activate flutterfire_cli`.
3. In the project root, run `flutterfire configure` and select your Firebase project. This will generate `lib/firebase_options.dart`.
4. In the Firebase Console for your project:
   - Go to **Authentication** -> **Sign-in method** and enable **Anonymous** AND **Google Sign-In**.
   - Go to **Firestore Database** and create a database.

### Security Rules
Deploy the included strict security rules by running:
```bash
firebase deploy --only firestore:rules
```
These rules ensure users can only read, create, update, and delete their own documents.

### Run
```bash
flutter run
```

## Testing & Building

**Run Unit & Widget Tests:**
```bash
flutter test
```
The test suite includes complete ViewModel behavior coverage (monthly aggregations, state transitions, validation) without initializing Firebase, utilizing a custom `FakeExpenseRepository`.

**Build Android APK:**
```bash
flutter build apk
```
The resulting APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## AI Disclosure
- **Planning & Prompt Design:** Assisted by Perplexity.
- **Implementation & Development:** Guided and assisted by Google Antigravity.
- *All architecture, widget structure, and logic has been thoroughly reviewed and manually verified against requirements.*
