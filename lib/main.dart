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
              ))
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

class SecondRoute extends StatelessWidget {

  verifyForm(BuildContext context) {

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Enter all the values."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create character'),
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
                    onPressed: () {

                      //Controllo textfield se ci sono dati o meno

                      // if () {
                      //   verifyForm(context);
                      // }
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
