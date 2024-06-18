import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto02app/view/principal_view.dart';
import 'visualizar_agendamentos_view.dart';

class AgendamentoVeterinarioView extends StatefulWidget {
  @override
  _AgendamentoVeterinarioViewState createState() => _AgendamentoVeterinarioViewState();
}

class _AgendamentoVeterinarioViewState extends State<AgendamentoVeterinarioView> {
  final _formKey = GlobalKey<FormState>();
  String _nomePet = '';
  String _motivoConsulta = '';
  String _dataPreferencial = '';
  String _tipoPet = 'Cachorro'; // Default selecionado como Cachorro
  String _porte = 'Pequeno'; // Default selecionado como Pequeno

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
          child: SingleChildScrollView( // Adicionado SingleChildScrollView
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
        'tipoPet': _tipoPet, // Salva o tipo de pet selecionado
        'porte': _porte, // Salva o porte do pet selecionado
        'tipoConsulta': 'Veterinário',
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

class VerAgendamentosView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Agendamentos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseAuth.instance.currentUser == null
            ? null
            : FirebaseFirestore.instance
                .collection('usuarios')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('agendamentos')
                .orderBy('dataAgendamento', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var agendamentos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              var agendamento = agendamentos[index];
              return ListTile(
                title: Text(agendamento['nomePet']),
                subtitle: Text(
                  'Motivo: ${agendamento['motivoConsulta']} \n'
                  'Data: ${agendamento['dataPreferencial']} \n'
                  'Tipo de Pet: ${agendamento['tipoPet']} \n'
                  'Porte: ${agendamento['porte']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}