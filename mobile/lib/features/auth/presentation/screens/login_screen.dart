import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  bool _registerMode = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 36),
            const Text(
              'Вход в Black Red Messenger',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Используйте email или телефон для входа. Тёмный киберпанк режим включён по умолчанию.'),
            const SizedBox(height: 24),
            TextField(
              controller: _identifier,
              decoration: const InputDecoration(labelText: 'Email или телефон'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            if (_registerMode) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: 'Отображаемое имя'),
              ),
            ],
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: state.authLoading
                  ? null
                  : () async {
                      try {
                        await state.loginOrRegister(
                          identifier: _identifier.text.trim(),
                          password: _password.text,
                          displayName: _registerMode ? _displayName.text.trim() : null,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                      }
                    },
              child: Text(_registerMode ? 'Зарегистрироваться' : 'Войти'),
            ),
            TextButton(
              onPressed: state.authLoading
                  ? null
                  : () {
                      setState(() {
                        _registerMode = !_registerMode;
                      });
                    },
              child: Text(_registerMode ? 'Уже есть аккаунт? Войти' : 'Нет аккаунта? Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}
