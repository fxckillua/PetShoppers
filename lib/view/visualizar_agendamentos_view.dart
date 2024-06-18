import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizarAgendamentosView extends StatefulWidget {
  @override
  _VisualizarAgendamentosViewState createState() => _VisualizarAgendamentosViewState();
}

class _VisualizarAgendamentosViewState extends State<VisualizarAgendamentosView> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Agendamentos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('agendamentos')
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
                subtitle: Text('Porte: ${agendamento['porte']}, Tipo: ${agendamento['tipoPet']}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarAgendamentoView(agendamento: agendamento),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditarAgendamentoView extends StatefulWidget {
  final DocumentSnapshot agendamento;

  EditarAgendamentoView({required this.agendamento});

  @override
  _EditarAgendamentoViewState createState() => _EditarAgendamentoViewState();
}

class _EditarAgendamentoViewState extends State<EditarAgendamentoView> {
  final _formKey = GlobalKey<FormState>();
  late String _nomePet;
  late String _porte;
  late String _tipoPet;

  @override
  void initState() {
    super.initState();
    _nomePet = widget.agendamento['nomePet'];
    _porte = widget.agendamento['porte'];
    _tipoPet = widget.agendamento['tipoPet'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _nomePet,
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
                    _editarAgendamento();
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editarAgendamento() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('agendamentos')
          .doc(widget.agendamento.id)
          .update({
        'nomePet': _nomePet,
        'porte': _porte,
        'tipoPet': _tipoPet,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento atualizado com sucesso')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erro ao atualizar agendamento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar agendamento')),
      );
    }
  }
}
