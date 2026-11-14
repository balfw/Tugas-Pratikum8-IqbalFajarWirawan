import 'package:flutter/material.dart';

import 'database_helper.dart';

class DaftarCatatan extends StatefulWidget {
  const DaftarCatatan({super.key});
  @override
  State<DaftarCatatan> createState() => _DaftarCatatanState();
}

class _DaftarCatatanState extends State<DaftarCatatan> {
  List<Map<String, Object?>> catatan = [];
  bool memuat = true;
  String? error;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    setState(() {
      memuat = true;
      error = null;
    });
    try {
      final data = await DatabaseCatatan.baca();
      if (mounted) setState(() => catatan = data);
    } catch (e) {
      if (mounted) setState(() => error = 'Gagal membaca: $e');
    } finally {
      if (mounted) setState(() => memuat = false);
    }
  }

  void pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> edit(Map<String, Object?> data) async {
    final judul = TextEditingController(text: data['judul'] as String);
    final isi = TextEditingController(text: data['isi'] as String);
    final hasil = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Catatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judul,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: isi,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Isi'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, [
              judul.text.trim(),
              isi.text.trim(),
            ]),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    // Tunggu animasi penutupan dialog sebelum membuang controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    judul.dispose();
    isi.dispose();
    if (hasil == null || !mounted) return;
    if (hasil.any((teks) => teks.isEmpty)) {
      pesan('Judul dan isi wajib diisi.');
      return;
    }
    try {
      final jumlah = await DatabaseCatatan.ubah(
        data['id'] as int,
        hasil[0],
        hasil[1],
      );
      if (jumlah != 1) throw StateError('Catatan tidak ditemukan');
      if (!mounted) return;
      pesan('Catatan berhasil diubah.');
      await muat();
    } catch (e) {
      if (mounted) pesan('Gagal mengubah: $e');
    }
  }

  Future<void> hapus(int id) async {
    try {
      final jumlah = await DatabaseCatatan.hapus(id);
      if (jumlah != 1) throw StateError('Catatan tidak ditemukan');
      if (!mounted) return;
      pesan('Catatan berhasil dihapus.');
      await muat();
    } catch (e) {
      if (mounted) pesan('Gagal menghapus: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Daftar Catatan'),
      actions: [
        IconButton(
          onPressed: memuat ? null : muat,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: memuat
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : catatan.isEmpty
        ? const Center(child: Text('Belum ada catatan.'))
        : ListView.builder(
            itemCount: catatan.length,
            itemBuilder: (context, index) {
              final data = catatan[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['judul'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(data['isi'] as String),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => edit(data),
                            child: const Text('Edit'),
                          ),
                          TextButton(
                            onPressed: () => hapus(data['id'] as int),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
  );
}
