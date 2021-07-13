import 'package:flutter/material.dart';

void main() {
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
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
                child: Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )
          )
        ],
      ),
      body: Center(
        child: ListView(
          children: boxes,
        )
      ),
    );
  }
}

class SecondRoute extends StatefulWidget {

  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  String textValueRace = "Umano";
  String textValueClass = "Reietto";
  List<String> _itemsRace = ['Umano', 'Orco', 'Nano', 'Elfo', 'Mezzo-Orco', 'Mezzo-Elfo', 'Mezzo-Umano'];
  List<String> _itemsClass = ['Reietto', 'Mago', 'Guerriero', 'Bardo', 'Stregone'];

  verifyForm(BuildContext context) {

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Errore"),
      content: Text("Inserisci il nome del personaggio!"),
      actions: [
        TextButton(
          child: Text("OK"),
           onPressed: () {Navigator.of(context).pop();},
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

  TextEditingController characterName = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crea personaggio'),
      ),
      body: Center (
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome personaggio'
              ),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container (
                  padding: const EdgeInsets.all(15),
                  child: 
                    ElevatedButton(
                      onPressed: () {Navigator.pop(context);},
                      child: Text("Go back"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red
                      )
                    )
                ),
                Container (
                  padding: const EdgeInsets.all(15),
                  child:
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green
                      ),
                      onPressed: () {

                        if (characterName.text == "") {
                          verifyForm(context);
                        }

                      },
                      child: Text("Confirm")
                    )
                )
              ]
            )
          ]
        ),
      ),
    );
  }
}
