import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto02app/view/agendamento_hotel_view.dart';
import 'package:projeto02app/view/ver_agendamentos_hotel_view.dart';
import '../controller/login_controller.dart';
import 'cadastrar_view.dart'; // Import da tela de cadastro
import 'sobre_view.dart'; // Import da tela de sobre
import 'racoes_cachorros_view.dart'; // Import da página de rações para cachorros
import 'petiscos_gatos_view.dart'; // Import da tela de petiscos para gatos
import 'racoes_aves_view.dart'; // Import da página de rações para aves
import 'carrinho_view.dart'; // Import da tela de carrinho de compras
import 'pesquisa_produtos_view.dart'; // Import da tela de pesquisa de produtos

// Nova importação para a tela de agendamento
import 'agendamento_banho_tosa_view.dart';
import 'agendamento_veterinario_view.dart';
//import 'veterinario_view.dart'; // Import da tela de veterinário

class PrincipalView extends StatefulWidget {
  const PrincipalView({Key? key}) : super(key: key);

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  final List<String> imgList = [
    'assets/images/promo1.jpg',
    'assets/images/promo2.jpg',
    'assets/images/promo3.jpg',
  ];

  List<String> carrinho = []; // Lista de produtos no carrinho
  late User? user; // Usuário logado

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    loadCartItems(); // Carregar itens do carrinho ao iniciar
  }

  void loadCartItems() async {
    try {
      // Carregar itens do carrinho do Firestore para o usuário atual
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrinho')
          .get();

      setState(() {
        carrinho = querySnapshot.docs.map((doc) => doc['product'] as String).toList();
      });
    } catch (e) {
      print('Erro ao carregar itens do carrinho: $e');
    }
  }

  void addToCart(String product) async {
    try {
      // Recuperar o usuário atualmente logado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado. Faça o login para adicionar ao carrinho.')),
        );
        return;
      }

      // Adicionar produto ao Firestore para o usuário atual
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('carrinho')
          .add({'product': product});

      // Atualizar localmente e na interface após adicionar ao carrinho
      setState(() {
        carrinho.add(product);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto adicionado ao carrinho: $product')),
      );
    } catch (e) {
      print('Erro ao adicionar produto ao carrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar produto ao carrinho.')),
      );
    }
  }

  void removeFromCart(String product) async {
    try {
      // Remover produto do carrinho local
      setState(() {
        carrinho.remove(product);
      });

      // Remover produto do Firestore para o usuário atual
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrinho')
          .where('product', isEqualTo: product)
          .limit(1)
          .get();

      querySnapshot.docs.first.reference.delete();

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
        title: Image.asset('assets/images/logo.png', height: 40),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PesquisaProdutosView()));
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            tooltip: 'Carrinho',
            onPressed: () {
              if (carrinho.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('O carrinho está vazio.')),
                );
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CarrinhoView(carrinho: carrinho))).then((_) {
                  // Atualiza a lista de itens do carrinho quando retornar da tela de carrinho
                  loadCartItems();
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            tooltip: 'Perfil',
            onPressed: () async {
              // Carregar informações do usuário logado antes de navegar para a tela de perfil
              try {
                Map<String, String> userData = await LoginController().getUsuarioLogado();
                Navigator.pushNamed(context, 'gerenciar', arguments: userData);
              } catch (e) {
                print('Erro ao carregar informações do usuário: $e');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () {
              // Adicionar funcionalidade de logout
              LoginController().logout();
              Navigator.pushNamed(context, 'login');
            },
          ),
          IconButton(
            icon: Icon(Icons.event),
            tooltip: 'Agendar Banho e Tosa',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentoBanhoTosaView()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrossel de Imagens
            CarouselSlider(
              options: CarouselOptions(height: 200.0, autoPlay: true),
              items: imgList.map((item) => Image.asset(item, fit: BoxFit.cover)).toList(),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categorias
                  Text('Categorias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        categoryItem('Cachorros', Icons.pets, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RacoesCachorrosView()));
                        }),
                        categoryItem('Gatos', Icons.category, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PetiscosGatosView()));
                        }),
                        categoryItem('Aves', Icons.air, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RacoesAvesView()));
                        }),
                       // categoryItem('Peixes', Icons.pool, () {
                          // Implementar navegação para Peixes
                       // }),
                        //categoryItem('Serviços', Icons.room_service, () {
                          // Implementar navegação para Serviços
                       // }),
                      ],
                    ),
                  ),

                  // Produtos em Destaque
                  SizedBox(height: 20),
                  Text('Produtos em Destaque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  productList(),

                  // Serviços
                  SizedBox(height: 20),
                  Text('Serviços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  serviceList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryItem(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        child: Container(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40),
              SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget productList() {
    return Column(
      children: [
        productItem('Ração para Cachorros', 'assets/images/produto1.jpg', 'R\$ 50,00'),
        productItem('Brinquedo para Gatos', 'assets/images/produto2.jpg', 'R\$ 20,00'),
        productItem('Aquário Completo', 'assets/images/produto3.jpg', 'R\$ 200,00'),
      ],
    );
  }

  Widget productItem(String title, String imagePath, String price) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(title),
        subtitle: Text(price),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: () {
            // Adicionar produto ao carrinho
            addToCart(title);
          },
        ),
      ),
    );
  }

