import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget{
  const ErrorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/error.png', height: 300, width: double.infinity, fit: BoxFit.cover,),
          const SizedBox(height: 24,),
          Text('Something went wrong!', style: Theme.of(context).textTheme.titleLarge,)
        ],
      ),
    );
  }
}