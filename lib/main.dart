import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:provider/provider.dart';

import 'data/moor_database.dart';
import 'ui/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          builder: (_) => AppDatabase(
            FlutterQueryExecutor(
              path: 'db.sqlite',
              logStatements: true,
            ),
          ).taskDao,
        ),
        ChangeNotifierProvider(builder: (_) => Model()),
      ],
      child: MaterialApp(
        title: 'Material App',
        home: Consumer<Model>(
          builder: (context, model, child) => HomePage(),
        ),
      ),
    );
  }
}

class Model extends ChangeNotifier {
  void update() {
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
