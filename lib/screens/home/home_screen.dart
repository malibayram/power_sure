import 'package:flutter/material.dart';
import 'package:power_sure/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('PowerSure'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hoş geldiniz ${authProvider.user?.email}'),
            Text('Rol: ${authProvider.userRole ?? "Belirlenmedi"}'),
          ],
        ),
      ),
    );
  }
}
