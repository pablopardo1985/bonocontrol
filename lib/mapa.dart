import 'dart:developer';
import 'dart:ui';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  Mapa({Key key }) : super(key: key);

  @override
  _Mapa createState() => _Mapa();
}



class _Mapa extends State<Mapa> {

  final controladorBusqueda = TextEditingController();
  int args = -1;
  Completer<GoogleMapController> controladorMapa = Completer();
  GoogleMapController controller;
  Set<Marker> establecimientos = <Marker>{};
  BitmapDescriptor marcador;


  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(32, 32)), 'assets/mappin.png').then((d) {
      marcador = d;
    });
    resolverLlamada();

  }

  CameraPosition MyCamara = CameraPosition(
      bearing: 0,
      target: LatLng(userLocation.latitude, userLocation.longitude),
      tilt: 0,
      zoom: 18
  );

  void resolverLlamada() async {
    log("Hace llamada");
    dynamic respuesta = await llamadaAPI({
      'funcion': 'establecimientos',
      'tipo': 'recuperar'
    });
    establecimientos.clear();
    if (respuesta["estado"] == 1) {
      for(var i = 0; i < respuesta['datos'].length; i++) {
        int hayNegocios = 0;
        final item = respuesta['datos'][i];
        for(var j = 0; j < item['establecimientos'].length; j++) {
          dynamic item2 = item['establecimientos'][j];

          Marker negocio = new Marker(
            position: LatLng.fromJson(item2['coordenadas']),
            draggable: false,
            markerId: MarkerId(item2['id'].toString()),
            icon: marcador,
            visible: true,
            infoWindow: InfoWindow(
              title: item2['nombre'].toString(),
              snippet: item2['direccion'].toString(),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, '/establecimientos',
                    arguments:item2['nombre']);
              }

            ),
            flat: true,
            onTap: () {

            }
          );


          try {
            establecimientos.add(negocio);
            hayNegocios++;
          }
          catch (ex) {
            log(ex.toString());
          }
        }
      }

    }
    else {
      Navigator.pushReplacementNamed(context, '/');
    }

    if (args != -1) {
      for(var i = 0; i < establecimientos.length; i++) {
        if (establecimientos.elementAt(i).markerId == MarkerId(args.toString())) {
          CameraUpdate camaraMarker = CameraUpdate.newCameraPosition(CameraPosition(target: establecimientos.elementAt(i).position, zoom: 20));
          controller.animateCamera(camaraMarker);
        }
      }
    }

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    args = ModalRoute.of(context).settings.arguments as int;


    return Scaffold(
      appBar: BarraAPP(
          titulo: Textos[idioma]['titulo'],
          appBar: AppBar()
      ),
      drawer: DrawerAPP(),
      body: Center(
          child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.topCenter,
              child: GoogleMap(
                initialCameraPosition: MyCamara,
                markers: establecimientos,
                mapType: MapType.normal,
                liteModeEnabled: false,
                mapToolbarEnabled: false,
                indoorViewEnabled: false,
                myLocationEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (control) async {
                  controladorMapa.complete(control);
                  controller = await controladorMapa.future;

                  if (args != -1) {
                    for(var i = 0; i < establecimientos.length; i++) {
                      if (establecimientos.elementAt(i).markerId == MarkerId(args.toString())) {
                        CameraUpdate camaraMarker = CameraUpdate.newCameraPosition(CameraPosition(target: establecimientos.elementAt(i).position, zoom: 20));
                        controller.animateCamera(camaraMarker);
                      }
                    }
                  }
                },
              )
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/establecimientos');
        },
        child: const Icon(Icons.list_alt),
        backgroundColor: secundario,
      ),
    );
  }
}
