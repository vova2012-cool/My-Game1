import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/cyber_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    final me = context.read<AppState>().me;
    _name = TextEditingController(text: me?.displayName ?? '');
    _bio = TextEditingController(text: me?.bio ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().me;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: CyberAvatar(name: me?.displayName ?? 'U', url: me?.avatarUrl ?? '', radius: 42)),
          const SizedBox(height: 14),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Имя')),
          const SizedBox(height: 14),
          TextField(controller: _bio, decoration: const InputDecoration(labelText: 'Статус'), maxLines: 3),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().updateProfile(displayName: _name.text.trim(), bio: _bio.text.trim());
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
