import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  
  // Método para criar uma conta de usuário no Firebase Authentication
  void criarConta(BuildContext context, String nome, String email, String senha, String cpf, String telefone) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: senha,
    )
        .then((resultado) {
      // Usuário criado com sucesso!
      // Armazenar o nome, CPF, telefone e UID do usuário no Firestore
      FirebaseFirestore.instance
          .collection("usuarios")
          .doc(resultado.user!.uid)
          .set(
        {
          "uid": resultado.user!.uid,
          "nome": nome,
          "email": email,
          "cpf": cpf,
          "telefone": telefone,
        },
      );
      sucesso(context, 'Usuário criado com sucesso!');
      Navigator.pop(context);
    }).catchError((e) {
      // Erro durante a criação do usuário
      switch (e.code) {
        case 'email-already-in-use':
          erro(context, 'O email já foi cadastrado.');
          break;
        case 'invalid-email':
          erro(context, 'O formato do e-mail é inválido.');
          break;
        default:
          erro(context, 'ERRO: ${e.toString()}');
      }
    });
  }

  // Método para realizar o login de usuário utilizando email/senha
  void login(BuildContext context, String email, String senha) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((resultado) {
      sucesso(context, 'Usuário autenticado com sucesso!');
      Navigator.pushNamed(context, 'principal');
    }).catchError((e) {
      switch (e.code) {
        case 'invalid-email':
          erro(context, 'O formato do e-mail é inválido.');
          break;
        case 'wrong-password':
          erro(context, 'Senha incorreta.');
          break;
        case 'user-not-found':
          erro(context, 'Usuário não encontrado.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  // Método para enviar email de redefinição de senha
  void esqueceuSenha(BuildContext context, String email) {
    if (email.isNotEmpty) {
      FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
      sucesso(context, 'Email enviado com sucesso.');
    } else {
      erro(context, 'Informe o email para recuperar a conta.');
    }
  }

  // Método para efetuar logout do usuário
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  // Método para obter o UID do usuário atualmente logado
  String idUsuarioLogado() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  // Método assíncrono para obter as informações do usuário logado
  Future<Map<String, String>> getUsuarioLogado() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      String nome = snapshot['nome'] ?? 'Nome não disponível';
      String email = user.email ?? 'Email não disponível';

      return {
        'nome': nome,
        'email': email,
      };
    } else {
      throw Exception('Nenhum usuário logado.');
    }
  }

  // Método para atualizar os dados do usuário (nome, email e senha)
  Future<void> atualizarDadosUsuario(BuildContext context, String nome, String email, String senha) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Atualizar email
      if (email.isNotEmpty) {
        await user.updateEmail(email);
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
          'email': email,
        });
      }

      // Atualizar nome
      if (nome.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
          'nome': nome,
        });
      }

      // Atualizar senha
      if (senha.isNotEmpty) {
        await user.updatePassword(senha);
      }

      sucesso(context, 'Dados atualizados com sucesso!');
    } else {
      throw Exception('Nenhum usuário logado.');
    }
  }

  // Método privado para exibir uma mensagem de sucesso
  void sucesso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // Método privado para exibir uma mensagem de erro
  void erro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }
}
