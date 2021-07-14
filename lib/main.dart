import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'kidmo_game.db'),
      onCreate: (database, version) async {
        await database.execute(
          '''CREATE TABLE sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sessionName varchar(50) not null,
          time int(32) not null,
          name varchar(50) not null,
          raceID int(8) not null,
          raceName varchar(30) not null,
          classID int(8) not null,
          className varchar(30) not null,
          level int(4) not null default 1,
          hpMax int(16) not null,
          hp int(16) not null,
          ability int(8) not null,
          specializationID int(4) not null,
          specializationName varchar(50) not null default 'Nessuna',
          professionID int(4) not null,
          professionName varchar(50) not null default 'Nessuna',
          money int(32) not null default 0,
          hpArmor int(32) not null default 0,
          armorName varchar(30) not null default 'Nessuna',
          weapon1Damage int(32) not null default 0,
          weapon1Name varchar(30) not null default 'Nessuna',
          multipleWeap int(1) not null default 1,
          weapon2Damage int(32) not null default 0,
          weapon2Name varchar(30) not null default 'Nessuna'
          );''',
        );
      },
      version: 1,
    );
  }

  Future<int> insertSession(Map<String, Object?> values) async {
    // Get a reference to the database.
    final db = await initializeDB();
    return await db.insert(
      'sessions',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map>> retrieveSessions() async {
    List<String> columnsToSelect = [
      "id",
      "name",
      "sessionName",
      "money",
      "hp",
      "hpMax"
    ];
    final Database db = await initializeDB();

    return await db.query('sessions',
        columns: columnsToSelect, orderBy: "time DESC");
  }

  Future<Map> retrieveSession(int id) async {
    final Database db = await initializeDB();
    List<Map> res =
        await db.query('sessions', where: "id = ?", whereArgs: [id]);
    return res[0];
  }

  // id-> the id of row to change, values -> map representing columns and their new value
  Future<void> updateSession(int id, Map<String, Object?> values) async {
    final Database db = await initializeDB();
    await db.update('sessions', values, where: "id = ?", whereArgs: [id]);
  }

  Future<void> deleteSession(int id) async {
    final db = await initializeDB();
    await db.delete(
      'sessions',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Profili'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseHandler handler;

  GestureDetector _generateCard(Map map, var context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ThirdRoute(db: handler, id: map["id"])));
        },
        child: Card(
          child: Row(
            children: [
              Expanded(
                  child: ListTile(
                title: Text(map["sessionName"]),
                subtitle: Text(map["name"], overflow: TextOverflow.ellipsis),
              )),
              Container(
                  padding: EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Text(map["money"].toString() + " monete"),
                      Text(map["hp"].toString() +
                          "/" +
                          map["hpMax"].toString() +
                          " vita")
                    ],
                  ))
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          //right Add Button
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SecondRoute(db: handler)),
                      //update database list after that
                    ).then((_) => setState(() {
                          this.handler.retrieveSessions();
                        }));
                  },
                  child: Icon(
                    Icons.add,
                    size: 26.0,
                  ),
                ))
          ],
        ),
        body: FutureBuilder(
          //need to use DatabaseHandler
          future: this.handler.retrieveSessions(),
          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
            //if has data
            if (snapshot.hasData) {
              //create a scrollable list
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  //the box in the list can be removed sliding it on the right
                  return Dismissible(
                      direction: DismissDirection.startToEnd,

                      //box showed when sliding
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(Icons.delete_forever),
                      ),
                      key: UniqueKey(),
                      //when the box is removed
                      onDismissed: (DismissDirection direction) async {
                        //remove from db the session
                        await this
                            .handler
                            .deleteSession(snapshot.data![index]["id"]!);
                        setState(() {
                          snapshot.data!.remove(snapshot.data![index]);
                        });
                      },
                      //positioning
                      child: _generateCard(snapshot.data![index], context));
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

class SecondRoute extends StatefulWidget {
  final DatabaseHandler db;
  SecondRoute({Key? key, required this.db}) : super(key: key);
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  String _textValueRace = "Umano";
  String _textValueClass = "Reietto";
  List<String> _itemsRace = [
    'Umano',
    'Orco',
    'Nano',
    'Elfo',
    'Mezzo-Orco',
    'Mezzo-Elfo',
    'Mezzo-Umano'
  ];
  List<String> _itemsClass = [
    'Reietto',
    'Mago',
    'Guerriero',
    'Bardo',
    'Stregone'
  ];

  _verifyForm(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Errore"),
      content:
          Text("Inserisci il nome della sessione e il nome del personaggio!"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  late TextEditingController characterName; // = TextEditingController();
  late TextEditingController sessionName;

  @override
  void initState() {
    super.initState();
    characterName = TextEditingController();
    sessionName = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crea personaggio'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: 'Nome della sessione'),
            controller: sessionName,
            validator: (value) {},
          ),
          TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: 'Nome personaggio'),
            controller: characterName,
            validator: (value) {},
          ),
          DropdownButton(
            hint: Text("Scegli la razza"),
            onChanged: (String? newValue) {
              setState(() {
                _textValueRace = newValue!;
              });
            },
            value: _textValueRace,
            items: _itemsRace.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          ),
          DropdownButton(
            hint: Text("Scegli la classe"),
            onChanged: (String? newValue) {
              setState(() {
                _textValueClass = newValue!;
              });
            },
            value: _textValueClass,
            items: _itemsClass.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Go back"),
                    style: ElevatedButton.styleFrom(primary: Colors.red))),
            Container(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () async {
                      if (characterName.text == "" || sessionName.text == "") {
                        _verifyForm(context);
                      } else {
                        int id = await widget.db.insertSession({
                          "sessionName": sessionName.text,
                          "time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          "name": characterName.text,
                          "raceID": 0,
                          "raceName": _textValueRace,
                          "classID": 0,
                          "className": _textValueClass,
                          "hpMax": 20,
                          "hp": 20,
                          "ability": 0,
                          "specializationID": 0,
                          "professionID": 0
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ThirdRoute(db: widget.db, id: id)));
                      }
                    },
                    child: Text("Confirm")))
          ])
        ]),
      ),
    );
  }
}

