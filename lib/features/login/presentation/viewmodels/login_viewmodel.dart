import 'package:flutter/foundation.dart';

import '../../../../shared/repositories/auth_repository.dart';

enum LoginStatus { initial, submitting, success, error }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> signIn({required String email, required String password}) async {
    _status = LoginStatus.submitting;
    notifyListeners();

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _status = LoginStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoginStatus.error;
    }
    notifyListeners();
  }

  Future<void> register({required String email, required String password}) async {
    _status = LoginStatus.submitting;
    notifyListeners();

    try {
      await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      _status = LoginStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoginStatus.error;
    }
    notifyListeners();
  }
}
