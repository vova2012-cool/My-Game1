import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Push-уведомления'),
            subtitle: const Text('Firebase Cloud Messaging'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Безопасность сессии'),
            subtitle: const Text('Подтверждение входа и управление токенами'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Тема'),
            subtitle: const Text('Dark cyberpunk (по умолчанию)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выйти'),
            onTap: () async {
              await context.read<AppState>().logout();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
