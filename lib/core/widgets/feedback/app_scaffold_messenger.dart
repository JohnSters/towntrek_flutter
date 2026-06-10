import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] so short-lived routes can show snackbars that survive [Navigator.pop].
class AppScaffoldMessenger {
  AppScaffoldMessenger._();

  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static ScaffoldMessengerState? get state => key.currentState;

  /// Prefer this over [ScaffoldMessenger.maybeOf] under modals: the sheet subtree
  /// may not resolve the same messenger as [MaterialApp.scaffoldMessengerKey].
  static void showSnackBar(SnackBar snackBar) {
    state?.showSnackBar(snackBar);
  }
}
