import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../shared/repositories/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._authRepository) {
    try {
      _authSubscription = _authRepository.authStateChanges.listen((user) {
        _loggedInEmail = user?.email;
        notifyListeners();
      });
    } catch (_) {
      // Firebase isn't initialized (e.g. running in a widget test) — treat
      // as logged out instead of crashing the home screen.
      _authSubscription = null;
    }
  }

  final AuthRepository _authRepository;
  StreamSubscription<void>? _authSubscription;

  int _counter = 0;
  String? _loggedInEmail;

  int get counter => _counter;
  String? get loggedInEmail => _loggedInEmail;
  bool get isLoggedIn => _loggedInEmail != null;

  void increment() {
    _counter++;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
