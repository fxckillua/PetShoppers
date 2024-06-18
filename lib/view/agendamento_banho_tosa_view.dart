import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'visualizar_agendamentos_view.dart';

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
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VisualizarAgendamentosView()),
              );
            },
          ),
        ],
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
