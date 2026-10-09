import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/app_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Profile Card',
      theme: AppTheme.lightTheme,
      home: const ProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GANTI angka 7 ini dengan digit terakhir NIM kamu (0-9)
    const int d = 7;

    // Perhitungan ukuran otomatis berdasarkan rumus NIM
    final double cardPadding = 16.0 + d;
    final double cardRadius = 8.0 + d;
    final double buttonHeight = 40.0 + d;
    final double buttonRadius = 4.0 + d;
    final double avatarSize = 40.0 + (2 * d);
    final double spacingNameNim = 8.0 + d;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(cardPadding),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: avatarSize / 2,
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(height: 12),
                  const Text('Reifan Ardissa Rachmanto'),
                  SizedBox(height: spacingNameNim),
                  const Text('20240801002'),
                  const SizedBox(height: 8),
                  const Text('Teknik Informatika'),
                  const SizedBox(height: 12),
                  const Text('Fans No.1 Tim Scuderia Ferrari'),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Kunjungi GitHub Saya',
                    icon: Icons.code,
                    url: 'https://github.com/reifengards',
                    height: buttonHeight,
                    borderRadius: buttonRadius,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}