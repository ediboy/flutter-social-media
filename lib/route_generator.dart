import 'package:flutter/material.dart';
import 'package:flutter_social_media/pages/post/create_post.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // post
      case '/create-post':
        if (args != null) {
          return MaterialPageRoute(builder: (_) => CreatePost(user: args));
        }
        return _errorRoute();

      // page not found
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('PAGE NOT FOUND'),
        ),
      );
    });
  }
}
