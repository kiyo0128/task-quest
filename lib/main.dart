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

  final Map<String, Map<String, dynamic>> professions = {
    'warrior': {
      'name': '戦士',
      'icon': '⚔️',
      'description': '物理攻撃が得意\n体力とパワーを重視',
      'color': Colors.red,
    },
    'mage': {
      'name': '魔法使い',
      'icon': '🧙‍♂️',
      'description': '魔法攻撃が得意\n知識と魔力を重視',
      'color': Colors.purple,
    },
    'rogue': {
      'name': '盗賊',
      'icon': '🗡️',
      'description': '素早さが得意\n敏捷性と技術を重視',
      'color': Colors.green,
    },
    'priest': {
      'name': '僧侶',
      'icon': '✨',
      'description': '回復が得意\n信仰と知恵を重視',
      'color': Colors.amber,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎯 キャラクター作成'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
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
            
            // 名前入力
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
            SizedBox(height: 24),
            
            // 職業選択
            Text(
              '⚔️ 職業を選択してください',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: professions.length,
              itemBuilder: (context, index) {
                final profession = professions.keys.elementAt(index);
                final data = professions[profession]!;
                final isSelected = selectedProfession == profession;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedProfession = profession;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? data['color'].withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? data['color'] : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['icon'],
                          style: TextStyle(fontSize: 32),
                        ),
                        SizedBox(height: 8),
                        Text(
                          data['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: data['color'],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['description'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CharacterScreen(),
          TaskScreen(),
          ShopScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'キャラクター',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'タスク',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'ショップ',
          ),
        ],
      ),
    );
  }
}

