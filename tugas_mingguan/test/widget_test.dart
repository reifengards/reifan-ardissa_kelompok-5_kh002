import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_layout_flutter/main.dart';

void main() {
  testWidgets('Form stok barang 5 field smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StokBarangScreen(),
      ),
    );

    expect(find.text('Input Stok Barang'), findsOneWidget);
    expect(find.text('Nama Barang'), findsOneWidget);
    expect(find.text('Tanggal Masuk Barang'), findsOneWidget);
    expect(find.text('Tanggal Keluar Barang'), findsOneWidget);
    expect(find.text('Kode Barang'), findsOneWidget);
    expect(find.text('Jumlah Stok'), findsOneWidget);
    expect(find.text('Simpan Barang'), findsOneWidget);
  });

  testWidgets('Validasi inisial nama dan digit NIM pada kode barang', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: StokBarangScreen(),
      ),
    );

    final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Barang');
    await tester.ensureVisible(simpanButton);

    // Tekan tombol simpan saat form kosong
    await tester.tap(simpanButton);
    await tester.pumpAndSettle();

    expect(find.text('Nama barang wajib diisi'), findsOneWidget);
    expect(find.text('Kode barang wajib diisi'), findsOneWidget);

    final textFields = find.byType(TextField);
    final namaField = textFields.at(0); // Nama Barang
    final kodeField = textFields.at(3); // Kode Barang
    final stokField = textFields.at(4); // Jumlah Stok

    // Masukkan nama barang tanpa inisial R
    await tester.enterText(namaField, 'Buku Tulis');
    // Masukkan kode barang kurang dari 6 digit
    await tester.enterText(kodeField, '1234');
    // Masukkan jumlah stok negatif
    await tester.enterText(stokField, '-5');

    await tester.tap(simpanButton);
    await tester.pumpAndSettle();

    expect(find.text('Nama barang harus diawali dengan inisial nama ("R")'), findsOneWidget);
    expect(find.text('Kode barang minimal 6 digit angka'), findsOneWidget);
    expect(find.text('Jumlah stok tidak boleh negatif'), findsOneWidget);

    // Masukkan kode 6 digit tapi tidak berakhiran 02
    await tester.enterText(kodeField, '123456');
    await tester.tap(simpanButton);
    await tester.pumpAndSettle();

    expect(find.text('2 digit terakhir kode barang harus "02" (2 angka terakhir NIM)'), findsOneWidget);

    // Masukkan kode 6 digit yang benar berakhiran 02 dan nama diawali R
    await tester.enterText(namaField, 'Rak Buku');
    await tester.enterText(kodeField, '123402');
    await tester.enterText(stokField, '10');

    await tester.tap(simpanButton);
    await tester.pumpAndSettle();

    // Tidak ada lagi error validasi pada field tersebut
    expect(find.text('Nama barang harus diawali dengan inisial nama ("R")'), findsNothing);
    expect(find.text('Kode barang minimal 6 digit angka'), findsNothing);
    expect(find.text('2 digit terakhir kode barang harus "02" (2 angka terakhir NIM)'), findsNothing);
    expect(find.text('Jumlah stok tidak boleh negatif'), findsNothing);
  });
}
