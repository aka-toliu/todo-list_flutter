import 'package:flutter/material.dart';
import 'package:todo_list/widgets/todo_list_item.dart';
import '../models/todo.dart';
import '../repositories/repository.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController todoController = TextEditingController();
  final Repository todoRepository = Repository();

  List<Todo> tasks = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();
    Repository().getTodoList().then((value){
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: todoController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicionar task',
                          hintText: 'Ex.: Estudar dart',
                          errorText: errorText
                      ),

                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: addItem,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.all(16)),
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Todo task in tasks)
                      TodoListItem(todo: task, onDelete: onDelete),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                      child: Text(
                          'Você possui ${tasks.length} tarefas pendentes')),
                  SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: showDeleteDialog,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.all(16)),
                      child: Text(
                        'Limpar tudo',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  void addItem() {
    String text = todoController.text;

    if(text.isEmpty){
        setState(() {
          errorText = 'O campo não pode ser vazio';
        });
        return;
    }

    setState(() {
      Todo newTodo = Todo(
        title: text,
        dateTime: DateTime.now(),
      );

      tasks.add(newTodo);
      errorText = null;
    });
    todoController.clear();
    Repository().saveTodoList(tasks);
  }

  void onSubmmited(String text) {
    // ignore: avoid_print
    print(text);
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = tasks.indexOf(todo);

    setState(() {
      tasks.remove(todo);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('A task ${todo.title} Foi removida com sucesso!'),
      action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tasks.insert(deletedTodoPos!, deletedTodo!);
            });
          }),
    ));
    Repository().saveTodoList(tasks);
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir tudo'),
        content: Text('Tem certeza que deseja limpar tudo?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTasks();
            },
            child: Text('Limpar tudo', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
    Repository().saveTodoList(tasks);
  }
}
