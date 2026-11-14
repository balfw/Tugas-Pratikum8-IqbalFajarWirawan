import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseCatatan {
  static Future<Database>? _koneksi;
  static Future<Database> get database async {
    try {
      return await (_koneksi ??= openDatabase(
        kIsWeb
            ? 'catatan_mahasiswa.db'
            : p.join(await getDatabasesPath(), 'catatan_mahasiswa.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE catatan ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, judul TEXT, isi TEXT)',
          );
        },
      ));
    } catch (_) {
      _koneksi = null;
      rethrow;
    }
  }

  static Future<int> tambah(String judul, String isi) async =>
      (await database).insert('catatan', {'judul': judul, 'isi': isi});
  static Future<List<Map<String, Object?>>> baca() async =>
      (await database).query('catatan', orderBy: 'id DESC');
  static Future<int> ubah(int id, String judul, String isi) async =>
      (await database).update(
        'catatan',
        {'judul': judul, 'isi': isi},
        where: 'id = ?',
        whereArgs: [id],
      );
  static Future<int> hapus(int id) async =>
      (await database).delete('catatan', where: 'id = ?', whereArgs: [id]);
}
