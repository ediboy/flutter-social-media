import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_social_media/pages/wrapper.dart';
import 'package:flutter_social_media/route_generator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat',
      home: _Content(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class _Content extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print('Something went wrong');
        }

        // Show app
        if (snapshot.connectionState == ConnectionState.done) {
          return Wrapper();
        }

        // Show loading
        return Center(
          child: Container(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
