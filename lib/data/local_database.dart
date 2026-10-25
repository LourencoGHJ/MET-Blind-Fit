import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      p.join(root, 'met_blind_fit_local.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE runs (
          id TEXT PRIMARY KEY, title TEXT NOT NULL, city TEXT NOT NULL,
          meeting_point TEXT NOT NULL, date_label TEXT NOT NULL,
          time_label TEXT NOT NULL, distance_km REAL NOT NULL,
          pace TEXT NOT NULL, level TEXT NOT NULL, capacity INTEGER NOT NULL,
          enrolled INTEGER NOT NULL, guides INTEGER NOT NULL,
          supervisor TEXT NOT NULL, verified INTEGER NOT NULL,
          description TEXT NOT NULL, status TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE friendships (
          id TEXT PRIMARY KEY, name TEXT NOT NULL, role TEXT NOT NULL,
          created_at TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE bookings (
          run_id TEXT PRIMARY KEY, status TEXT NOT NULL, created_at TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE activity_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT NOT NULL,
          created_at TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE preferences (
          key TEXT PRIMARY KEY, value TEXT NOT NULL
        )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''CREATE TABLE preferences (
            key TEXT PRIMARY KEY, value TEXT NOT NULL
          )''');
        }
      },
    );
    await _seed(_db!);
    return _db!;
  }

  Future<void> _seed(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM runs')) ?? 0;
    if (count > 0) return;
    final runs = [
      {'id':'run_foz','title':'Corrida inclusiva à beira-mar','city':'Porto · Foz do Douro','meeting_point':'Jardim do Passeio Alegre, entrada principal','date_label':'Sábado, 31 de outubro','time_label':'09:30','distance_km':4.0,'pace':'Confortável · conversa','level':'Iniciação','capacity':12,'enrolled':8,'guides':4,'supervisor':'Marta Silva','verified':1,'description':'Corrida social em grupo, com briefing inicial, guias atribuídos, pontos de controlo e regresso ao ponto de encontro. O percurso deve ser confirmado pelo supervisor antes da sessão.','status':'open'},
      {'id':'run_parque','title':'Treino no Parque da Cidade','city':'Porto · Parque da Cidade','meeting_point':'Entrada Norte, junto ao quiosque','date_label':'Domingo, 1 de novembro','time_label':'10:00','distance_km':5.0,'pace':'Moderado · 6:30–7:00/km','level':'Intermédio','capacity':10,'enrolled':6,'guides':3,'supervisor':'João Ribeiro','verified':1,'description':'Treino de cinco quilómetros em grupo pequeno. A organização confirma previamente o estado dos caminhos, as atribuições de guias e o plano de contingência.','status':'open'},
      {'id':'run_maia','title':'Primeiros passos em grupo','city':'Maia · Parque Central','meeting_point':'Entrada principal do Parque Central','date_label':'Quarta-feira, 4 de novembro','time_label':'18:30','distance_km':2.0,'pace':'Muito confortável','level':'Primeira corrida','capacity':8,'enrolled':5,'guides':3,'supervisor':'Inês Costa','verified':1,'description':'Sessão de iniciação com aquecimento, apresentação dos participantes, percurso curto e tempo para socializar no final.','status':'open'},
      {'id':'run_matosinhos','title':'Ritmo e companhia','city':'Matosinhos · Marginal','meeting_point':'Praça junto à praia, ponto combinado','date_label':'Sábado, 7 de novembro','time_label':'09:00','distance_km':6.0,'pace':'Moderado','level':'Intermédio','capacity':10,'enrolled':10,'guides':4,'supervisor':'Rui Fernandes','verified':1,'description':'Grupo de ritmo moderado. Lista de espera disponível; a organização só confirma a participação quando existir capacidade de acompanhamento adequada.','status':'full'},
    ];
    for (final run in runs) { await db.insert('runs', run); }
    await db.insert('friendships', {'id':'friend_marta','name':'Marta Silva','role':'Guia verificada','created_at':DateTime.now().toIso8601String()});
    await db.insert('activity_log', {'message':'Base local inicializada com dados demonstrativos.','created_at':DateTime.now().toIso8601String()});
  }

  Future<Map<String, String>> getPreferences() async {
    final rows = await (await database).query('preferences');
    return {for (final row in rows) row['key'] as String: row['value'] as String};
  }

  Future<void> setPreference(String key, String value) async {
    await (await database).insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await log('Preferência atualizada: $key');
  }

  Future<List<Map<String, Object?>>> getRuns() async => (await database).query('runs', orderBy: 'date_label ASC');
  Future<Map<String, Object?>?> getRun(String id) async {
    final rows = await (await database).query('runs', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }
  Future<List<Map<String, Object?>>> getBookings() async => (await database).query('bookings', orderBy: 'created_at DESC');
  Future<List<Map<String, Object?>>> getFriends() async => (await database).query('friendships', orderBy: 'name COLLATE NOCASE');
  Future<List<Map<String, Object?>>> getLog() async => (await database).query('activity_log', orderBy: 'id DESC', limit: 30);

  Future<String> bookRun(Map<String, Object?> run) async {
    final db = await database;
    final existing = await db.query('bookings', where: 'run_id = ?', whereArgs: [run['id']]);
    if (existing.isNotEmpty) {
      await db.delete('bookings', where: 'run_id = ?', whereArgs: [run['id']]);
      await db.rawUpdate('UPDATE runs SET enrolled = MAX(0, enrolled - 1) WHERE id = ?', [run['id']]);
      await log('Reserva cancelada: ${run['title']}');
      return 'cancelled';
    }
    if ((run['status'] as String) == 'full' || ((run['enrolled'] as int) >= (run['capacity'] as int))) {
      return 'waitlist';
    }
    await db.insert('bookings', {'run_id':run['id'], 'status':'confirmed', 'created_at':DateTime.now().toIso8601String()});
    await db.rawUpdate('UPDATE runs SET enrolled = enrolled + 1 WHERE id = ?', [run['id']]);
    await log('Reserva criada: ${run['title']}');
    return 'booked';
  }
  Future<void> addFriend(String name) async {
    final db = await database;
    final id = 'friend_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('friendships', {'id':id, 'name':name, 'role':'Amigo/a', 'created_at':DateTime.now().toIso8601String()});
    await log('Novo amigo adicionado: $name');
  }
  Future<void> log(String message) async => (await database).insert('activity_log', {'message':message, 'created_at':DateTime.now().toIso8601String()});
  Future<void> clearDemoData() async {
    final db = await database;
    await db.delete('bookings'); await db.delete('friendships'); await db.delete('activity_log'); await db.delete('runs');
    await _seed(db);
  }
}
