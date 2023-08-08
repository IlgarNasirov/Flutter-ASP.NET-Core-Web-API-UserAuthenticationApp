import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:client/constant.dart';
import 'package:client/screens/error.dart';
import 'package:client/screens/home.dart';

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState()=>_AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>{
  final _form=GlobalKey<FormState>();
  var _enteredUsername='';
  var _enteredPassword='';
  var _isRegister=false;
  var _isError=false;
  var _isLogin=false;
  var _error='';
  var _isLoading=false;

  void _changeScreen(){
    setState(() {
      _isLogin=false;
    });
  }

  void _toggleAuth(){
    setState(() {
      _isRegister=!_isRegister;
    });
  }

  void _submit() async{

    final isValid=_form.currentState!.validate();
    
    if(!isValid){
      return;
    }
    
    _form.currentState!.save();

    Uri url;
    setState(() {
          _isLoading=true;
    });
    if(_isRegister){
      url=Uri.http(Constant.url, 'api/user/register');
    }
    else{
      url=Uri.http(Constant.url, 'api/user/login');
    }

    try{
      final response=await http.post(url, headers: {
        'Content-Type':'application/json'
      },
      body: json.encode({
        'username': _enteredUsername,
        'password': _enteredPassword
      })
      );

      if(response.statusCode==400||response.statusCode==404){
       setState(() {
         _error=response.body;
        _isLoading=false;
       });
      }
      else
      if(_isRegister){
        _form.currentState!.reset();
        _toggleAuth();
        setState(() {
          _isLoading=false;
          _error='';
        });
      }
      else{
        final Map<String, dynamic> responseData=json.decode(response.body);
        const storage= FlutterSecureStorage();
        await storage.write(key: 'accessToken', value: responseData['accessToken']);
        await storage.write(key: 'refreshToken', value: responseData['refreshToken']);
        setState(() {
          _isLoading=false;
          _isLogin=true;
          _error='';
        });
      }
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
      body: _isLogin?HomeScreen(username: _enteredUsername, changeScreen: _changeScreen,):_isError?const ErrorScreen():Center(
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  width: 300,
                  child: Image.asset('assets/images/user.png')
                ),
                Card(
                  margin: const EdgeInsets.only(left:20, right: 20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                maxLength: 50,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value){
                                  if(value==null||value.trim().length<3){
                                    return 'Please enter at least 3 characters for the username.';
                                  }
                                  return null;
                                },
                                onSaved: (value){
                                  _enteredUsername=value!;
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Password'
                                ),
                                obscureText: true,
                                validator: (value){
                                  if(value==null||value.trim().length<6){
                                    return 'Please enter at least 6 characters for the password.';
                                  }
                                  return null;
                                },
                                onSaved: (value){
                                  _enteredPassword=value!;
                                },
                              ),
                              const SizedBox(height: 10,),
                              if(_error.isNotEmpty)
                              Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.start,),
                              ElevatedButton(onPressed: _submit,
                              child: _isLoading?const Text('Please wait...'):_isRegister?const Text('Register'):const Text('Login')
                              ),
                              TextButton(onPressed: _toggleAuth, 
                              child: _isRegister?const Text('Login'):const Text('Register')
                              )
                            ],
                          ),  
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ),
        ),
      );
  }
}