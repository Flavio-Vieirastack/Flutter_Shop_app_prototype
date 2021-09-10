import 'package:brasil_fields/brasil_fields.dart';
import 'package:brasil_fields/formatter/real_input_formatter.dart';
import 'package:brasil_fields/modelos/estados.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_App/models/Anuncio.dart';
import 'package:olx_App/util/Configuracoes.dart';
import 'package:olx_App/view/widgets/InputCustomizado.dart';
import 'package:validadores/validadores.dart';
import 'widgets/BotaoCustomizado.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  final _formKey = GlobalKey<FormState>();

  List<File> _listaImagens = List();
  List<DropdownMenuItem<String>> _listaItensDropEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropCategorias = List();

  Anuncio _anuncio;

  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  BuildContext _dialoContext;

  _selecionarImagemGaleria() async {
    File imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        _listaImagens.add(imagemSelecionada);
      });
    }
  }

  _abirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text("Salvando Anuncio...")
              ],
            ),
          );
        });
  }

  _salvarAnuncio() async {
    _abirDialog(_dialoContext);

    //upload das imagens
    await _uploadImagens();
    //salvar anuncios no firestore

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    String idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    db
        .collection("meus_anuncios")
        .document(idUsuarioLogado)
        .collection("anuncios")
        .document(_anuncio.id)
        .setData(_anuncio.toMap())
        .then((_) {

          //salvar anuncio publico
        db.collection("anuncios")
        .document(_anuncio.id)
        .setData(_anuncio.toMap())
        .then((_) {

      Navigator.pop(_dialoContext);
      Navigator.pop(context);

        });
        

    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

      StorageReference arquivo =
          pastaRaiz.child("meus_anuncios").child(_anuncio.id).child(nomeImagem);

      StorageUploadTask uploadTask = arquivo.putFile(imagem);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropDown();

    _anuncio = Anuncio.gerarId();
  }

  _carregarItensDropDown() {
    //lista categorias
    
    _listaItensDropCategorias = Configuracoes.getCategorias();

    //lista estados
    _listaItensDropEstados = Configuracoes.getEstados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Anúncio'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //area de imagens
                  FormField<List>(
                    initialValue: _listaImagens,
                    validator: (imagens) {
                      if (imagens.length == 0) {
                        return "Necessário selecionar uma imagem";
                      }

                      return null;
                    },
                    builder: (state) {
                      return Column(
                        children: [
                          Container(
                            height: 100,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _listaImagens.length + 1,
                                itemBuilder: (context, indice) {
                                  if (indice == _listaImagens.length) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: GestureDetector(
                                        onTap: () => _selecionarImagemGaleria(),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          radius: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                size: 40,
                                                color: Colors.grey[100],
                                              ),
                                              Text(
                                                "Adicionar",
                                                style: TextStyle(
                                                    color: Colors.grey[100]),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  if (_listaImagens.length > 0) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image.file(
                                                            _listaImagens[
                                                                indice]),
                                                        FlatButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _listaImagens
                                                                  .removeAt(
                                                                      indice);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            });
                                                          },
                                                          child:
                                                              Text("Excluir"),
                                                          textColor: Colors.red,
                                                        )
                                                      ],
                                                    ),
                                                  ));
                                        },
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage:
                                              FileImage(_listaImagens[indice]),
                                          child: Container(
                                            color: Color.fromRGBO(
                                                255, 255, 255, 0.4),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return Container();
                                }),
                          ),
                          if (state.hasError)
                            Container(
                              child: Text(
                                "[${state.errorText}]",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            )
                        ],
                      );
                    },
                  ),
                  //menus drop down
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            value: _itemSelecionadoEstado,
                            validator: (valor) {
                              return Validador()
                                  .add(Validar.OBRIGATORIO,
                                      msg: "Campo obrigatório")
                                  .valido(valor);
                            },
                            hint: Text("Estados"),
                            items: _listaItensDropEstados,
                            onSaved: (estado) {
                              _anuncio.estado = estado;
                            },
                            onChanged: (valor) {
                              setState(() {
                                _itemSelecionadoEstado = valor;
                              });
                            }),
                      )),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            value: _itemSelecionadoCategoria,
                            validator: (valor) {
                              return Validador()
                                  .add(Validar.OBRIGATORIO,
                                      msg: "Campo obrigatório")
                                  .valido(valor);
                            },
                            hint: Text("Categorias"),
                            onSaved: (categoria) {
                              _anuncio.categoria = categoria;
                            },
                            items: _listaItensDropCategorias,
                            onChanged: (valor) {
                              setState(() {
                                _itemSelecionadoCategoria = valor;
                              });
                            }),
                      )),
                    ],
                  ),
                  //caixa de texto e botões
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: InputCustomizado(
                      controller: null,
                      hint: "Título",
                      onSaved: (titulo) {
                        _anuncio.titulo = titulo;
                      },
                      validator: (valor) {
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor);
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: InputCustomizado(
                      controller: null,
                      type: TextInputType.number,
                      hint: "Preço",
                      onSaved: (preco) {
                        _anuncio.preco = preco;
                      },
                      inputFormatrers: [
                        FilteringTextInputFormatter.digitsOnly,
                        RealInputFormatter(centavos: true)
                      ],
                      validator: (valor) {
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor);
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: InputCustomizado(
                      controller: null,
                      type: TextInputType.phone,
                      hint: "Telefone",
                      onSaved: (telefone) {
                        _anuncio.telefone = telefone;
                      },
                      inputFormatrers: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter()
                      ],
                      validator: (valor) {
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor);
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: InputCustomizado(
                      controller: null,
                      maxLines: null,
                      hint: "Descrição",
                      onSaved: (descricao) {
                        _anuncio.descricao = descricao;
                      },
                      validator: (valor) {
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .maxLength(200, msg: "Limite máximo atingido")
                            .valido(valor);
                      },
                    ),
                  ),

                  BotaoCustomizado(
                      texto: "Cadastrar Anúncio",
                      onpressed: () {
                        if (_formKey.currentState.validate()) {
                          //salvar campos
                          _formKey.currentState.save();
                          //configurar dialog
                          _dialoContext = context;
                          //salvar anuncio
                          _salvarAnuncio();
                        }
                      }),
                ],
              )),
        ),
      ),
    );
  }
}
