import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RacoesAvesView extends StatefulWidget {
  @override
  _RacoesAvesViewState createState() => _RacoesAvesViewState();
}

class _RacoesAvesViewState extends State<RacoesAvesView> {
  late List<String> carrinhoIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rações para Aves'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('produtos')
            .where('categoria', isEqualTo: 'Raçoes')
            .where('tipo', isEqualTo: 'Ave')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum produto encontrado.'));
          }

          var produtos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              var produto = produtos[index];
              return ListTile(
                leading: produto['imagemUrl'] != null
                    ? Image.network(produto['imagemUrl'], width: 50, height: 50)
                    : Icon(Icons.image, size: 50),
                title: Text(produto['nome']),
                subtitle: Text('R\$ ${produto['preco']}'),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () => addToCart(context, produto.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void addToCart(BuildContext context, String productId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado. Faça o login para adicionar ao carrinho.')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('carrinho')
          .add({'productId': productId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto adicionado ao carrinho.')),
      );
    } catch (e) {
      print('Erro ao adicionar produto ao carrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar produto ao carrinho.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCarrinhoIds();
  }

  void getCarrinhoIds() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var carrinhoSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('carrinho')
            .get();

        setState(() {
          carrinhoIds = carrinhoSnapshot.docs
              .map((doc) => doc.data())
              .where((data) => data.containsKey('productId'))
              .map((data) => data['productId'] as String)
              .toList();
        });
      }
    } catch (e) {
      print('Erro ao obter produtos do carrinho: $e');
    }
  }
}
