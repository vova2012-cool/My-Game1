import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MessengerApp());
}

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        apiBase: const String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:8080'),
        socketBase: const String.fromEnvironment('SOCKET_BASE', defaultValue: 'http://10.0.2.2:8080'),
      )..bootstrap(),
      child: MaterialApp(
        title: 'Black Red Messenger',
        theme: AppTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.booting) {
      return const SplashScreen();
    }

    if (!state.isAuthorized) {
      return const LoginScreen();
    }

    return const ChatListScreen();
  }
}
