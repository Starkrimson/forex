// Package imports:
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:forex/forex/model.dart';

const convertTable = "Convert";
const fixerTable = "Fixer";

class DBProvider {
  late Database db;

  Future open() async {
    var path = await getDatabasesPath();
    Logger().d(path);
    path = join(path, "forex.db");
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
        '''
        CREATE TABLE $convertTable (
          uuid TEXT PRIMARY KEY,
          _from TEXT,
          _to TEXT
          )
          ''',
      );

      await db.execute(
        '''
        CREATE TABLE $fixerTable (
          timestamp INTEGER PRIMARY KEY,
          date TEXT,
          value TEXT
          )
          ''',
      );
    });
  }

  Future<List<Convert>> getConvertList() async {
    List<Map<String, dynamic>> maps = await db.query(convertTable);
    return maps.map((e) => Convert.fromMap(e)).toList();
  }

  Future<Convert> insertConvert(Convert convert) async {
    await db.insert(convertTable, convert.toMap());
    return convert;
  }

  Future updateConvert(Convert convert) async {
    return await db.update(convertTable, convert.toMap(),
        where: 'uuid = ?', whereArgs: [convert.uuid]);
  }

  Future deleteConvert(String uuid) async {
    return await db.delete(convertTable, where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<Fixer?> getLatestFixer() async {
    List<Map<String, dynamic>> maps = await db.query(
      fixerTable,
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Fixer.fromDBMap(maps.first);
    }
    return null;
  }

  Future<Fixer> insertFixer(Fixer fixer) async {
    await db.insert(fixerTable, fixer.toDBMap());
    return fixer;
  }

  Future close() async => db.close();
}
