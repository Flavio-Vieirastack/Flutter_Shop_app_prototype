import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx_App/models/Anuncio.dart';
import 'package:olx_App/util/Configuracoes.dart';
import 'package:olx_App/view/widgets/ItemAnuncio.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  List<String> itensMenu = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias;
  List<DropdownMenuItem<String>> _listaItensDropEstados;
  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  var _carregandoDados = Center(
    child: Column(
      children: [CircularProgressIndicator(), Text("Carregando...")],
    ),
  );

  final _controller = StreamController<QuerySnapshot>.broadcast();

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Meus Anúncios":
        Navigator.pushNamed(context, "/meus-anuncios");

        break;

      case "Entrar/Cadastrar":
        Navigator.pushNamed(context, "/loguin");

        break;

      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut().then((_) {
      //Navigator.pushReplacementNamed(context, "/meus-anuncios");
    });

    
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado == null) {
      setState(() {
        itensMenu = ["Entrar/Cadastrar"];
      });
    } else {
      setState(() {
        itensMenu = ["Meus Anúncios", "Deslogar"];
      });
    }
  }

  _carregarItensDropDown() {
    //lista categorias

    _listaItensDropCategorias = Configuracoes.getCategorias();

    //lista estados
    _listaItensDropEstados = Configuracoes.getEstados();
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios").snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

    return null;
  }

  Future<Stream<QuerySnapshot>> _filtrarAnuncios() async {
    Firestore db = Firestore.instance;
    Query query = db.collection("anuncios");

    if (_itemSelecionadoEstado != null) {
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }

    if (_itemSelecionadoCategoria != null) {
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

    
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropDown();
    _verificaUsuarioLogado();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My ShopApp"),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem<String>(value: item, child: Text(item));
                }).toList();
              })
        ],
      ),
      body: Container(
        child: Column(
          children: [
            //filtros
            Row(
              children: [
                Expanded(
                    child: DropdownButtonHideUnderline(
                        child: Center(
                  child: DropdownButton(
                      iconEnabledColor: Color(0xff9c27b0),
                      value: _itemSelecionadoEstado,
                      items: _listaItensDropEstados,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                      onChanged: (estado) {
                        setState(() {
                          _itemSelecionadoEstado = estado;
                          _filtrarAnuncios();
                        });
                      }),
                ))),
                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 60,
                ),
                Expanded(
                    child: DropdownButtonHideUnderline(
                        child: Center(
                  child: DropdownButton(
                      iconEnabledColor: Color(0xff9c27b0),
                      value: _itemSelecionadoCategoria,
                      items: _listaItensDropCategorias,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                      onChanged: (categoria) {
                        setState(() {
                          _itemSelecionadoCategoria = categoria;
                          _filtrarAnuncios();
                        });
                      }),
                )))
              ],
            ),
            //lista de anuncios
            StreamBuilder(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return _carregandoDados;
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      QuerySnapshot querySnapshot = snapshot.data;

                      if (querySnapshot.documents.length == 0) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "Nenhum Anuncio :(",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return Expanded(
                          child: ListView.builder(
                              itemCount: querySnapshot.documents.length,
                              itemBuilder: (_, indice) {
                                List<DocumentSnapshot> anuncios =
                                    querySnapshot.documents.toList();
                                DocumentSnapshot documentSnapshot =
                                    anuncios[indice];

                                Anuncio anuncio = Anuncio.fromDocumentSnapshot(
                                    documentSnapshot);

                                return ItemAnuncio(
                                  anuncio: anuncio,
                                  onTapItem: () {
                                    Navigator.pushNamed(
                                        context, "/detalhes-anuncio",
                                        arguments: anuncio);
                                  },
                                );
                              }));
                  }
                  return Container();
                })
          ],
        ),
      ),
    );
  }
}
