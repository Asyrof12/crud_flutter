import 'package:flutter/material.dart';
import 'package:card/settings/hamburger.dart';

class MySetting extends StatelessWidget {
  const MySetting({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomHamburger(),
        title: const Text("Setting"),
      ),
      body: Center(
        child: Text("This is the setting page."),
      ),
    );
  }
}