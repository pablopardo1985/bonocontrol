import 'package:flutter/material.dart';
import 'main.dart';

class Funcionamiento extends StatefulWidget {
  Funcionamiento();

  @override
  _Funcionamiento createState() => _Funcionamiento();
}

class _Funcionamiento extends State<Funcionamiento> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraAPP(
          titulo: Textos[idioma]['titulo'],
          appBar: AppBar()
      ),
      drawer: DrawerAPP(),
      body: Center(
        child: Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.all(20.0),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      width: 48.0,
                      height: 48.0,
                      alignment: Alignment.topLeft,
                    ),
                    Text(
                      Textos[idioma]['funcionamiento'],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54
                      ),
                    ),
                ]
              )

            ]
            ),
        ),
      )
    );
  }
}
