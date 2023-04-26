import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? task;
  const AddPage({
    super.key,
    this.task,
    });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if(task != null){
      isEdit = true;
      final title = task['title'];
      final description = task['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar tarefa' : 'Adicionar Tarefa',
          ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Título'),
            ),
            SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Descrição'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                isEdit ? 'Atualizar' : 'Enviar',
                ),
            ),
            )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final task = widget.task;
    if(task == null) {
      print('Você não pode chamar a atualização sem os dados ta tarefa');
      return;
    }
    final id = task['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title" : title,
      "description" : description,
      "is_completed" : false,
    };

    //Enviar dados atualizados ao servidor
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
     body: jsonEncode(body),headers: {'Content-Type': 'application/json'},
     );

     //Exibir mensagem de sucesso ou erro
    if(response.statusCode == 200) {
      showSuccessMessage('Tarefa atualizada!');
    }else{
      showErrorMessage('Falha ao atualizar.');
    }
  }

  Future<void> submitData() async {
    //Receber dados do formulario
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title" : title,
      "description" : description,
      "is_completed" : false,
    };
    //Enviar dados ao servidor
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
     body: jsonEncode(body),headers: {'Content-Type': 'application/json'},
     );
    //Exibir mensagem de sucesso ou erro
    if(response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      print('Tarefa adicionada');
      showSuccessMessage('Tarefa adicionada');
    }else{
      print('Falha ao adicionar');
      showErrorMessage('Falha ao adicionar');
    }
  }
  
  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white)
        ),
    backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}