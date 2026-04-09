import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] so short-lived routes can show snackbars that survive [Navigator.pop].
class AppScaffoldMessenger {
  AppScaffoldMessenger._();

  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static ScaffoldMessengerState? get state => key.currentState;
}
