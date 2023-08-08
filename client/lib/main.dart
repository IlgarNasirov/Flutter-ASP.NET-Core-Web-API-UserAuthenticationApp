import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:client/app.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
     DeviceOrientation.portraitUp
  ]).then((fn){
  runApp(const App());
  });
}