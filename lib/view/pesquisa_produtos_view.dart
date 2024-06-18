import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto02app/controller/principal_controller.dart';

class PesquisaProdutosView extends StatefulWidget {
  @override
  _PesquisaProdutosViewState createState() => _PesquisaProdutosViewState();
}

class _PesquisaProdutosViewState extends State<PesquisaProdutosView> {
  late TextEditingController _controller;
  List<String> produtosEncontrados = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void pesquisarProdutos(String query) async {
    try {
      // Limpar a lista de produtos encontrados antes de pesquisar novamente
      setState(() {
        produtosEncontrados.clear();
      });

      // Realizar a pesquisa no Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('produtos')
          .where('nome', isGreaterThanOrEqualTo: query)
          .where('nome', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      setState(() {
        produtosEncontrados =
            querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
      });
    } catch (e) {
      print('Erro ao pesquisar produtos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar Produtos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Digite o nome do produto',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    pesquisarProdutos(_controller.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: produtosEncontrados.length,
                itemBuilder: (context, index) {
                  String produto = produtosEncontrados[index];
                  return ListTile(
                    title: Text(produto),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        PrincipalController().addToCart(produto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Produto adicionado ao carrinho: $produto')),
                        );
                      },
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
