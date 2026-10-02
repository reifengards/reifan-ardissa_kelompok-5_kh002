import 'package:flutter/material.dart';
import 'profile_card.dart';

void main() => runApp(const MyApp()); //[cite: 22]

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Menggunakan warna pastel kuning muda karena digit terakhir NIM Genap (4)[cite: 22]
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.amber[100], //[cite: 22]
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Memposisikan widget ProfileCard tepat di tengah layar[cite: 22]
      body: Center(
        // Skor aktivitas bernilai 74 (didapat dari 24 + 50) sesuai rumus penugasan[cite: 22]
        child: ProfileCard(
          nama: "Reifan Ardissa Rachmanto",
          nim: "20240801002",
          hobi: "Gaming & Motorsports",
          skorAktivitas: 74,
        ),
      ),
    );
  }
}