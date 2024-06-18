import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrincipalController {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> addToCart(String product) async {
    try {
      // Adicionar produto ao carrinho local (opcional)
      // Se você já está usando carrinho local em _PrincipalViewState, pode não precisar disso.
      // Para simplificação, vamos adicionar diretamente ao Firestore.

      // Adicionar produto ao Firestore para o usuário atual
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrinho')
          .add({'product': product});

      // Você pode adicionar mais lógica aqui, como exibir uma mensagem de sucesso.
    } catch (e) {
      print('Erro ao adicionar produto ao carrinho: $e');
      // Tratar erros, se necessário
    }
  }
}
