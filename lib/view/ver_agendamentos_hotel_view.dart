import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerAgendamentosHotelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Agendamentos de Hotel'),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: fetchAgendamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar agendamentos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum agendamento encontrado'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final agendamento = snapshot.data![index];
                return ListTile(
                  title: Text(agendamento.nomePet),
                  subtitle: Text('Data: ${agendamento.dataAgendamento}\nTipo: ${agendamento.tipoPet}\nPorte: ${agendamento.portePet}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Agendamento>> fetchAgendamentos() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('agendamentosHotel').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Agendamento(
          nomePet: data['nomePet'],
          dataAgendamento: data['dataAgendamento'],
          tipoPet: data['tipoPet'],
          portePet: data['portePet'],
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar agendamentos: $e');
      return []; // Retorna uma lista vazia em caso de erro
    }
  }
}

class Agendamento {
  final String nomePet;
  final String dataAgendamento;
  final String tipoPet;
  final String portePet;

  Agendamento({
    required this.nomePet,
    required this.dataAgendamento,
    required this.tipoPet,
    required this.portePet,
  });
}
