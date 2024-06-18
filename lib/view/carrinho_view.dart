import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarrinhoView extends StatelessWidget {
  final List<String> carrinho;

  const CarrinhoView({Key? key, required this.carrinho}) : super(key: key);

  void removeFromCart(String product, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // Remove o produto do Firestore para o usuário atual
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrinho')
          .where('product', isEqualTo: product)
          .limit(1)
          .get();

      querySnapshot.docs.first.reference.delete();

      // Remove o produto do carrinho localmente
      carrinho.remove(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto removido do carrinho: $product')),
      );
    } catch (e) {
      print('Erro ao remover produto do carrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover produto do carrinho.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de Compras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens no Carrinho:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: carrinho.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(carrinho[index]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      String removedProduct = carrinho[index];
                      removeFromCart(removedProduct, context);
                    },
                    child: ListTile(
                      title: Text(carrinho[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