Widget serviceList() {
  return Column(
    children: [
      serviceItem('Banho e Tosa', Icons.room_service, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentoBanhoTosaView()));
      }),
      serviceItem('Veterinário', Icons.local_hospital, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VeterinarioView()));
      }),
      serviceItem('Hotel para Pets', Icons.hotel, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentoHotelView()));
      }),
    ],
  );
}


  Widget serviceItem(String title, IconData icon, VoidCallback onPressed) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        onTap: onPressed,
      ),
    );
  }
}

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
        produtosEncontrados = querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
      });
    } catch (e) {
      print('Erro ao pesquisar produtos: $e');
    }
  }

  void addToCart(String product) async {
    try {
      // Recuperar o usuário atualmente logado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado. Faça o login para adicionar ao carrinho.')),
        );
        return;
      }

      // Adicionar produto ao Firestore para o usuário atual
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('carrinho')
          .add({'product': product});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto adicionado ao carrinho: $product')),
      );
    } catch (e) {
      print('Erro ao adicionar produto ao carrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar produto ao carrinho.')),
      );
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
                  return ListTile(
                    title: Text(produtosEncontrados[index]),
                    onTap: () {
                      // Adicionar produto ao carrinho ao ser selecionado
                      addToCart(produtosEncontrados[index]);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Oculta a SnackBar atual
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produto adicionado ao carrinho: ${produtosEncontrados[index]}')),
                      );
                    },
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

class AgendamentoBanhoTosaView extends StatefulWidget {
  @override
  _AgendamentoBanhoTosaViewState createState() => _AgendamentoBanhoTosaViewState();
}

class _AgendamentoBanhoTosaViewState extends State<AgendamentoBanhoTosaView> {
  final _formKey = GlobalKey<FormState>();
  String _nomePet = '';
  String _porte = 'Pequeno';
  String _tipoPet = 'Cachorro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Banho e Tosa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Pet'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do pet';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nomePet = value!;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Porte do Pet'),
                value: _porte,
                items: ['Pequeno', 'Médio', 'Grande'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _porte = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Tipo de Pet'),
                value: _tipoPet,
                items: ['Cachorro', 'Gato'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoPet = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _agendarBanhoETosa();
                  }
                },
                child: Text('Agendar'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VerAgendamentosView()));
                },
                child: Text('Ver Agendamentos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agendarBanhoETosa() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado. Faça o login para agendar.')),
        );
        return;
      }

      // Adicionar agendamento ao Firestore para o usuário atual
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('agendamentos')
          .add({
        'nomePet': _nomePet,
        'porte': _porte,
        'tipoPet': _tipoPet,
        'dataAgendamento': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento realizado com sucesso para $_nomePet')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erro ao agendar banho e tosa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar banho e tosa.')),
      );
    }
  }
}

