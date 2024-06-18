import 'package:flutter/material.dart';
import '../controller/login_controller.dart';

class GerenciarCadastro extends StatefulWidget {
  const GerenciarCadastro({Key? key}) : super(key: key);

  @override
  _GerenciarCadastroState createState() => _GerenciarCadastroState();
}

class _GerenciarCadastroState extends State<GerenciarCadastro> {
  late Future<Map<String, String>> _usuarioLogado;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

 
@override
  void initState() {
    super.initState();
    _usuarioLogado = LoginController().getUsuarioLogado();
    _usuarioLogado.then((usuario) {
      _nomeController.text = usuario['nome']!;
      _emailController.text = usuario['email']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Cadastro'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _usuarioLogado,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar dados do usuário.'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('Nenhum dado encontrado para o usuário.'),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nova Senha',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _senhaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua nova senha';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _atualizarDadosUsuario(context);
                        }
                      },
                      child: Text('Salvar'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _atualizarDadosUsuario(BuildContext context) {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String senha = _senhaController.text;

    LoginController().atualizarDadosUsuario(context, nome, email, senha).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
      setState(() {
        _usuarioLogado = LoginController().getUsuarioLogado();
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar dados: $e')),
      );
    });
  }
}
