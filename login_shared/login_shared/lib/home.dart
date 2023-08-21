import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            children: [
               Text(
                "Home Page",
                style: TextStyle(fontSize: 35),
              ),
               SizedBox(
                height: 10,
              ),
              Text("Burası Home Page"),
              
              
              
            ],
          ),
        ),
      ),
      ),
    );
  }
}