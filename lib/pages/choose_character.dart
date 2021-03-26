import 'package:flutter/material.dart';
import 'package:flutter_social_media/services/auth_service.dart';

class ChooseCharacter extends StatelessWidget {
  final List _characters = [
    {
      'name': 'Shadow',
      'image': 'assets/images/characters/shadow.jpg',
      'email': 'shadow@example.com'
    },
    {
      'name': 'Luna',
      'image': 'assets/images/characters/luna.jpg',
      'email': 'luna@example.com'
    },
    {
      'name': 'Moose',
      'image': 'assets/images/characters/moose.jpg',
      'email': 'moose@example.com'
    },
    {
      'name': 'Sammy',
      'image': 'assets/images/characters/sammy.jpg',
      'email': 'sammy@example.com'
    },
    {
      'name': 'Marley',
      'image': 'assets/images/characters/marley.jpg',
      'email': 'marley@example.com'
    },
    {
      'name': 'Bruno',
      'image': 'assets/images/characters/bruno.jpg',
      'email': 'bruno@example.com'
    },
    {
      'name': 'Lucky',
      'image': 'assets/images/characters/lucky.jpg',
      'email': 'lucky@example.com'
    },
    {
      'name': 'Apollo',
      'image': 'assets/images/characters/apollo.jpg',
      'email': 'apollo@example.com'
    },
    {
      'name': 'Hunter',
      'image': 'assets/images/characters/hunter.jpg',
      'email': 'hunter@example.com'
    },
    {
      'name': 'Blue',
      'image': 'assets/images/characters/blue.jpg',
      'email': 'blue@example.com'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Character'),
      ),
      body: Container(
        child: SafeArea(
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              height: 1,
            ),
            itemCount: _characters.length,
            itemBuilder: (context, index) => ListTile(
              title: Text('Login as ${_characters[index]['name']}'),
              leading: CircleAvatar(
                backgroundImage: AssetImage(_characters[index]['image']),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              selectedTileColor: Colors.grey[200],
              onTap: () => AuthService().signInWithEmailAndPassword(
                  _characters[index]['email'], 'test123'),
            ),
          ),
        ),
      ),
    );
  }
}
