class Usuario {
  String _idusuario;
  String _nome;
  String _email;
  String _senha;

  String get idusuario => this._idusuario;

  set idusuario(String value) => this._idusuario = value;

  get nome => this._nome;

  set nome(value) => this._nome = value;

  get email => this._email;

  set email(value) => this._email = value;

  get senha => this._senha;

  set senha(value) => this._senha = value;

  Usuario();

  Map<String, dynamic> toMap() {
    
    Map<String, dynamic> map = {

      "idUsuario": this.idusuario,
      "nome"     : this.nome,
      "email"    : this.email
    };
    return map;
  }
}
