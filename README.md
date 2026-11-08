# Money Tracker

Flutter UI app: Splash, Login, Home (balance, income, expenses, categories, transactions).

## Features
- Add / edit / delete income and expenses
- Rejects an expense bigger than the available balance (with a warning)
- User name comes from the email used to log in
- Transactions are saved locally with `shared_preferences` (one list per email)

## Run
```bash
flutter create .      # generates android/ios/web folders (existing files are kept)
flutter pub get
flutter run
```

## Structure
```
lib/
  main.dart
  constants.dart              colors, categories, icons
  models/tx.dart              Tx model + JSON
  services/storage_service.dart   shared_preferences save/load
  utils/helpers.dart          money(), nameFromEmail(), input style
  screens/                    splash, login, home
  widgets/                    tx_sheet, summary_tile, empty_hint
```
