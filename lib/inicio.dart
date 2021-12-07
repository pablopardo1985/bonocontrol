import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';


class Inicio extends StatefulWidget {
  Inicio({Key key }) : super(key: key);

  @override
  _Inicio createState() => _Inicio();
}

class _Inicio extends State<Inicio> {

  final controladorDNI = TextEditingController();
  List<dynamic> bonos = [];

  Future<void> arranque() async {

    log("Primer login: " + primerLogin.toString());
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    userLocation = await location.getLocation();
    location.onLocationChanged().listen((LocationData currentLocation) {
      userLocation = currentLocation;
    });

    try {
      String deviceName;
      String androidVersion;
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        androidVersion = build.version.release.toString();
        var key = utf8.encode(build.androidId);
        var bytes = utf8.encode("scan");
        var hmacSha256 = new Hmac(sha256, key);
        uuid = hmacSha256.convert(bytes).toString();
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        androidVersion = data.systemVersion;
        uuid = data.identifierForVendor; //UUID for iOS
      }
    } catch (err) {
      log("ERROR UUID" + err);
      uuid = "error";
    }

    prefs = await SharedPreferences.getInstance();
    token = await prefs.getString("token");
    bool _logueado = (prefs.getBool("logueado") ?? false);
    if (_logueado && token != "" && !primerLogin) {

      dynamic respuesta = await llamadaAPI({
        'funcion': 'usuarios',
        'tipo': 'validar'
      });

      if (respuesta['estado'] == 1) {
        _logueado = true;
        campanas = respuesta['datos']['campanas'];
        for(var i = 0; i < campanas.length; i++) {
          if (campanas[i]["activa"] == 't') {
            campana_activa = i;
          }
        }
        resolverLlamada();

      }
      else{
        prefs.setString('token', "");
        _logueado = false;
        campanas = [];
        campana_activa = 0;
        mostrarDialogo(context, 'Error de acceso', respuesta["texto"].toString(), 'Cerrar', null);
      }
    }
    else {
      if (primerLogin) {
        primerLogin = false;
        _logueado = true;
        resolverLlamada();
      }
      else {
        _logueado = false;
      }
    }
    log("Logueado Arranque: " + _logueado.toString());
    log("Campañas Arranque: " + campanas.toString());
    log("UUID: " + uuid.toString());
    setState(() { logueado = _logueado; prefs.setBool("logueado", logueado); });
  }

  void initState() {
    arranque();
    super.initState();
  }

  Future<bool> escanear() async {
    var opciones = ScanOptions(
      strings: {
        "cancel": 'Terminar',
        "flash_on": 'Flash on',
        "flash_off": 'Flash off',
      },
      autoEnableFlash: false,
      android: AndroidOptions(
        aspectTolerance: 0.5,
        useAutoFocus: true,
      ),
    );


    try {
      ScanResult barcodeSR = await BarcodeScanner.scan(options: opciones);
      if (barcodeSR.type.toString() == 'Barcode') {

        token = "";

        dynamic respuesta = await llamadaAPI({
          'funcion': 'usuarios',
          'codigo': barcodeSR.rawContent,
          'dni': controladorDNI.text,
          'tipo': 'login_cliente'
        });

        if (respuesta["estado"] == 1) {

            logueado = true;
            token = respuesta['datos']['token'];
            campanas = respuesta['datos']['campanas'];
            for(var i = 0; i < campanas.length; i++) {
              if (campanas[i]["activa"] == 't') {
                campana_activa = i;
              }
            }
            primerLogin = true;
            prefs.setBool("logueado", logueado);
            prefs.setString("token", token);
            Navigator.pushReplacementNamed(context, '/');
        }
        else {
            logueado = false;
            token = "";
            campanas = [];
            primerLogin = false;
            prefs.setBool("logueado", logueado);
            prefs.setString("token", token);
            Navigator.pushReplacementNamed(context, '/');
        }

      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          //Error de permisos
        });
      } else {
        //Error desconocido
      }
    } on FormatException catch (e) {
      if (e.toString() != 'FormatException: Invalid envelope') {
        //Error accediendo a la camara
      }
    } catch (e) {
      //Error escaneando
    }

    log("UUID Login: " + uuid.toString());
    log("TOKEN Login: " + token.toString());
    log("Logueado Login: " + logueado.toString());
    log("Campañas Login: " + campanas.toString());
    setState(() {});
  }

  Future<void> resolverLlamada() async {
    dynamic respuesta = await llamadaAPI({
      'funcion': 'bonos_cliente',
      'tipo': 'recuperar'
    });

    if (respuesta["estado"] == 1) {
        setState(() {
          bonos = respuesta["datos"];
        });
    }
    else {
      mostrarDialogo(context, 'Error al obtener datos', respuesta["texto"].toString(), 'Cerrar', null);
      setState(() {
        logueado = false;
        token = "";
        prefs.setBool("logueado", logueado);
        prefs.setString("token", token);
      });
    }
  }

  Widget construirLista() {
    return bonos.length != 0
        ? RefreshIndicator(
      child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: bonos.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shadowColor:  bonos[index]['estado'] == "1" ? Colors.green : Colors.redAccent,
              elevation: 4,
              semanticContainer: false,
              child: Column(
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints.expand(height: 32),
                    color: bonos[index]['estado'] == "1" ? Colors.green : Colors.redAccent,
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 100),
                    padding: EdgeInsets.all(8),
                    color: Colors.grey.shade100,
                    child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    padding: EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
                                    child: QrImage(
                                      data: bonos[index]['qr'],
                                      foregroundColor:  bonos[index]['estado'] == "1" ? Colors.black : Colors.redAccent,
                                      version: QrVersions.auto,
                                      errorCorrectionLevel: QrErrorCorrectLevel.Q,
                                      size: 80.0,
                                    )
                                ),
                                flex: 3,
                              ),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, top: 0, right:8, bottom: 0),
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    AutoSizeText(
                                      bonos[index]['estado'] == "1" ? Textos[idioma]['disponible'].toUpperCase() : Textos[idioma]['usado'].toUpperCase(),
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: bonos[index]['estado'] == "1" ? Colors.green : Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                        height:4
                                    ),
                                    AutoSizeText(
                                      bonos[index]['establecimiento'].toString() != 'null' ? bonos[index]['establecimiento'].toString() : '',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,

                                      ),
                                    ),
                                    Container(
                                      height:4
                                    ),
                                    AutoSizeText(
                                      bonos[index]['estado'] == "1" ? '' : Textos[idioma]['fecha_escaneo'] + " " + bonos[index]['fecha_escaneo'] + " " + bonos[index]['hora_escaneo'],
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: bonos[index]['estado'] == "1" ? Colors.green : Colors.redAccent,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            )
                          ],
                        ),
                        Container(
                          height:16
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 24, right: 16, top: 8, bottom: 8),
                          color: Colors.white,
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    bonos[index]['nombre'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                Textos[idioma]['valor'] + " " + bonos[index]['importe'].toString() + " €",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                  height:4
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      child: AutoSizeText(
                                        Textos[idioma]['canjear'].toUpperCase(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: principal,
                                            letterSpacing: -0.8,
                                            fontWeight: FontWeight.bold
                                        ),
                                        maxLines: 1,
                                      ),
                                      onTap: () => {
                                        Navigator.pushReplacementNamed(context, '/establecimientos')
                                      },
                                    ),

                                  ]
                              )
                            ]
                          )
                        ),
                      ]
                    )
                  ),
                ],
              ),
            );
          }),
      onRefresh: resolverLlamada,
    )
        : Center(child: CircularProgressIndicator());
  }

  Widget componerCuerpo(BuildContext context) {

    if (logueado) {
      return Container(
        margin: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: construirLista()

        );
    }
    else {
      return Container(
          margin: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
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
              Text(
                Textos[idioma]['introduzcadni'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.left,
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                alignment: Alignment.topLeft,
              ),
              Text(
                Textos[idioma]['escaneeqr'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.left,
              ),
              Container(
                margin: const EdgeInsets.all(40.0),
                alignment: Alignment.topLeft,
              ),
              TextField(
                obscureText: false,
                controller: controladorDNI,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    labelText: Textos[idioma]['dni'],
                    helperText: Textos[idioma]['introduzcadatos'],
                    helperStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.black54
                    ),
                    labelStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.black54
                    ),
                    hintStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.black54
                    ),
                    focusColor: Colors.black54,
                    hoverColor: Colors.black54,
                    fillColor: Colors.black54
                ),
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
              Container(
                  alignment: Alignment.bottomRight,
                  height: 80,
                  child: ElevatedButton(
                      child: Text(Textos[idioma]['escanear']),
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

                      onPressed: () async => { await escanear() }
                  )
              )
            ],
          )
      );
    }
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
        child: componerCuerpo(context)
      )
    );
  }
}
