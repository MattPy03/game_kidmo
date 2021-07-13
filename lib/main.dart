import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'kidmo_game.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, nome varchar(50) not null, race varchar(30) not null, class varchar(30) not null, level int(4) not null, );',
      );
    },
  );
  runApp(MyApp());
}

/*
nome const
razza const
classe const
livello (1,5)
abilita (max 5 abilita)
specializzazione
professione
soldi
hp
hp massimi (modificabile da livello e armatura, no modifica diretta)
armatura (da hp)
armi (fino a 2 armi)
inventario
inventario attivabili

//mie cose
ultima volta aperto
*/

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
  //generate list of boxes
  final boxes = List<Widget>.generate(
    30,
    (index) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('My number is $index'),
          Text(
            'That\'s my number',
            textScaleFactor: 0.9,
          )
        ]),
        Container(
          child: Icon(
            Icons.person,
            size: 26.0,
          ),
        )
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),

        //right Add Button
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
                child: Icon(
                  Icons.add,
                  size: 26.0,
                ),
              ))
        ],
      ),
      body: Center(
          child: ListView(
        children: boxes,
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
