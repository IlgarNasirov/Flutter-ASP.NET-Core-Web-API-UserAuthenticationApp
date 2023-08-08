import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:client/constant.dart';
import 'package:client/screens/auth.dart';
import 'package:client/screens/error.dart';
import 'package:client/screens/home.dart';

class App extends StatefulWidget{
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _isError=false;
  final storage= const FlutterSecureStorage();
  String? accessToken;
  String? refreshToken;
  Widget? _widget;

  void _changeScreen(){
    setState(() {
      _widget=const AuthScreen();
    });
  }

  Future<String> _getUser() async{
      accessToken=await storage.read(key: 'accessToken');
      refreshToken=await storage.read(key: 'refreshToken');
      if(accessToken==null||refreshToken==null){
        return '';
      }
      final url=Uri.http(Constant.url, 'api/user/username');
      try{
      final response=await http.get(url, headers: {
        'Content-Type':'application/json',
        'Authorization': 'Bearer $accessToken'
      });
      if(response.statusCode!=401){
        return response.body;
      }
      }
      catch(error){
        setState(() {
          _isError=true;
        });
      }
      return 'other';
    }

  Future<bool>_createAccessToken()async{
     final url=Uri.http(Constant.url, 'api/user/createaccesstoken');
      try{
      final response=await http.post(url, headers: {
        'Content-Type':'application/json',
        'refreshToken': '$refreshToken'
      });
      if(response.statusCode!=404){
        final Map<String, dynamic> responseData=json.decode(response.body);
        await storage.write(key: 'accessToken', value: responseData['accessToken']);
        await storage.write(key: 'refreshToken', value: responseData['refreshToken']);
        return true;
      }
      }
      catch(error){
        setState(() {
          _isError=true;
        });
      }
      return false;
  }

void _setWidget() async{
    var username=await _getUser();
    if(username==''){
      _widget=const AuthScreen();
    }
    else{
      if(username=='other'){
        var check= await _createAccessToken();
        if(check){
        var username=await _getUser();
        _widget= HomeScreen(username: username, changeScreen: _changeScreen,);
        }
        else{
          _widget=const AuthScreen();
        }
      }
      else{
        _widget= HomeScreen(username: username, changeScreen: _changeScreen,);
      }
    }
    setState(() {
      
    });
}

@override
  void initState() {
    super.initState();
    _widget=const Scaffold(body: Center(child: CircularProgressIndicator(),));
    _setWidget();
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: _isError?const Scaffold(body: ErrorScreen(),):_widget,
    );
  }
}