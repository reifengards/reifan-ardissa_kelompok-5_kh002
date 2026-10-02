import 'package:flutter/material.dart';

// Buat StatelessWidget bernama ProfileCard[cite: 21]
class ProfileCard extends StatelessWidget {
  // Wajib menerima 4 parameter via constructor[cite: 21]
  final String nama;
  final String nim;
  final String hobi;
  final int skorAktivitas;

  const ProfileCard({
    super.key,
    required this.nama,
    required this.nim,
    required this.hobi,
    required this.skorAktivitas,
  });

  @override
  Widget build(BuildContext context) {
    // Root Kartu: Menggunakan Container[cite: 21]
    return Container(
      // Lebar Kartu: 330.0 (Rumus: 320.0 + (2 * 5) karena digit ke-2 belakang adalah 2)[cite: 22]
      width: 330.0,
      padding: const EdgeInsets.all(20.0), // Padding agar isi tidak menempel ke tepi
      // Menggunakan dekorasi BoxDecoration[cite: 21]
      decoration: BoxDecoration(
        color: Colors.white, // Latar Belakang: Colors.white[cite: 21]
        // Sudut Melengkung: 18.0 (Rumus: 12.0 + (4 * 1.5) karena digit terakhir adalah 4)[cite: 22]
        borderRadius: BorderRadius.circular(18.0),
        // Memiliki Bayangan (BoxShadow) warna hitam transparan dan blurRadius 10.0[cite: 21]
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Agar tinggi kartu menyesuaikan isi
        children: [
          // Bagian Header Kartu (Horizontal - Row)[cite: 21]
          Row(
            children: [
              // Sisi Kiri: Menampilkan Logo/Ikon dibungkus Container berbingkai Lingkaran[cite: 21]
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: Colors.grey[200], // Latar tipis agar bingkai terlihat
                ),
                padding: const EdgeInsets.all(8.0),
                child: const FlutterLogo(
                  // Ukuran Logo: 68.0 (Rumus: 60.0 + (4 * 2) karena digit terakhir adalah 4)[cite: 22]
                  size: 68.0,
                ),
              ),

              // Jarak Pemisah Horizontal menggunakan SizedBox[cite: 21]
              // Jarak Pemisah: 19.0 (Rumus: 15.0 + 4 karena digit terakhir adalah 4)[cite: 22]
              const SizedBox(width: 19.0),

              // Sisi Kanan: Menggunakan Column dengan perataan awal (CrossAxisAlignment.start)[cite: 21]
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kartu Praktikan",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      nama, // Menampilkan Nama Mahasiswa[cite: 21]
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Pemisah: Gunakan widget Divider(thickness: 1.5)[cite: 21]
          const Divider(thickness: 1.5),

          const SizedBox(height: 16.0),

          // Bagian Detail Identitas (Vertikal - Column)[cite: 21]
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Menampilkan baris Nim, Hobi, dan Skor Aktivitas[cite: 21]
            children: [
              Text(
                "NIM: $nim",
                // Pengaturan TextStyle FontWeight.w600[cite: 21]
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Hobi: $hobi",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Skor Aktivitas: $skorAktivitas",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}