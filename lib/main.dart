import 'dart:developer';
import 'package:flutter/material.dart';
import 'inicio.dart';
import 'funcionamiento.dart';
import 'establecimientos.dart';
import 'mapa.dart';
import 'idiomas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:device_info/device_info.dart';

//TODO: Move to config file
const Map<int, Color> TonalidadesPrincipal = {
    50:Color.fromRGBO(65,41,110, .1),
    100:Color.fromRGBO(65,41,110, .2),
    200:Color.fromRGBO(65,41,110, .3),
    300:Color.fromRGBO(65,41,110, .4),
    400:Color.fromRGBO(65,41,110, .5),
    500:Color.fromRGBO(65,41,110, .6),
    600:Color.fromRGBO(65,41,110, .7),
    700:Color.fromRGBO(65,41,110, .8),
    800:Color.fromRGBO(65,41,110, .9),
    900:Color.fromRGBO(65,41,110, 1)
};
const Map<int, Color> TonalidadesSecundario = {
  50:Color.fromRGBO(228,74,138, .1),
  100:Color.fromRGBO(228,74,138, .2),
  200:Color.fromRGBO(228,74,138, .3),
  300:Color.fromRGBO(228,74,138, .4),
  400:Color.fromRGBO(228,74,138, .5),
  500:Color.fromRGBO(228,74,138, .6),
  600:Color.fromRGBO(228,74,138, .7),
  700:Color.fromRGBO(228,74,138, .8),
  800:Color.fromRGBO(228,74,138, .9),
  900:Color.fromRGBO(228,74,138, 1)
};
const MaterialColor principal = MaterialColor(0xFF41296e, TonalidadesPrincipal);
const MaterialColor secundario = MaterialColor(0xFFe44a8a, TonalidadesSecundario);


//TODO: Move to languages file
const Map<int, Map<String, String>> Textos = {
  0: {
    'titulo': 'BonoCONTROL',
    'inicio': 'Inicio',
    'desconectar': 'Desconectar',
    'desconectado': 'No registrado',
    'como_funciona': '¿Cómo funciona la app?',
    'establecimientos': 'Establecimientos',
    'idiomas': 'Idiomas',
    'salir': 'Salir',
    'introduzcadni': '1. Introduzca Su DNI/NIF',
    'escaneeqr': '2. Escanee un código QR de uno de sus bonos',
    'dni': 'DNI/NIE',
    'introduzcadatos': 'Introduzca sus datos',
    'escanear': 'ESCANEAR',
    'funcionamiento': 'Introduzca su DNI/NIF y escanee el código QR de cualquiera de los bonos que ha comprado.\n\nSe comprobará que el bono y el DNI/NIF estan relacionados en la misma compra y se mostrará en pantalla con detalle los códigos QR con la información de cada uno de ellos: Nombre del producto, importe de valor y estado del bono.\n\nSi el bono no ha sido utilizado aparecerá como estado “Disponible”.\n\nSi el bono ha sido utilizado aparecerá el QR en color rojo y en estado “USADO”. Justo  debajo aparecerá en que fecha se ha utilizado y en que lugar.',
    'disponible': 'Disponible',
    'usado': 'Usado',
    'fecha_escaneo': 'Fecha escaneo:',
    'valor': 'Valor:',
    'canjear': 'Establecimientos dónde canjear',
    'ver_en_mapa': 'Ver en mapa',
    'buscar_establecimiento': 'Buscar un establecimiento',
    'campana': 'Campaña',
    'campana_vacia': 'Sin campaña'
  },
  1: {
    'titulo': 'BonoCONTROL',
    'inicio': 'Home',
    'desconectar': 'Log out',
    'desconectado': 'Not logged in',
    'como_funciona': 'How it works?',
    'establecimientos': 'Establishments',
    'idiomas': 'Languages',
    'salir': 'Exit',
    'introduzcadni': '1. Insert your DNI/NIF',
    'escaneeqr': '2. Scan the QR code of one of your tickets',
    'dni': 'DNI/NIE',
    'introduzcadatos': 'Insert your data',
    'escanear': 'SCAN',
    'funcionamiento': 'Insert your DNI/NIF and scan the QR code of any of the tickets you\'ve bought.\n\nThe system will check that ticket and DNI/NIF match in the same purchase and the APP will show the QR code detail of each one: Product name, value and ticket state.\n\nIf the ticket wasn\t used, it will appear as “Free”.\n\nOtherwise, the QR code will appear red and with “USED” state. Below, you\'ll see the place and date where it has been used.',
    'disponible': 'Free',
    'usado': 'Used',
    'fecha_escaneo': 'Scan date:',
    'valor': 'Value:',
    'canjear': 'Establishments where to exchange',
    'ver_en_mapa': 'Show in map',
    'buscar_establecimiento': 'Find establishements',
    'campana': 'Campaign',
    'campana_vacia': 'No campaign'
  }
};

bool logueado = false;
String token = "";
int idioma = 0;
List campanas = [];
int campana_activa = 0;
bool primerLogin = false;
SharedPreferences prefs;
final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

