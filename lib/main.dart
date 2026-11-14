import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'database_helper.dart';
import 'halaman_catatan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const MaterialApp(home: TambahCatatan()));
}

class TambahCatatan extends StatefulWidget {
  const TambahCatatan({super.key});
  @override
  State<TambahCatatan> createState() => _TambahCatatanState();
}

class _TambahCatatanState extends State<TambahCatatan> {
  final judul = TextEditingController();
  final isi = TextEditingController();
  bool sibuk = false;

  void pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> simpan() async {
    if (judul.text.trim().isEmpty || isi.text.trim().isEmpty) {
      pesan('Judul dan isi wajib diisi.');
      return;
    }
    setState(() => sibuk = true);
    try {
      await DatabaseCatatan.tambah(judul.text.trim(), isi.text.trim());
      if (!mounted) return;
      judul.clear();
      isi.clear();
      pesan('Catatan berhasil disimpan.');
    } catch (e) {
      if (mounted) pesan('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => sibuk = false);
    }
  }

  @override
  void dispose() {
    judul.dispose();
    isi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tambah Catatan')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: judul,
          decoration: const InputDecoration(labelText: 'Judul Catatan'),
        ),
        TextField(
          controller: isi,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Isi Catatan'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: sibuk ? null : simpan,
          child: Text(sibuk ? 'Menyimpan...' : 'Simpan'),
        ),
        OutlinedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const DaftarCatatan()),
            );
          },
          child: const Text('Lihat Catatan'),
        ),
      ],
    ),
  );
}
