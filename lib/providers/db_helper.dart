import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/photo.dart';
class DBHelper {

static Database? _database;

  //Instancio
  static final DBHelper db = DBHelper._();
  
  static const String ID = 'id';
  static const String NAME = 'photoName';
  static const String TABLE = 'PhotosTable';
  static const String DB_NAME = 'photos.db';

  DBHelper._();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $TABLE ($ID INTEGER, $NAME TEXT)");
  }

  Future<Photo> save(Photo employee) async {
    var dbClient = await database;
    employee.id = await dbClient!.insert(TABLE, employee.toMap());
    return employee;
  }

  Future<List<Photo>> getPhotos() async {
    var dbClient = await database;
    List<Map> maps = await dbClient!.query(TABLE, columns: [ID, NAME]);
    List<Photo> employees = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(Photo.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return employees;
  }

  Future close() async {
    var dbClient = await database;
    dbClient?.close();
  }
}