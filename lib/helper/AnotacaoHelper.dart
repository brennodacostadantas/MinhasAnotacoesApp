import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/Anotacao.dart';

class AnotacaoHelper {
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _database;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {}

  get dabatase async {
    if (_database != null) {
      return _database;
    } else {
      _database = await inicializarDB();
      return _database;
    }
  }

  _onCreate(Database db, int version) async {
    String _sql =
        "CREATE TABLE anotacoes(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(_sql);
  }

  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "minhas_anotacoes_db.db");
    var db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Anotacao a) async {
    var bancoDados = await dabatase;
    int id = await bancoDados.insert("anotacoes", a.toMap());
    return id;
  }

  recuperarAnotacoes() async {
    var bancoDados = await dabatase;
    String sql = "SELECT * FROM anotacoes ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await dabatase;
    return await bancoDados.update("anotacoes", anotacao.toMap(),
        where: "id = ?", whereArgs: {anotacao.id});
  }

  Future<int> removerAnotacao(int id) async {
    var bancoDados = await dabatase;
    return await bancoDados
        .delete("anotacoes", where: "id = ?", whereArgs: [id]);
  }
}
