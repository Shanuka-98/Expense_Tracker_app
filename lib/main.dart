import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'firebase_options.dart';

/// App entry point.
///
/// Initializes Firebase before rendering the widget tree.
/// The [DefaultFirebaseOptions] come from the FlutterFire-generated
/// `firebase_options.dart` file.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  runApp(ExpenseTrackerApp(prefs: prefs));
}
