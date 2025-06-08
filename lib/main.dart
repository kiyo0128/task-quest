import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TaskQuestApp());
}

class TaskQuestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'TaskQuest',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[800],
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: TaskQuestHome(),
      ),
    );
  }
}

class TaskQuestHome extends StatefulWidget {
  @override
  _TaskQuestHomeState createState() => _TaskQuestHomeState();
}

class _TaskQuestHomeState extends State<TaskQuestHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.blue[50],
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    'TaskQuest',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'タスク管理×RPG育成アプリ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!gameProvider.hasCharacter) {
          return CharacterCreationScreen();
        }

        return MainScreen();
      },
    );
  }
}

// Character Creation Screen
class CharacterCreationScreen extends StatefulWidget {
  @override
  _CharacterCreationScreenState createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  String selectedProfession = 'warrior';
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎯 キャラクター作成'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.blue[600],
            ),
            SizedBox(height: 24),
            Text(
              'TaskQuest へようこそ！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'タスクを完了してキャラクターを育成しよう！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '🏷️ キャラクター名',
                  hintText: 'あなたの名前を入力してください',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.blue[600]),
                ),
                onChanged: (value) {
                  setState(() {}); // ボタンの状態を更新
                },
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating || _nameController.text.trim().isEmpty 
                    ? null 
                    : _createCharacter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '🚀 冒険を始める',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCharacter() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final gameProvider = context.read<GameProvider>();
      await gameProvider.createCharacter(selectedProfession, name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name が冒険を始めました！'),
            backgroundColor: Colors.green[600],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('キャラクター作成に失敗しました'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// Main Screen
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final character = gameProvider.character;
        return Scaffold(
          appBar: AppBar(
            title: Text('TaskQuest - ${character?.name}'),
            centerTitle: true,
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.white],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_pin,
                          size: 60,
                          color: Colors.blue[600],
                        ),
                        SizedBox(height: 16),
                        Text(
                          '🏆 ${character?.name}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatCard('レベル', '${character?.level}', Colors.orange),
                            SizedBox(width: 16),
                            _buildStatCard('経験値', '${character?.experience}', Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🎉 TaskQuest が起動しました！',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'タスク管理機能は準備中です...\n今後のアップデートをお楽しみに！',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Character Model
class Character {
  final String id;
  final String profession;
  final String name;
  final int level;
  final int experience;
  final DateTime createdAt;

  Character({
    required this.id,
    required this.profession,
    required this.name,
    this.level = 1,
    this.experience = 0,
    required this.createdAt,
  });

  factory Character.create(String profession, String name) {
    return Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profession: profession,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profession': profession,
      'name': name,
      'level': level,
      'experience': experience,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] ?? '',
      profession: map['profession'] ?? 'warrior',
      name: map['name'] ?? '',
      level: map['level']?.toInt() ?? 1,
      experience: map['experience']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());
  factory Character.fromJson(String source) => Character.fromMap(json.decode(source));
}

// Game Provider
class GameProvider with ChangeNotifier {
  Character? _character;
  bool _isLoading = false;

  Character? get character => _character;
  bool get isLoading => _isLoading;
  bool get hasCharacter => _character != null;

  // 初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final characterJson = prefs.getString('taskquest_character');
      
      if (characterJson != null) {
        _character = Character.fromJson(characterJson);
      }
    } catch (e) {
      print('初期化エラー: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // キャラクター作成
  Future<void> createCharacter(String profession, String name) async {
    _character = Character.create(profession, name);
    
    // 保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taskquest_character', _character!.toJson());
    
    notifyListeners();
  }
}
