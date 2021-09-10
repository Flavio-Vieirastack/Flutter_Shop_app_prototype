import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio {
  String _id;
  String _estado;
  String _categoria;
  String _titulo;
  String _preco;
  String _telefone;
  String _descricao;
  
  List<dynamic> _fotos;

  String get id => this._id;

  set id(String value) => this._id = value;

  get estado => this._estado;

  set estado(value) => this._estado = value;

  get categoria => this._categoria;

  set categoria(value) => this._categoria = value;

  get titulo => this._titulo;

  set titulo(value) => this._titulo = value;

  get preco => this._preco;

  set preco(value) => this._preco = value;

  get telefone => this._telefone;

  set telefone(value) => this._telefone = value;

  get descricao => this._descricao;

  set descricao(value) => this._descricao = value;

  get fotos => this._fotos;

  set fotos(value) => this._fotos = value;

  Anuncio();

  Anuncio.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    this.id = documentSnapshot.documentID;
    this.estado = documentSnapshot["estado"];
    this.categoria = documentSnapshot["categoria"];
    this.titulo = documentSnapshot["titulo"];
    this.preco = documentSnapshot["preco"];
    this.telefone = documentSnapshot["telefone"];
    this.descricao = documentSnapshot["descricao"];
    this.fotos = List<String>.from(documentSnapshot["fotos"]);
  }

  Anuncio.gerarId() {
    Firestore db = Firestore.instance;
    CollectionReference anuncios = db.collection("meus_anuncios");
    this.id = anuncios.document().documentID;

    this.fotos = [];
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": this.id,
      "estado": this.estado,
      "categoria": this.categoria,
      "titulo": this.titulo,
      "preco": this.preco,
      "telefone": this.telefone,
      "descricao": this.descricao,
      "fotos": this.fotos
    };
    return map;
  }
}
