import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/certificate.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'certificates.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE certificates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileType TEXT NOT NULL,
        fileSize REAL NOT NULL,
        uploadDate TEXT NOT NULL,
        description TEXT,
        category TEXT
      )
    ''');
  }

  Future<int> insertCertificate(Certificate certificate) async {
    final db = await database;
    return await db.insert('certificates', certificate.toMap());
  }

  Future<List<Certificate>> getAllCertificates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'certificates',
      orderBy: 'uploadDate DESC',
    );
    return List.generate(maps.length, (i) => Certificate.fromMap(maps[i]));
  }

  Future<Certificate?> getCertificate(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'certificates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Certificate.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCertificate(Certificate certificate) async {
    final db = await database;
    return await db.update(
      'certificates',
      certificate.toMap(),
      where: 'id = ?',
      whereArgs: [certificate.id],
    );
  }

  Future<int> deleteCertificate(int id) async {
    final db = await database;
    return await db.delete(
      'certificates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Certificate>> searchCertificates(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'certificates',
      where: 'fileName LIKE ? OR description LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'uploadDate DESC',
    );
    return List.generate(maps.length, (i) => Certificate.fromMap(maps[i]));
  }

  Future<List<Certificate>> getCertificatesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'certificates',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'uploadDate DESC',
    );
    return List.generate(maps.length, (i) => Certificate.fromMap(maps[i]));
  }
} 