import 'package:flutter/material.dart';
import 'main.dart';

class Idiomas extends StatefulWidget {
  Idiomas();

  @override
  _Idiomas createState() => _Idiomas();
}

class _Idiomas extends State<Idiomas> {

  cambiarIdioma(idiomaNuevo) {

    setState(() {
      idioma = idiomaNuevo;
    });
    Navigator.pushReplacementNamed(context, '/');
  }

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
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    width: 48.0,
                    height: 48.0,
                    alignment: Alignment.topLeft,
                  ),
                  ElevatedButton(
                      child: Text('Español'),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.all(16.0)),
                          textStyle: MaterialStateProperty.all(TextStyle(
                              fontSize: 22,
                              color: Colors.white
                          )),
                          elevation: MaterialStateProperty.all(0.5),
                          minimumSize: MaterialStateProperty.all(Size(150, 50))
                      ),

                      onPressed: () => cambiarIdioma(0)
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    width: 48.0,
                    height: 5.0,
                    alignment: Alignment.topLeft,
                  ),
                  ElevatedButton(
                      child: Text('English'),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.all(16.0)),
                          textStyle: MaterialStateProperty.all(TextStyle(
                              fontSize: 22,
                              color: Colors.white
                          )),
                          elevation: MaterialStateProperty.all(0.5),
                          minimumSize: MaterialStateProperty.all(Size(150, 50))
                      ),

                      onPressed: () => cambiarIdioma(1)
                  ),
                ]
            )
        ),
      ),

    );
  }
}
