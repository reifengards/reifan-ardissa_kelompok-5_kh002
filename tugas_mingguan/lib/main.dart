import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatatan Stok Barang',
      theme: AppTheme.lightTheme,
      home: const StokBarangScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StokBarangScreen extends StatefulWidget {
  const StokBarangScreen({super.key});

  @override
  State<StokBarangScreen> createState() => _StokBarangScreenState();
}

class _StokBarangScreenState extends State<StokBarangScreen> {
  final _formKey = GlobalKey<FormState>();

  // Lima controller untuk input form
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _tanggalMasukController = TextEditingController();
  final TextEditingController _tanggalKeluarController = TextEditingController();
  final TextEditingController _kodeBarangController = TextEditingController();
  final TextEditingController _jumlahStokController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaBarangController.dispose();
    _tanggalMasukController.dispose();
    _tanggalKeluarController.dispose();
    _kodeBarangController.dispose();
    _jumlahStokController.dispose();
    super.dispose();
  }

  Future<void> _simpanBarang() async {
    // Validasi seluruh input
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mengambil data dari form pengguna
      final String namaBarang = _namaBarangController.text.trim();
      final String tanggalMasuk = _tanggalMasukController.text.trim();
      final String tanggalKeluar = _tanggalKeluarController.text.trim();

      // Konversi Kode Barang dan Jumlah Stok ke integer (Number)
      final int kodeBarang = int.parse(_kodeBarangController.text.trim());
      final int jumlahStok = int.parse(_jumlahStokController.text.trim());

      // Menyimpan data ke collection 'stok_barang' di Firebase Cloud Firestore
      await FirebaseFirestore.instance.collection('stok_barang').add({
        'nama_barang': namaBarang,
        'tanggal_masuk': tanggalMasuk,
        'tanggal_keluar': tanggalKeluar,
        'kode_barang': kodeBarang,
        'jumlah_stok': jumlahStok,
        'waktu': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Notifikasi sukses dan reset form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data barang berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      _namaBarangController.clear();
      _tanggalMasukController.clear();
      _tanggalKeluarController.clear();
      _kodeBarangController.clear();
      _jumlahStokController.clear();
      _formKey.currentState?.reset();
    } catch (e) {
      if (!mounted) return;

      // Notifikasi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Stok Barang'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 28, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Input Stok Barang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1. TextFormField Nama Barang (harus diawali inisial 'R')
                    TextFormField(
                      controller: _namaBarangController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        hintText: 'Contoh: Rak Buku / Reifan Laptop (Awali inisial R)',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama barang wajib diisi';
                        }
                        final trimmed = value.trim();
                        if (!trimmed.toUpperCase().startsWith('R')) {
                          return 'Nama barang harus diawali dengan inisial nama ("R")';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. TextFormField Tanggal Masuk Barang (berupa teks)
                    TextFormField(
                      controller: _tanggalMasukController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Masuk Barang',
                        hintText: 'Masukkan tanggal masuk (contoh: 16-10-2026)',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tanggal masuk barang wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. TextFormField Tanggal Keluar Barang (berupa teks)
                    TextFormField(
                      controller: _tanggalKeluarController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Keluar Barang',
                        hintText: 'Masukkan tanggal keluar (contoh: 20-10-2026)',
                        prefixIcon: Icon(Icons.event_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tanggal keluar barang wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. TextFormField Kode Barang (numerik, min 6 angka, 2 digit terakhir '02')
                    TextFormField(
                      controller: _kodeBarangController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Barang',
                        hintText: 'Contoh: 123402 (min. 6 digit & diakhiri 02)',
                        prefixIcon: Icon(Icons.qr_code),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kode barang wajib diisi';
                        }
                        final trimmed = value.trim();
                        final parsed = int.tryParse(trimmed);
                        if (parsed == null || !RegExp(r'^\d+$').hasMatch(trimmed)) {
                          return 'Kode barang harus berupa bilangan bulat (angka)';
                        }
                        if (trimmed.length < 6) {
                          return 'Kode barang minimal 6 digit angka';
                        }
                        if (!trimmed.endsWith('02')) {
                          return '2 digit terakhir kode barang harus "02" (2 angka terakhir NIM)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. TextFormField Jumlah Stok (numerik, integer >= 0)
                    TextFormField(
                      controller: _jumlahStokController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Stok',
                        hintText: 'Contoh: 25',
                        prefixIcon: Icon(Icons.format_list_numbered),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jumlah stok wajib diisi';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null) {
                          return 'Jumlah stok harus berupa bilangan bulat';
                        }
                        if (parsed < 0) {
                          return 'Jumlah stok tidak boleh negatif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan Barang
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _simpanBarang,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isLoading ? 'Menyimpan...' : 'Simpan Barang',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}