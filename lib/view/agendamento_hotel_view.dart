import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto02app/view/ver_agendamentos_hotel_view.dart';

class AgendamentoHotelView extends StatefulWidget {
  @override
  _AgendamentoHotelViewState createState() => _AgendamentoHotelViewState();
}

class _AgendamentoHotelViewState extends State<AgendamentoHotelView> {
  final _formKey = GlobalKey<FormState>();
  String _nomePet = '';
  String _dataEntrada = '';
  String _dataSaida = '';
  String _tipoPet = 'Cachorro'; // Default selecionado como Cachorro
  String _porte = 'Pequeno'; // Default selecionado como Pequeno

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Hotel para Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  decoration: InputDecoration(labelText: 'Data de Entrada'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a data de entrada';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _dataEntrada = value!;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Data de Saída'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a data de saída';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _dataSaida = value!;
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
                      _agendarHotel();
                    }
                  },
                  child: Text('Agendar'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VerAgendamentosHotelView()));
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

  void _agendarHotel() async {
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
        'dataEntrada': _dataEntrada,
        'dataSaida': _dataSaida,
        'tipoPet': _tipoPet, // Salva o tipo de pet selecionado
        'porte': _porte, // Salva o porte do pet selecionado
        'tipoConsulta': 'Hotel', // Identifica o tipo de agendamento como "Hotel"
        'dataAgendamento': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento de hotel realizado com sucesso para $_nomePet')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erro ao agendar hotel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar hotel.')),
      );
    }
  }
}