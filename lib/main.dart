import 'package:flutter/material.dart';
import 'dart:async';

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
          specializationName varchar(50),
          professionID int(4) not null,
          professionName varchar(50),
          money int(32) not null default 0,
          hpArmor int(32) not null default 0,
          armorName varchar(30),
          weapon1Damage int(32) not null default 0,
          weapon1Name varchar(30),
          multipleWeap int(1) not null default 1,
          weapon2Damage int(32) not null default 0,
          weapon2Name varchar(30)
          );''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertSession(Map<String, Object?> values) async {
    // Get a reference to the database.
    final db = await initializeDB();
    await db.insert(
      'sessions',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map>> retrieveSessions() async {
    final Database db = await initializeDB();
    return await db.query('sessions');
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

  Card _generateCard(Map map) {
    return Card(
      child: Row(
        children: [
          Expanded(
              child: ListTile(
            title: Text(map["sessionName"]),
            subtitle: Text(map["name"]),
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
    );
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
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ThirdRoute()))
                      .then((_) => setState(() {
                            this.handler.retrieveSessions();
                          }));
                  ;
                },
              );
            },
          ),
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
                      child: _generateCard(snapshot.data![index]));
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
  String textValueRace = "Umano";
  String textValueClass = "Reietto";
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

  verifyForm(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Errore"),
      content: Text("Inserisci il nome del personaggio!"),
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

  @override
  void initState() {
    super.initState();
    characterName = TextEditingController();
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
                border: OutlineInputBorder(), labelText: 'Nome personaggio'),
            controller: characterName,
            validator: (value) {},
          ),
          DropdownButton(
            hint: Text("Scegli la razza"),
            onChanged: (String? newValue) {
              setState(() {
                textValueRace = newValue!;
              });
            },
            value: textValueRace,
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
                textValueClass = newValue!;
              });
            },
            value: textValueClass,
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
                    onPressed: () {
                      if (characterName.text == "") {
                        verifyForm(context);
                      } else {
                        widget.db.insertSession({
                          "sessionName": "prova2",
                          "time": 3,
                          "name": characterName.text,
                          "raceID": 0,
                          "raceName": textValueRace,
                          "classID": 0,
                          "className": textValueClass,
                          "hpMax": 20,
                          "hp": 20,
                          "ability": 0,
                          "specializationID": 0,
                          "professionID": 0
                        });
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
  _ThirdRouteState createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheda personaggio'),
      ),
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                ),
              ],
            )),
      ),
    );
  }
}
