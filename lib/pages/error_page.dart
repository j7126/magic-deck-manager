import 'package:flutter/material.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/widgets/nav.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavMenu(),
      appBar: AppBar(
        title: const Text(Service.appName),
      ),
      body: const Center(
        child: Text('An unknown error has occurred.'),
      ),
    );
  }
}
