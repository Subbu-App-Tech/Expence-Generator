import 'package:expence_generator/apps/src/Data/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:expence_generator/apps/src/home.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.init();
  runApp(const MyHome());
}
