import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Database"),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: IconButton(
          onPressed: sharing,
          icon: Icon(Icons.share),
        ),
      ),
    );
  }
}

void sharing() async {
  String path = p.join(await getDatabasesPath(), 'mediLight.db');
  Share.shareFiles([path], subject: "Database");
}
