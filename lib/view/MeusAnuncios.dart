import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_App/models/Anuncio.dart';
import 'package:olx_App/view/widgets/ItemAnuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  var carregandoDados = Center(
    child: Column(
      children: [Text("Carregando anuncios..."), CircularProgressIndicator()],
    ),
  );

  _recuperarDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncio() async {
    await _recuperarDadosUsuarioLogado();
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .document(_idUsuarioLogado)
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

    return null;
  }

  _removerAnuncio(String idAnuncio) {
    Firestore db = Firestore.instance;
    db
        .collection("meus_anuncios")
        .document(_idUsuarioLogado)
        .collection("anuncios")
        .document(idAnuncio)
        .delete().then((value) {
          db.collection("anuncios")
          .document(idAnuncio)
          .delete();
        });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Meus Anúncios'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            foregroundColor: Colors.white,
            icon: Icon(Icons.add),
            label: Text("Adicionar"),
            onPressed: () {
              Navigator.popAndPushNamed(context, "/novo-anuncio");
            }),
        body: StreamBuilder(
            stream: _controller.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return carregandoDados;
                  break;
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) return Text("Erro ao carregar dados");

                  QuerySnapshot querySnapshot = snapshot.data;

                  return ListView.builder(
                      itemCount: querySnapshot.documents.length,
                      itemBuilder: (_, indice) {
                        List<DocumentSnapshot> anuncios =
                            querySnapshot.documents.toList();
                        DocumentSnapshot documentSnapshot = anuncios[indice];

                        Anuncio anuncio =
                            Anuncio.fromDocumentSnapshot(documentSnapshot);

                        return ItemAnuncio(
                          anuncio: anuncio,
                          onPressedRemover: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Confirmar"),
                                    content: Text(
                                        "Deseja realmente excluir este Anúncio?"),
                                    actions: [
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Canelar",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )),
                                      FlatButton(
                                          color: Colors.red,
                                          onPressed: () {
                                            _removerAnuncio(anuncio.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Remover",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))
                                    ],
                                  );
                                });
                          },
                        );
                      });
              }

              return null;
            }));
  }
}