class ThirdRoute extends StatefulWidget {
  final DatabaseHandler db;
  final int id;
  ThirdRoute({Key? key, required this.db, required this.id}) : super(key: key);
  _ThirdRouteState createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
  late TextEditingController _money;
  late TextEditingController _life;
  late TextEditingController _specialization;
  late TextEditingController _level;

  Container _createRow(String index, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: TextStyle(fontSize: 15, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.left,
          )
        ],
      ),
    );
  }

  Container _createUpdatableRow(
      String index, String value, TextEditingController controller,
      //optional values
      [bool isNum = false,
      int? min,
      int? max]) {
    if (min != null && max != null && min > max) {
      max += min;
      min = max - min;
      max -= min;
    }
    controller.text = value;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: TextStyle(fontSize: 15, color: Colors.grey)),
          TextFormField(
            //select all text inside text field
            onTap: () => controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.value.text.length),
            //choose if show only number keyboard or normal one
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            //choose if allow every charaters or only digit
            inputFormatters:
                isNum ? [FilteringTextInputFormatter.digitsOnly] : [],
            style: TextStyle(fontSize: 20),
            controller: controller,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
            ),
            onChanged: (String tfValue) {
              if (tfValue != "" && isNum) {
                if (min != null && int.parse(tfValue) < min) {
                  controller.text = min.toString();
                } else if (max != null && int.parse(tfValue) > max) {
                  controller.text = max.toString();
                }
              }
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _level = TextEditingController();
    _money = TextEditingController();
    _life = TextEditingController();
    _specialization = TextEditingController();
  }

  Widget build(BuildContext context) {
    // widget.db.retrieveSessions();
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheda personaggio'),
      ),
      body: FutureBuilder(
          future: widget.db.retrieveSession(widget.id),
          builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _createRow("Nome", snapshot.data!["name"]),
                      _createRow("Razza", snapshot.data!["raceName"]),
                      _createRow("Classe", snapshot.data!["className"]),
                      _createUpdatableRow(
                          "Livello",
                          snapshot.data!["level"].toString(),
                          _level,
                          true,
                          1,
                          5),
                      _createRow("Vita",
                          '${snapshot.data!["hp"]}/${snapshot.data!["hpMax"]}'),
                      _createUpdatableRow(
                          "Monete", "${snapshot.data!["money"]}", _money, true),
                      _createUpdatableRow(
                          "specializzazione",
                          snapshot.data!["specializationName"].toString(),
                          _specialization)
                    ],
                  ));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      drawer: Drawer(
        child: Container(
            decoration: BoxDecoration(color: Colors.lightBlue),
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Scheda personaggio'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Torna alla home'),
                  onTap: () {
                    // Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context) => MyApp()));
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            )),
      ),
    );
  }
}