class AgendamentoVeterinarioView extends StatefulWidget {
  @override
  _AgendamentoVeterinarioViewState createState() => _AgendamentoVeterinarioViewState();
}

class _AgendamentoVeterinarioViewState extends State<AgendamentoVeterinarioView> {
  final _formKey = GlobalKey<FormState>();
  String _nomePet = '';
  String _motivoConsulta = '';
  String _dataPreferencial = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Veterinário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Pet'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do pet';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nomePet = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Motivo da Consulta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o motivo da consulta';
                  }
                  return null;
                },
                onSaved: (value) {
                  _motivoConsulta = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Data Preferencial'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data preferencial';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dataPreferencial = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _agendarVeterinario();
                  }
                },
                child: Text('Agendar'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VerAgendamentosView()));
                },
                child: Text('Ver Agendamentos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agendarVeterinario() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado. Faça o login para agendar.')),
        );
        return;
      }

      // Adicionar agendamento ao Firestore para o usuário atual
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('agendamentos')
          .add({
        'nomePet': _nomePet,
        'motivoConsulta': _motivoConsulta,
        'dataPreferencial': _dataPreferencial,
        'tipoConsulta': 'Veterinário', // Adicione outros campos específicos do agendamento de veterinário aqui
        'dataAgendamento': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento realizado com sucesso para $_nomePet')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erro ao agendar veterinário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar veterinário.')),
      );
    }
  }
}

class VerAgendamentosView extends StatefulWidget {
  @override
  _VerAgendamentosViewState createState() => _VerAgendamentosViewState();
}

class _VerAgendamentosViewState extends State<VerAgendamentosView> {
  late User? user;
  List<Map<String, dynamic>> agendamentos = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    loadAgendamentos();
  }

  void loadAgendamentos() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('agendamentos')
          .orderBy('dataAgendamento', descending: true)
          .get();

      setState(() {
        agendamentos = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Erro ao carregar agendamentos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Agendamentos'),
      ),
      body: ListView.builder(
        itemCount: agendamentos.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.event),
              title: Text('Agendamento para ${agendamentos[index]['nomePet']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo: ${agendamentos[index]['tipoPet']}'),
                  Text('Porte: ${agendamentos[index]['porte']}'),
                  Text('Data: ${_formatDate(agendamentos[index]['dataAgendamento'])}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class VeterinarioView extends StatefulWidget {
  @override
  _VeterinarioViewState createState() => _VeterinarioViewState();
}

class _VeterinarioViewState extends State<VeterinarioView> {
  final _formKey = GlobalKey<FormState>();
  String _nomePet = '';
  String _motivoConsulta = '';
  String _dataPreferencial = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Veterinário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Pet'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do pet';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nomePet = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Motivo da Consulta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o motivo da consulta';
                  }
                  return null;
                },
                onSaved: (value) {
                  _motivoConsulta = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Data Preferencial'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data preferencial';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dataPreferencial = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _agendarVeterinario();
                  }
                },
                child: Text('Agendar'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VerAgendamentosView()));
                },
                child: Text('Ver Agendamentos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agendarVeterinario() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado. Faça o login para agendar.')),
        );
        return;
      }

      // Adicionar agendamento ao Firestore para o usuário atual
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('agendamentos')
          .add({
        'nomePet': _nomePet,
        'motivoConsulta': _motivoConsulta,
        'dataPreferencial': _dataPreferencial,
        'tipoConsulta': 'Veterinário', // Adicione outros campos específicos do agendamento de veterinário aqui
        'dataAgendamento': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento realizado com sucesso para $_nomePet')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erro ao agendar veterinário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar veterinário.')),
      );
    }
  }
}