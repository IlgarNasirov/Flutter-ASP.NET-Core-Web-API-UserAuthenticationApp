import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:client/constant.dart';
import 'package:client/screens/error.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({required this.changeScreen, required this.username, super.key});
  final String username;
  final void Function() changeScreen;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isError=false;
  var _isLoading=false;

  void _logout() async{
        setState(() {
          _isLoading=true;
        });
        const storage= FlutterSecureStorage();
        var accessToken=await storage.read(key: 'accessToken');
        var url=Uri.http(Constant.url, 'api/user/logout');
        try{
          await http.get(url, headers: {
        'Content-Type':'application/json',
        'Authorization': 'Bearer $accessToken'
        });
          await storage.delete(key: 'accessToken');
          await storage.delete(key: 'refreshToken');
          widget.changeScreen();
          setState(() {
            _isLoading=false;
          });
        }
        catch(error){
          setState(() {
            _isError=true;
            _isLoading=false;
          });
        }
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _isError?null:AppBar(
        title: Text(widget.username),
        actions: [
          IconButton(onPressed: _logout, 
          icon: const Icon(Icons.exit_to_app)
          )
        ],
      ),
      body: _isError?const ErrorScreen():Center(
        child: _isLoading?const CircularProgressIndicator():Text('Hello ${widget.username}!', style: Theme.of(context).textTheme.titleLarge,),
      ),
    );
  }
}