// Character Screen
class CharacterScreen extends StatelessWidget {
  final Map<String, Map<String, dynamic>> professions = {
    'warrior': {'name': '戦士', 'icon': '⚔️', 'color': Colors.red},
    'mage': {'name': '魔法使い', 'icon': '🧙‍♂️', 'color': Colors.purple},
    'rogue': {'name': '盗賊', 'icon': '🗡️', 'color': Colors.green},
    'priest': {'name': '僧侶', 'icon': '✨', 'color': Colors.amber},
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final character = gameProvider.character;
        final professionData = professions[character?.profession] ?? professions['warrior']!;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('${professionData['icon']} ${character?.name}'),
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // キャラクター情報
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
                        Text(
                          professionData['icon'],
                          style: TextStyle(fontSize: 80),
                        ),
                        SizedBox(height: 16),
                        Text(
                          character?.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          professionData['name'],
                          style: TextStyle(
                            fontSize: 18,
                            color: professionData['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard('レベル', '${character?.level}', Colors.orange),
                            _buildStatCard('経験値', '${character?.experience}', Colors.green),
                            _buildStatCard('次のレベル', '${character?.expToNextLevel}', Colors.blue),
                          ],
                        ),
                        SizedBox(height: 16),
                        // 経験値バー
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (character?.experience ?? 0) / (character?.expToNextLevel ?? 100),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // 統計情報
                  Container(
                    padding: EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        Text(
                          '📊 統計',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('完了タスク', '${gameProvider.completedTasksCount}', Icons.check_circle),
                            _buildStatItem('総タスク', '${gameProvider.totalTasksCount}', Icons.task_alt),
                          ],
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue[600]),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Task Screen
class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedDifficulty = 'normal';

  final Map<String, Map<String, dynamic>> difficulties = {
    'easy': {'name': '簡単', 'exp': 10, 'color': Colors.green, 'icon': '🟢'},
    'normal': {'name': '普通', 'exp': 25, 'color': Colors.orange, 'icon': '🟡'},
    'hard': {'name': '難しい', 'exp': 50, 'color': Colors.red, 'icon': '🔴'},
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('📋 タスク管理'),
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
            child: Column(
              children: [
                // タスク追加エリア
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '➕ 新しいタスクを追加',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          hintText: 'タスクを入力してください',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '難易度を選択',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: difficulties.entries.map((entry) {
                          final difficulty = entry.key;
                          final data = entry.value;
                          final isSelected = _selectedDifficulty == difficulty;
                          
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? data['color'].withOpacity(0.1) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected ? data['color'] : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(data['icon'], style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 2),
                                    Text(
                                      data['name'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: data['color'],
                                      ),
                                    ),
                                    Text(
                                      '+${data['exp']}XP',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _taskController.text.trim().isEmpty ? null : _addTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('タスクを追加'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // タスクリスト
                Expanded(
                  child: gameProvider.tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'タスクがありません',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '上記のフォームから\n新しいタスクを追加しましょう！',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: gameProvider.tasks.length,
                          itemBuilder: (context, index) {
                            final task = gameProvider.tasks[index];
                            final difficultyData = difficulties[task.difficulty]!;
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: difficultyData['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      difficultyData['icon'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    color: task.isCompleted ? Colors.grey[500] : Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  '${difficultyData['name']} (+${difficultyData['exp']}XP)',
                                  style: TextStyle(
                                    color: difficultyData['color'],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: task.isCompleted
                                    ? Icon(Icons.check_circle, color: Colors.green)
                                    : IconButton(
                                        icon: Icon(Icons.check_circle_outline),
                                        onPressed: () => _completeTask(task),
                                      ),
                                onLongPress: () => _deleteTask(task),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    final gameProvider = context.read<GameProvider>();
    gameProvider.addTask(title, _selectedDifficulty);
    
    _taskController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('タスクを追加しました！'),
        backgroundColor: Colors.green[600],
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _completeTask(Task task) {
    final gameProvider = context.read<GameProvider>();
    final expGained = difficulties[task.difficulty]!['exp'];
    
    gameProvider.completeTask(task);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('タスク完了！ +${expGained}XP 獲得！'),
        backgroundColor: Colors.green[600],
        duration: Duration(milliseconds: 2000),
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('タスクを削除'),
        content: Text('「${task.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().deleteTask(task);
              Navigator.pop(context);
            },
            child: Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}

// Shop Screen (Placeholder)
class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏪 ショップ'),
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
              Icon(
                Icons.store,
                size: 80,
                color: Colors.blue[600],
              ),
              SizedBox(height: 24),
              Text(
                'ショップ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'アイテムショップは準備中です...\n今後のアップデートをお楽しみに！',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Task Model
class Task {
  final String id;
  final String title;
  final String difficulty;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.difficulty,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory Task.create(String title, String difficulty) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      difficulty: difficulty,
      createdAt: DateTime.now(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? difficulty,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      difficulty: map['difficulty'] ?? 'normal',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}

// Character Model
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

  // 次のレベルまでに必要な経験値を計算
  int get expToNextLevel {
    return level * 100;
  }

  // レベルアップ可能かチェック
  bool get canLevelUp {
    return experience >= expToNextLevel;
  }

  factory Character.create(String profession, String name) {
    return Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profession: profession,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  Character copyWith({
    String? id,
    String? profession,
    String? name,
    int? level,
    int? experience,
    DateTime? createdAt,
  }) {
    return Character(
      id: id ?? this.id,
      profession: profession ?? this.profession,
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      createdAt: createdAt ?? this.createdAt,
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
  List<Task> _tasks = [];
  bool _isLoading = false;

  Character? get character => _character;
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get hasCharacter => _character != null;

  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;
  int get totalTasksCount => _tasks.length;

  final Map<String, int> _difficultyExp = {
    'easy': 10,
    'normal': 25,
    'hard': 50,
  };

  // 初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // キャラクター読み込み
      final characterJson = prefs.getString('taskquest_character');
      if (characterJson != null) {
        _character = Character.fromJson(characterJson);
      }
      
      // タスク読み込み
      final tasksJson = prefs.getStringList('taskquest_tasks') ?? [];
      _tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
      
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
    await _saveCharacter();
    notifyListeners();
  }

  // タスク追加
  Future<void> addTask(String title, String difficulty) async {
    final task = Task.create(title, difficulty);
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  // タスク完了
  Future<void> completeTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      
      // 経験値獲得
      final expGained = _difficultyExp[task.difficulty] ?? 0;
      _gainExperience(expGained);
      
      await _saveTasks();
      await _saveCharacter();
      notifyListeners();
    }
  }

  // タスク削除
  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    await _saveTasks();
    notifyListeners();
  }

  // 経験値獲得
  void _gainExperience(int exp) {
    if (_character == null) return;
    
    int newExp = _character!.experience + exp;
    int newLevel = _character!.level;
    
    // レベルアップチェック
    while (newExp >= newLevel * 100) {
      newExp -= newLevel * 100;
      newLevel++;
    }
    
    _character = _character!.copyWith(
      experience: newExp,
      level: newLevel,
    );
  }

  // データ保存
  Future<void> _saveCharacter() async {
    if (_character == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taskquest_character', _character!.toJson());
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setStringList('taskquest_tasks', tasksJson);
  }
}

