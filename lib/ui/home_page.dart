import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/moor_database.dart';
import 'widget/new_task_input_widget.dart';

const platform = const MethodChannel('database/demo');
const stream = const EventChannel('com.yourcompany.eventchannelsample/stream');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showCompleted = false;

  @override
  void initState() {
    _initDb().then((v) {
      print('DB is open? $v');
      _getMessage().then((String message) {
        print("From Room => $message");
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
          actions: <Widget>[
            _buildCompletedOnlySwitch(),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: _buildTaskList(context)),
            NewTaskInput(),
          ],
        ));
  }

  Row _buildCompletedOnlySwitch() {
    return Row(
      children: <Widget>[
        Text('Update Task'),
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () async {
            await platform.invokeMethod('updateTask', 'new Task name');
          },
        )
      ],
    );
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      stream: dao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, dao);
          },
        );
      },
    );
  }

  Widget _buildListItem(Task itemTask, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(itemTask),
        )
      ],
      child: ListTile(
        title: Text(itemTask.name),
        subtitle: Text('No date'),
      ),
    );
  }

  Future<bool> _initDb() async {
    bool value;
    try {
      value = await platform.invokeMethod('initDb');
    } catch (e) {
      value = false;
    }
    return value;
  }

  Future<String> _getMessage() async {
    String value;
    try {
      value = await platform.invokeMethod('getMessage');
    } catch (e) {
      value = e.toString();
    }
    return value;
  }
}
