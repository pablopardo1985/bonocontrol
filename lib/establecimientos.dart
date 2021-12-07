import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Negocio {
  int id;
  String imagen;
  String nombre;
  String direccion;
  String telefono;
  String descripcion;
  String coordenadas;

  Negocio({id, imagen, nombre, direccion, telefono, descripcion, coordenadas}) {
    this.id = id;
    this.imagen = imagen;
    this.nombre = nombre;
    this.direccion = direccion;
    this.telefono = telefono;
    this.descripcion = descripcion;
    this.coordenadas = coordenadas;
  }
}

class Categoria {
  Categoria(id, nombre) {
    this.id = id;
    this.nombre = nombre;
    this.isExpanded = false;
  }

  int id;
  String nombre;
  List<Negocio> negocios = [];
  bool isExpanded;
}

class Establecimientos extends StatefulWidget {
  Establecimientos({Key key}) : super(key: key);

  @override
  _Establecimientos createState() => _Establecimientos();
}

class _Establecimientos extends State<Establecimientos> {
  final controladorBusqueda = TextEditingController();
  List<Categoria> establecimientos = [];
  String args = "";
  String argsUsados = "";

  void initState() {
    super.initState();
    resolverLlamada();
  }

  void resolverLlamada() async {
    log("Hace llamada");
    dynamic respuesta =
        await llamadaAPI({'funcion': 'establecimientos', 'tipo': 'recuperar'});
    establecimientos.clear();
    if (respuesta["estado"] == 1) {
      for (var i = 0; i < respuesta['datos'].length; i++) {
        int hayNegocios = 0;
        final item = respuesta['datos'][i];
        Categoria data_categoria =
            Categoria(item['id'], item['categoria'].toString());
        for (var j = 0; j < item['establecimientos'].length; j++) {
          dynamic item2 = item['establecimientos'][j];
          Negocio data_negocio = Negocio(
              id: item2['id'],
              nombre: item2['nombre'].toString(),
              imagen: item2['imagen'].toString(),
              direccion: item2['direccion'].toString(),
              telefono: item2['telefono'].toString(),
              descripcion: item2['descripcion'].toString(),
              coordenadas: item2['coordenadas'].toString());
          try {
            data_categoria.negocios.add(data_negocio);
            hayNegocios++;
          } catch (ex) {
            log(ex.toString());
          }
        }
        if (hayNegocios > 0) {
          establecimientos.add(data_categoria);
        }
      }
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
    setState(() {});
  }

  Widget generarTarjeta(item) {
    return Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                  item.imagen,
                  fit: BoxFit.cover),
            ),
            Container(
                color: Colors.white70,
                padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 8,
                    bottom: 8),
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      AutoSizeText(
                        item.nombre,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      Container(height: 32),
                      AutoSizeText(
                        item.direccion,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: principal,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      AutoSizeText(
                        item.telefono,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: principal,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      Container(height: 16),
                      AutoSizeText(
                        item.descripcion,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black26,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 4,
                        minFontSize: 18,
                      ),
                      Container(
                          height: 64,
                          padding:
                          const EdgeInsets.only(
                              left: 0,
                              right: 0,
                              top: 16,
                              bottom: 8),
                          alignment:
                          Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/mapa',
                                  arguments:item.id);
                            },
                            child: Container(
                              width: 150,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                      Icons
                                          .pin_drop_sharp,
                                      color:
                                      Colors.white,
                                      size: 20),
                                  AutoSizeText(
                                    Textos[idioma]
                                    ['ver_en_mapa'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight
                                          .normal,
                                    ),
                                    maxLines: 1,
                                  )
                                ],
                              ),
                            ),
                            style: ButtonStyle(
                              foregroundColor:
                              MaterialStateProperty
                                  .all(
                                Colors.white,
                              ),
                              backgroundColor:
                              MaterialStateProperty
                                  .all(principal),
                            ),
                          )),
                    ]))
          ],
        ));
  }

  Widget construirLista(String busqueda) {
    log(busqueda);

    PageController controladorPaginas =
        PageController(initialPage: 0, viewportFraction: 0.9);

    if (busqueda == '') {
      return ListView(children: [
        ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              for (var i = 0; i < establecimientos.length; i++) {
                establecimientos[i].isExpanded = false;
              }
              establecimientos[index].isExpanded = !isExpanded;
            });
          },
          children: establecimientos.map<ExpansionPanel>((Categoria item) {
            return ExpansionPanel(
              backgroundColor: Colors.white70,
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  dense: false,
                  title: AutoSizeText(
                    item.nombre,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                );
              },
              body: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: PageView.builder(
                      controller: controladorPaginas,
                      scrollDirection: Axis.horizontal,
                      itemCount: item.negocios.length,
                      itemBuilder: (BuildContext context, int index) {
                        return item.isExpanded
                            ? generarTarjeta(item.negocios[index])
                            : null;
                      })),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        )
      ]);
    } else {
      List<Negocio> negocios = [];

      for (var i = 0; i < establecimientos.length; i++) {
        for (var j = 0; j < establecimientos[i].negocios.length; j++) {
          if (establecimientos[i]
                  .negocios[j]
                  .nombre
                  .toString()
                  .toLowerCase()
                  .contains(busqueda.toLowerCase()) ||
              establecimientos[i]
                  .negocios[j]
                  .descripcion
                  .toString()
                  .toLowerCase()
                  .contains(busqueda.toLowerCase())) {
            negocios.add(establecimientos[i].negocios[j]);
          }
        }
      }

      return PageView.builder(
          controller: controladorPaginas,
          scrollDirection: Axis.horizontal,
          itemCount: negocios.length,
          itemBuilder: (BuildContext context, int index) {
            return generarTarjeta(negocios[index]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {


    if (args.toString() == "null") {
      args = "";
    }

    args = ModalRoute.of(context).settings.arguments as String;
    if (args != "") {
      if (args != argsUsados) {
        argsUsados = args;
        controladorBusqueda.text = args;
      }
    }



    return Scaffold(
      appBar: BarraAPP(titulo: Textos[idioma]['titulo'], appBar: AppBar()),
      drawer: DrawerAPP(),
      body: Center(
          child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.topCenter,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(2.0),
                        height: 54,
                        child: Row(children: <Widget>[
                          Expanded(
                            flex: 9,
                            child: TextField(
                              obscureText: false,
                              controller: controladorBusqueda,
                              decoration: InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black54),
                                  ),
                                  labelText: Textos[idioma]
                                      ['buscar_establecimiento'],
                                  labelStyle: TextStyle(
                                      fontSize: 18, color: Colors.black54),
                                  focusColor: Colors.black54,
                                  hoverColor: Colors.black54,
                                  fillColor: Colors.black54),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(Icons.search),
                                iconSize: 32.0,
                                color: Colors.black54,
                                onPressed: () {
                                  setState(() {

                                    for (var i = 0;
                                        i < establecimientos.length;
                                        i++) {
                                      establecimientos[i].isExpanded = false;
                                    }
                                  });
                                },
                              ))
                        ])),
                    Expanded(
                        /*padding: const EdgeInsets.all(2.0),
                        alignment: Alignment.topCenter,*/
                        child: construirLista(controladorBusqueda.value.text))
                  ]))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/mapa');
        },
        child: const Icon(Icons.pin_drop),
        backgroundColor: secundario,
      ),
    );
  }
}