String uuid = "";

var location = new Location();
LocationData userLocation;



void main() async {
  runApp(BonoControl());
}


class BonoControl extends StatelessWidget {

  //Main widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos[idioma]['titulo'],
      theme: ThemeData(
        primarySwatch: principal,
        accentColor: secundario
      ),
      home: Inicio(),
      routes: {
        "/inicio": (context) => Inicio(),
        "/funcionamiento": (context) => Funcionamiento(),
        "/idiomas": (context) => Idiomas(),
        "/establecimientos": (context) => Establecimientos(),
        "/mapa": (context) => Mapa()
      },
    );
  }
}

//FUNCIONES OPERATIVAS. TODO: Move to functions script
class BarraAPP extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final AppBar appBar;
  const BarraAPP({Key key, this.titulo, this.appBar}) : super(key: key);

  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      centerTitle: true,
      primary: true,
      flexibleSpace: Image(
          image: AssetImage('assets/appbar.jpg'),
          fit: BoxFit.fill
      ),
    );
  }

  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}

class DrawerAPP extends StatefulWidget {
  DrawerAPP({Key key }) : super(key: key);

  @override
  _DrawerAPP createState() => _DrawerAPP();
}

class _DrawerAPP extends State<DrawerAPP> {

  List<Widget> devolverCampanas() {
    List<ElevatedButton> enlaces = [];
    if (campanas.length > 0) {
      for (var i = 0; i < campanas.length; i++) {
        enlaces.add(ElevatedButton(
            child: Text(campanas[i]["nombre"] != '' ? campanas[i]["nombre"] : '', style: TextStyle(
                fontSize: 10
            )),
            style: ButtonStyle(
                backgroundColor: i == campana_activa ? MaterialStateProperty.all(secundario) : MaterialStateProperty.all(Colors.white10),
                padding: MaterialStateProperty.all(EdgeInsets.all(4)),
            ),
            onPressed: () {
              setState(() {
                campana_activa = i;
                Future<bool> test() async {
                  dynamic respuesta = await llamadaAPI({
                    'funcion': 'campana',
                    'campana': campanas[i]['id'],
                    'tipo': 'actualizar'
                  });
                  Navigator.pushReplacementNamed(context, '/');
                }
                test();
              });
            }
        ));

      }
    }
    else {
      enlaces = [
        ElevatedButton(
          child: Text(Textos[idioma]["campana_vacia"], style: TextStyle(
            fontSize: 12
          ))
        )
      ];
    }
    return enlaces;
  }

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: principal,
            ),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Textos[idioma]['titulo'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Container(
                      height: 60,
                      padding: EdgeInsets.all(4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: devolverCampanas()
                      )
                  )
                ],
              ),
            ),

          ),

          ListTile(
              leading: Icon(Icons.home),
              title: Text(Textos[idioma]['inicio']),
              onTap: () => Navigator.pushReplacementNamed(context, '/')
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text(Textos[idioma]['como_funciona']),
            onTap: () => Navigator.pushReplacementNamed(context, '/funcionamiento')
          ),
          ListTile(
              leading: Icon(Icons.location_city),
              title: Text(Textos[idioma]['establecimientos']),
              onTap: () => Navigator.pushReplacementNamed(context, '/establecimientos')
          ),
          /*ListTile(
            leading: Icon(Icons.language),
            title: Text(Textos[idioma]['idiomas']),
              onTap: () => Navigator.pushReplacementNamed(context, '/idiomas')
          ),*/
          ListTile(
              leading: Icon(Icons.logout),
              title: Text(logueado ? Textos[idioma]['desconectar'] : Textos[idioma]['desconectado']),
              onTap: () {
                setState(() {
                  logueado = false;
                  campanas = [];
                  campana_activa = 0;
                  prefs.setBool("logueado", logueado);
                });
                Navigator.pushReplacementNamed(context, '/');
              },
              enabled: logueado,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Textos[idioma]['salir']),
              onTap: () => exit(100)
          ),
        ],
      ),
    );
  }
}

Future<void> mostrarDialogo(_contexto, _titulo, _texto, _boton, _funcion) async {
  return showDialog<void>(
    context: _contexto,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(_titulo),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(_texto),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(_boton),
            onPressed: () {

              Navigator.of(context).pop();
              return _funcion;
            },
          ),
        ],
      );
    },
  );
}

Future<dynamic> llamadaAPI(datos) async {
  var httpClient = new HttpClient();
  dynamic respuesta;

  datos['idioma'] = idioma.toString();
  datos['token'] = token;
  datos['dispositivo'] = uuid;

  log(datos.toString());

  Uri uri = new Uri.https('XXXXXX.com', '/lambda/APIBonos', datos);

  try {
    var request = await httpClient.postUrl(uri);
    HttpClientResponse response = await request.close();
    String json_respuesta = await response.transform(new Utf8Decoder()).join();
    respuesta = json.decode(json_respuesta);
    log(respuesta.toString());
  } catch (err) {
    log(err);
    respuesta = "";
  }
  return respuesta;
}