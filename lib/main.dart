import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html show window if (dart.library.html) 'dart:html';
import 'package:table_calendar/table_calendar.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:async';
import 'dart:math';

// プラットフォーム対応ストレージ
class PlatformStorage {
  static Future<String?> getString(String key) async {
    try {
      // Web環境の場合
      if (kIsWeb) {
        try {
          final value = html.window.localStorage[key];
          print('🌐 WebStorage 読み込み: $key = $value');
          return value;
        } catch (e) {
          print('⚠️ WebStorage 読み込みエラー: $e');
        }
      }
      
      // SharedPreferencesをフォールバックとして使用
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      print('📱 SharedPreferences 読み込み: $key = $value');
      return value;
    } catch (e) {
      print('❌ ストレージ読み込みエラー: $e');
      return null;
    }
  }

  static Future<bool> setString(String key, String value) async {
    try {
      // Web環境の場合
      if (kIsWeb) {
        try {
          html.window.localStorage[key] = value;
          print('🌐 WebStorage 保存成功: $key');
        } catch (e) {
          print('⚠️ WebStorage 保存エラー: $e');
        }
      }
      
      // SharedPreferencesにも保存
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(key, value);
      print('📱 SharedPreferences 保存: $key = ${success ? "成功" : "失敗"}');
      return success;
    } catch (e) {
      print('❌ ストレージ保存エラー: $e');
      return false;
    }
  }

  static Future<List<String>> getStringList(String key) async {
    try {
      // Web環境の場合
      if (kIsWeb) {
        try {
          final value = html.window.localStorage[key];
          if (value != null && value.isNotEmpty) {
            final List<dynamic> decoded = json.decode(value);
            final result = decoded.cast<String>();
            print('🌐 WebStorage リスト読み込み: $key = ${result.length}件');
            return result;
          }
        } catch (e) {
          print('⚠️ WebStorage リスト読み込みエラー: $e');
        }
      }
      
      // SharedPreferencesをフォールバックとして使用
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getStringList(key) ?? [];
      print('📱 SharedPreferences リスト読み込み: $key = ${result.length}件');
      return result;
    } catch (e) {
      print('❌ ストレージリスト読み込みエラー: $e');
      return [];
    }
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      // Web環境の場合
      if (kIsWeb) {
        try {
          html.window.localStorage[key] = json.encode(value);
          print('🌐 WebStorage リスト保存成功: $key = ${value.length}件');
        } catch (e) {
          print('⚠️ WebStorage リスト保存エラー: $e');
        }
      }
      
      // SharedPreferencesにも保存
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setStringList(key, value);
      print('📱 SharedPreferences リスト保存: $key = ${success ? "成功" : "失敗"}');
      return success;
    } catch (e) {
      print('❌ ストレージリスト保存エラー: $e');
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      // Web環境の場合
      if (kIsWeb) {
        try {
          html.window.localStorage.remove(key);
          print('🌐 WebStorage 削除成功: $key');
        } catch (e) {
          print('⚠️ WebStorage 削除エラー: $e');
        }
      }
      
      // SharedPreferencesからも削除
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(key);
      print('📱 SharedPreferences 削除: $key = ${success ? "成功" : "失敗"}');
      return success;
    } catch (e) {
      print('❌ ストレージ削除エラー: $e');
      return false;
    }
  }
}

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

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CharacterScreen(),
          TaskScreen(),
          CalendarScreen(),
          QuestScreen(),
          PomodoroScreen(),
          ShopScreen(),
          AchievementScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setSelectedIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 10,
        unselectedFontSize: 8,
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
            icon: Icon(Icons.calendar_today),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'クエスト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'ポモドーロ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'ショップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '実績',
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
            actions: [
              IconButton(
                icon: Icon(Icons.bug_report),
                onPressed: () => _showDebugInfo(context, gameProvider),
                tooltip: 'デバッグ情報',
              ),
            ],
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
                            _buildStatCard('ゴールド', '${character?.gold}G', Colors.amber),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            _buildStatItem('実績', '${gameProvider.unlockedAchievementsCount}/${gameProvider.achievements.length}', Icons.emoji_events),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('完了クエスト', '${gameProvider.quests.where((q) => q.isCompleted).length}', Icons.explore),
                            _buildStatItem('ポモドーロ', '${gameProvider.pomodoroSessions.where((s) => s.isCompleted).length}', Icons.timer),
                            _buildStatItem('ボス討伐', '${gameProvider.quests.where((q) => q.isCompleted && q.boss != null).length}', Icons.shield),
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

  void _showDebugInfo(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔧 デバッグ情報'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📱 プラットフォーム: ${kIsWeb ? "Web" : "Desktop"}'),
              SizedBox(height: 8),
              Text('💾 キャラクター: ${gameProvider.character != null ? "保存済み" : "未保存"}'),
              if (gameProvider.character != null) ...[
                SizedBox(height: 4),
                Text('名前: ${gameProvider.character!.name}'),
                Text('職業: ${gameProvider.character!.profession}'),
                Text('レベル: ${gameProvider.character!.level}'),
                Text('経験値: ${gameProvider.character!.experience}'),
              ],
              SizedBox(height: 8),
              Text('📋 タスク数: ${gameProvider.tasks.length}'),
              SizedBox(height: 16),
              Text(
                '⚠️ データが保存されない場合：\n'
                '${kIsWeb ? "• ブラウザのプライベートモード\n• ブラウザのデータクリア\n• ローカルストレージの制限" : "• アプリの権限設定\n• ストレージの容量不足"}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await gameProvider.resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('データをリセットしました'),
                  backgroundColor: Colors.orange[600],
                ),
              );
            },
            child: Text('データリセット', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('閉じる'),
          ),
        ],
      ),
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
  DateTime? _selectedDueDate;

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
                      
                      // 期限設定
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '📅 期限: ${_selectedDueDate != null ? "${_selectedDueDate!.month}/${_selectedDueDate!.day}" : "なし"}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _selectDueDate,
                            child: Text(_selectedDueDate != null ? '変更' : '設定'),
                          ),
                          if (_selectedDueDate != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDueDate = null;
                                });
                              },
                              child: Text('クリア', style: TextStyle(color: Colors.red)),
                            ),
                        ],
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
                                color: task.isOverdue && !task.isCompleted ? Colors.red[50] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: task.isOverdue && !task.isCompleted 
                                    ? Border.all(color: Colors.red[300]!, width: 1)
                                    : null,
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
                                    color: (difficultyData['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      difficultyData['icon'] as String,
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
                                    color: task.isCompleted ? Colors.grey[500] : 
                                           task.isOverdue ? Colors.red[700] : Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${difficultyData['name']} (+${difficultyData['exp']}XP, +${_getDifficultyGold(task.difficulty)}G)',
                                      style: TextStyle(
                                        color: difficultyData['color'] as Color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (task.dueDate != null)
                                      Text(
                                        '📅 期限: ${task.dueDate!.month}/${task.dueDate!.day}${task.isOverdue ? " (期限切れ)" : task.isDueToday ? " (今日)" : ""}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: task.isOverdue ? Colors.red : 
                                                 task.isDueToday ? Colors.orange : Colors.grey[600],
                                          fontWeight: task.isOverdue || task.isDueToday ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                                            trailing: task.isCompleted
                ? Icon(Icons.check_circle, color: Colors.green)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.timer, color: Colors.orange),
                        onPressed: () => _startPomodoroForTask(task),
                        tooltip: 'ポモドーロ開始',
                      ),
                      IconButton(
                        icon: Icon(Icons.check_circle_outline),
                        onPressed: () => _completeTask(task),
                        tooltip: 'タスク完了',
                      ),
                    ],
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
    gameProvider.addTask(title, _selectedDifficulty, dueDate: _selectedDueDate);
    
    _taskController.clear();
    setState(() {
      _selectedDueDate = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('タスクを追加しました！'),
        backgroundColor: Colors.green[600],
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    // シンプルな日付選択ダイアログを表示
    showDialog(
      context: context,
      builder: (context) => _DatePickerDialog(
        initialDate: _selectedDueDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDueDate = date;
          });
        },
      ),
    );
  }

  int _getDifficultyGold(String difficulty) {
    const goldMap = {'easy': 5, 'normal': 15, 'hard': 30};
    return goldMap[difficulty] ?? 15;
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

  void _startPomodoroForTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🍅 ポモドーロ開始'),
        content: Text('「${task.title}」のポモドーロタイマーを開始しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ポモドーロタブに移動
              final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
              if (mainScreenState != null) {
                mainScreenState.setSelectedIndex(4); // ポモドーロタブのインデックス
              }
            },
            child: Text('開始'),
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

// カスタム日付選択ダイアログ
class _DatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onDateSelected;

  _DatePickerDialog({required this.initialDate, required this.onDateSelected});

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(30, (index) {
      return today.add(Duration(days: index));
    });

    return AlertDialog(
      title: Text('📅 期限を選択'),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: dates.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                leading: Icon(Icons.clear, color: Colors.red),
                title: Text('期限なし'),
                onTap: () {
                  widget.onDateSelected(null);
                  Navigator.pop(context);
                },
              );
            }
            
            final date = dates[index - 1];
            final isSelected = selectedDate != null && 
                date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;
            
            return ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              title: Text(
                '${date.month}/${date.day} (${_getWeekdayName(date.weekday)})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
              subtitle: Text(
                index == 1 ? '今日' : index == 2 ? '明日' : '${index - 1}日後',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                widget.onDateSelected(date);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('キャンセル'),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }
}

// Calendar Screen
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('📅 カレンダー'),
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
                // カレンダー
                Container(
                  margin: EdgeInsets.all(16),
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
                  child: TableCalendar<Task>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    eventLoader: (day) {
                      return gameProvider.getTasksForDate(day);
                    },
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.red[600]),
                      holidayTextStyle: TextStyle(color: Colors.red[600]),
                      markerDecoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.orange[400],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
                
                // 選択された日のタスク
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDay != null 
                              ? '📋 ${_selectedDay!.month}/${_selectedDay!.day}のタスク'
                              : '📋 今日のタスク',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: _buildTaskList(gameProvider, _selectedDay ?? DateTime.now()),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(GameProvider gameProvider, DateTime date) {
    final tasks = gameProvider.getTasksForDate(date);
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'この日にタスクはありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
                 final difficulties = {
           'easy': {'name': '簡単', 'exp': 10, 'color': Colors.green, 'icon': '🟢'},
           'normal': {'name': '普通', 'exp': 25, 'color': Colors.orange, 'icon': '🟡'},
           'hard': {'name': '難しい', 'exp': 50, 'color': Colors.red, 'icon': '🔴'},
         };
         final difficultyData = difficulties[task.difficulty] ?? difficulties['normal']!;
        
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: task.isOverdue && !task.isCompleted ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: task.isOverdue && !task.isCompleted 
                ? Border.all(color: Colors.red[300]!, width: 1)
                : null,
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
                color: (difficultyData['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  difficultyData['icon'] as String,
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
                color: task.isCompleted ? Colors.grey[500] : 
                       task.isOverdue ? Colors.red[700] : Colors.black,
              ),
            ),
            subtitle: Text(
              '${difficultyData['name']} (+${difficultyData['exp']}XP, +${_getDifficultyGold(task.difficulty)}G)${task.isOverdue ? " (期限切れ)" : task.isDueToday ? " (今日)" : ""}',
              style: TextStyle(
                color: task.isOverdue ? Colors.red : (difficultyData['color'] as Color),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: task.isCompleted
                ? Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: Icon(Icons.check_circle_outline),
                    onPressed: () => _completeTask(gameProvider, task),
                  ),
          ),
        );
      },
    );
  }

  void _completeTask(GameProvider gameProvider, Task task) {
    gameProvider.completeTask(task);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('タスク完了！'),
        backgroundColor: Colors.green[600],
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  int _getDifficultyGold(String difficulty) {
    const goldMap = {'easy': 5, 'normal': 15, 'hard': 30};
    return goldMap[difficulty] ?? 15;
  }
}

// Shop Screen
class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final character = gameProvider.character;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('🏪 ショップ'),
            centerTitle: true,
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            actions: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '${character?.gold ?? 0}G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                // ヘッダー
                Container(
                  margin: EdgeInsets.all(16),
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
                        '🏪 アイテムショップ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'タスクを完了してゴールドを稼ぎ、\n便利なアイテムを購入しよう！',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // アイテムリスト
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gameProvider.shopItems.length,
                    itemBuilder: (context, index) {
                      final item = gameProvider.shopItems[index];
                      final isPurchased = character?.purchasedItems.contains(item.id) ?? false;
                      final canAfford = (character?.gold ?? 0) >= item.price;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isPurchased ? Colors.green[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isPurchased 
                              ? Border.all(color: Colors.green[300]!, width: 1)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getTypeColor(item.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                item.icon,
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPurchased ? Colors.green[700] : Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(item.type).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getTypeName(item.type),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getTypeColor(item.type),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Icon(Icons.monetization_on, 
                                           color: Colors.amber, size: 16),
                                      SizedBox(width: 2),
                                      Text(
                                        '${item.price}G',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: canAfford ? Colors.amber[700] : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: isPurchased
                              ? Icon(Icons.check_circle, color: Colors.green, size: 32)
                              : ElevatedButton(
                                  onPressed: canAfford ? () => _purchaseItem(context, gameProvider, item) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canAfford ? Colors.blue[600] : Colors.grey[300],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    canAfford ? '購入' : '不足',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'weapon': return Colors.red;
      case 'armor': return Colors.blue;
      case 'accessory': return Colors.purple;
      case 'consumable': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'weapon': return '武器';
      case 'armor': return '防具';
      case 'accessory': return '装飾品';
      case 'consumable': return '消耗品';
      default: return 'その他';
    }
  }

  void _purchaseItem(BuildContext context, GameProvider gameProvider, ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('アイテム購入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.icon} ${item.name}'),
            SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Text('価格: ${item.price}G'),
            Text('所持金: ${gameProvider.character?.gold ?? 0}G'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await gameProvider.purchaseItem(item);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'アイテムを購入しました！' : '購入に失敗しました'),
                  backgroundColor: success ? Colors.green[600] : Colors.red[600],
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
            child: Text('購入'),
          ),
        ],
      ),
    );
  }
}

// Shop Item Model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int price;
  final String type; // 'weapon', 'armor', 'accessory', 'consumable'

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'price': price,
      'type': type,
    };
  }

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      price: map['price']?.toInt() ?? 0,
      type: map['type'] ?? '',
    );
  }
}

// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int goldReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    this.goldReward = 0,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? goldReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      goldReward: goldReward ?? this.goldReward,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'goldReward': goldReward,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      goldReward: map['goldReward']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory Achievement.fromJson(String source) => Achievement.fromMap(json.decode(source));
}

// Achievement Screen
class AchievementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final unlockedCount = gameProvider.unlockedAchievementsCount;
        final totalCount = gameProvider.achievements.length;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('🏆 実績'),
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
                // ヘッダー
                Container(
                  margin: EdgeInsets.all(16),
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
                        '🏆 実績システム',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '様々な条件を達成して実績を解除しよう！\n実績を解除するとゴールドがもらえます。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '進捗: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '$unlockedCount/$totalCount',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(${((unlockedCount / totalCount) * 100).toInt()}%)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // 進捗バー
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: unlockedCount / totalCount,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 実績リスト
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gameProvider.achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = gameProvider.achievements[index];
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? Colors.amber[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: achievement.isUnlocked 
                              ? Border.all(color: Colors.amber[300]!, width: 1)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: achievement.isUnlocked 
                                  ? Colors.amber.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                achievement.isUnlocked ? achievement.icon : '🔒',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: achievement.isUnlocked ? Colors.amber[800] : Colors.grey[600],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                achievement.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.monetization_on, 
                                       color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '報酬: ${achievement.goldReward}G',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                  Spacer(),
                                  if (achievement.isUnlocked && achievement.unlockedAt != null)
                                    Text(
                                      '解除日: ${achievement.unlockedAt!.month}/${achievement.unlockedAt!.day}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: achievement.isUnlocked
                              ? Icon(Icons.check_circle, color: Colors.amber, size: 32)
                              : Icon(Icons.lock, color: Colors.grey, size: 32),
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
}

// Task Model (Extended)
class Task {
  final String id;
  final String title;
  final String difficulty;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.difficulty,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
  });

  factory Task.create(String title, String difficulty, {DateTime? dueDate}) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      difficulty: difficulty,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && now.month == due.month && now.day == due.day;
  }

  Task copyWith({
    String? id,
    String? title,
    String? difficulty,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
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
      'dueDate': dueDate?.toIso8601String(),
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
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
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
  final int gold;
  final List<String> purchasedItems;
  final DateTime createdAt;

  Character({
    required this.id,
    required this.profession,
    required this.name,
    this.level = 1,
    this.experience = 0,
    this.gold = 100, // 初期ゴールド
    this.purchasedItems = const [],
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
    int? gold,
    List<String>? purchasedItems,
    DateTime? createdAt,
  }) {
    return Character(
      id: id ?? this.id,
      profession: profession ?? this.profession,
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      gold: gold ?? this.gold,
      purchasedItems: purchasedItems ?? this.purchasedItems,
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
      'gold': gold,
      'purchasedItems': purchasedItems,
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
      gold: map['gold']?.toInt() ?? 100,
      purchasedItems: List<String>.from(map['purchasedItems'] ?? []),
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
  List<Achievement> _achievements = [];
  List<Quest> _quests = [];
  List<PomodoroSession> _pomodoroSessions = [];
  bool _isLoading = false;

  Character? get character => _character;
  List<Task> get tasks => _tasks;
  List<Achievement> get achievements => _achievements;
  List<Quest> get quests => _quests;
  List<PomodoroSession> get pomodoroSessions => _pomodoroSessions;
  bool get isLoading => _isLoading;
  bool get hasCharacter => _character != null;

  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;
  int get totalTasksCount => _tasks.length;
  int get unlockedAchievementsCount => _achievements.where((a) => a.isUnlocked).length;

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final due = task.dueDate!;
      return due.year == today.year && due.month == today.month && due.day == today.day;
    }).toList();
  }

  List<Task> get overdueTasks => _tasks.where((task) => task.isOverdue).toList();

  final Map<String, int> _difficultyExp = {
    'easy': 10,
    'normal': 25,
    'hard': 50,
  };

  final Map<String, int> _difficultyGold = {
    'easy': 5,
    'normal': 15,
    'hard': 30,
  };

  // ショップアイテム
  final List<ShopItem> _shopItems = [
    ShopItem(
      id: 'sword_basic',
      name: '鉄の剣',
      description: '基本的な戦士の武器\n攻撃力+5',
      icon: '⚔️',
      price: 50,
      type: 'weapon',
    ),
    ShopItem(
      id: 'staff_basic',
      name: '魔法の杖',
      description: '魔法使いの基本杖\n魔力+5',
      icon: '🪄',
      price: 50,
      type: 'weapon',
    ),
    ShopItem(
      id: 'dagger_basic',
      name: '盗賊の短剣',
      description: '素早い攻撃が可能\n敏捷性+5',
      icon: '🗡️',
      price: 50,
      type: 'weapon',
    ),
    ShopItem(
      id: 'shield_basic',
      name: '木の盾',
      description: '基本的な防具\n防御力+3',
      icon: '🛡️',
      price: 30,
      type: 'armor',
    ),
    ShopItem(
      id: 'potion_health',
      name: '回復ポーション',
      description: 'HPを回復する\n体力+10',
      icon: '🧪',
      price: 20,
      type: 'consumable',
    ),
    ShopItem(
      id: 'ring_exp',
      name: '経験値の指輪',
      description: '経験値獲得量+20%\n知恵+3',
      icon: '💍',
      price: 100,
      type: 'accessory',
    ),
  ];

  List<ShopItem> get shopItems => _shopItems;

  // 初期クエスト設定
  void _initializeQuests() {
    if (_quests.isEmpty) {
      _quests = [
        Quest.create(
          'スライム討伐',
          '森に出現したスライムを倒してください',
          'easy',
          boss: Boss.create('スライム', '🟢', 1),
        ),
        Quest.create(
          'ゴブリン退治',
          '村を襲うゴブリンを退治してください',
          'normal',
          boss: Boss.create('ゴブリン', '👹', 2),
        ),
        Quest.create(
          'ドラゴン討伐',
          '伝説のドラゴンを討伐してください',
          'hard',
          boss: Boss.create('ドラゴン', '🐉', 5),
        ),
        Quest.create(
          '古代遺跡の探索',
          '古代遺跡を探索して宝物を見つけてください',
          'normal',
        ),
        Quest.create(
          '薬草採集',
          '山で薬草を10個採集してください',
          'easy',
        ),
      ];
    }
  }

  // 初期アチーブメント
  void _initializeAchievements() {
    _achievements = [
      Achievement(
        id: 'first_task',
        title: '初心者',
        description: '最初のタスクを完了',
        icon: '🌟',
        goldReward: 10,
      ),
      Achievement(
        id: 'level_5',
        title: 'レベル5到達',
        description: 'レベル5に到達',
        icon: '🏆',
        goldReward: 50,
      ),
      Achievement(
        id: 'task_10',
        title: 'タスクマスター',
        description: '10個のタスクを完了',
        icon: '📋',
        goldReward: 30,
      ),
      Achievement(
        id: 'week_streak',
        title: '継続の力',
        description: '7日連続でタスクを完了',
        icon: '🔥',
        goldReward: 100,
      ),
      Achievement(
        id: 'hard_task_5',
        title: '困難を乗り越えて',
        description: '難易度ハードのタスクを5個完了',
        icon: '💪',
        goldReward: 75,
      ),
      Achievement(
        id: 'first_purchase',
        title: '初回購入',
        description: '初めてアイテムを購入',
        icon: '💰',
        goldReward: 20,
      ),
      Achievement(
        id: 'first_quest',
        title: '冒険者',
        description: '初めてクエストを完了',
        icon: '🗺️',
        goldReward: 25,
      ),
      Achievement(
        id: 'boss_slayer',
        title: 'ボススレイヤー',
        description: 'ボスを倒してクエストを完了',
        icon: '⚔️',
        goldReward: 50,
      ),
      Achievement(
        id: 'pomodoro_master',
        title: 'ポモドーロマスター',
        description: 'ポモドーロセッションを10回完了',
        icon: '🍅',
        goldReward: 30,
      ),
    ];
  }

  // 初期化
  Future<void> initialize() async {
    print('🔍 GameProvider初期化開始...');
    _isLoading = true;
    notifyListeners();

    try {
      // アチーブメント初期化
      _initializeAchievements();
      
      // クエスト初期化
      _initializeQuests();
      
      // プラットフォーム対応ストレージからデータを読み込み
      String? characterJson;
      List<String> tasksJson = [];
      List<String> achievementsJson = [];
      List<String> questsJson = [];
      List<String> pomodoroJson = [];
      
      try {
        print('📱 PlatformStorage からデータ読み込み開始...');
        
        characterJson = await PlatformStorage.getString('taskquest_character');
        tasksJson = await PlatformStorage.getStringList('taskquest_tasks');
        achievementsJson = await PlatformStorage.getStringList('taskquest_achievements');
        questsJson = await PlatformStorage.getStringList('taskquest_quests');
        pomodoroJson = await PlatformStorage.getStringList('taskquest_pomodoro');
        
        print('📖 読み込み結果 - キャラクター: ${characterJson != null ? "あり" : "なし"}');
        print('📖 読み込み結果 - タスク: ${tasksJson.length}件');
        print('📖 読み込み結果 - アチーブメント: ${achievementsJson.length}件');
        print('📖 読み込み結果 - クエスト: ${questsJson.length}件');
        print('📖 読み込み結果 - ポモドーロ: ${pomodoroJson.length}件');
      } catch (e) {
        print('⚠️ PlatformStorage エラー: $e');
      }
      
      // キャラクター読み込み
      if (characterJson != null && characterJson.isNotEmpty) {
        try {
          _character = Character.fromJson(characterJson);
          print('✅ キャラクター読み込み成功: ${_character?.name} (${_character?.profession})');
        } catch (e) {
          print('❌ キャラクターデータ解析エラー: $e');
          // 破損したデータをクリア
          await _clearAllData();
        }
      } else {
        print('📭 保存されたキャラクターデータがありません');
      }
      
      // タスク読み込み
      print('📖 保存されたタスクデータ: ${tasksJson.length}件');
      
      try {
        _tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
        print('✅ タスク読み込み成功: ${_tasks.length}件');
      } catch (e) {
        print('❌ タスクデータ解析エラー: $e');
        _tasks = [];
        // 破損したデータをクリア
        await _clearAllData();
      }

      // アチーブメント読み込み
      if (achievementsJson.isNotEmpty) {
        try {
          final savedAchievements = achievementsJson.map((json) => Achievement.fromJson(json)).toList();
          // 保存されたアチーブメントの状態を適用
          for (var saved in savedAchievements) {
            final index = _achievements.indexWhere((a) => a.id == saved.id);
            if (index != -1) {
              _achievements[index] = saved;
            }
          }
          print('✅ アチーブメント読み込み成功: ${_achievements.where((a) => a.isUnlocked).length}/${_achievements.length}件解除済み');
        } catch (e) {
          print('❌ アチーブメントデータ解析エラー: $e');
        }
      }

      // クエスト読み込み
      if (questsJson.isNotEmpty) {
        try {
          final savedQuests = questsJson.map((json) => Quest.fromJson(json)).toList();
          // 保存されたクエストの状態を適用
          for (var saved in savedQuests) {
            final index = _quests.indexWhere((q) => q.id == saved.id);
            if (index != -1) {
              _quests[index] = saved;
            } else {
              _quests.add(saved);
            }
          }
          print('✅ クエスト読み込み成功: ${_quests.where((q) => q.isCompleted).length}/${_quests.length}件完了済み');
        } catch (e) {
          print('❌ クエストデータ解析エラー: $e');
        }
      }

      // ポモドーロセッション読み込み
      if (pomodoroJson.isNotEmpty) {
        try {
          _pomodoroSessions = pomodoroJson.map((json) => PomodoroSession.fromJson(json)).toList();
          print('✅ ポモドーロセッション読み込み成功: ${_pomodoroSessions.length}件');
        } catch (e) {
          print('❌ ポモドーロデータ解析エラー: $e');
          _pomodoroSessions = [];
        }
      }
      
      print('🎯 初期化完了 - キャラクター: ${_character != null ? "あり" : "なし"}, タスク: ${_tasks.length}件, アチーブメント: ${unlockedAchievementsCount}/${_achievements.length}件, クエスト: ${_quests.length}件, ポモドーロ: ${_pomodoroSessions.length}件');
      
    } catch (e) {
      print('❌ 初期化エラー: $e');
      _character = null;
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // キャラクター作成
  Future<void> createCharacter(String profession, String name) async {
    print('🎭 キャラクター作成開始: $name ($profession)');
    
    try {
      _character = Character.create(profession, name);
      print('✅ キャラクターオブジェクト作成成功: ${_character?.toJson()}');
      
      await _saveCharacter();
      print('💾 キャラクターデータ保存完了');
      
      notifyListeners();
      print('🔄 UI更新通知完了');
      
    } catch (e) {
      print('❌ キャラクター作成エラー: $e');
      rethrow;
    }
  }

  // タスク追加
  Future<void> addTask(String title, String difficulty, {DateTime? dueDate}) async {
    print('➕ タスク追加: $title ($difficulty) - 期限: ${dueDate?.toString() ?? "なし"}');
    
    try {
      final task = Task.create(title, difficulty, dueDate: dueDate);
      _tasks.add(task);
      await _saveTasks();
      notifyListeners();
      print('✅ タスク追加完了');
    } catch (e) {
      print('❌ タスク追加エラー: $e');
      rethrow;
    }
  }

  // タスク完了
  Future<void> completeTask(Task task) async {
    print('✅ タスク完了: ${task.title}');
    
    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        
        // 経験値獲得
        final expGained = _difficultyExp[task.difficulty] ?? 0;
        _gainExperience(expGained);
        
        // ゴールド獲得
        final goldGained = _difficultyGold[task.difficulty] ?? 0;
        _gainGold(goldGained);
        
        // アチーブメントチェック
        _checkAchievements();
        
        await _saveTasks();
        await _saveCharacter();
        await _saveAchievements();
        notifyListeners();
        print('✅ タスク完了処理完了');
      }
    } catch (e) {
      print('❌ タスク完了エラー: $e');
      rethrow;
    }
  }

  // タスク削除
  Future<void> deleteTask(Task task) async {
    print('🗑️ タスク削除: ${task.title}');
    
    try {
      _tasks.removeWhere((t) => t.id == task.id);
      await _saveTasks();
      notifyListeners();
      print('✅ タスク削除完了');
    } catch (e) {
      print('❌ タスク削除エラー: $e');
      rethrow;
    }
  }

  // 経験値獲得
  void _gainExperience(int exp) {
    if (_character == null) return;
    
    print('⭐ 経験値獲得: +${exp}XP');
    
    int newExp = _character!.experience + exp;
    int newLevel = _character!.level;
    int levelUps = 0;
    
    // レベルアップチェック
    while (newExp >= newLevel * 100) {
      newExp -= newLevel * 100;
      newLevel++;
      levelUps++;
    }
    
    if (levelUps > 0) {
      print('🎉 レベルアップ! ${_character!.level} → $newLevel (${levelUps}回)');
    }
    
    _character = _character!.copyWith(
      experience: newExp,
      level: newLevel,
    );
  }

  // ゴールド獲得
  void _gainGold(int gold) {
    if (_character == null) return;
    
    print('💰 ゴールド獲得: +${gold}G');
    
    _character = _character!.copyWith(
      gold: _character!.gold + gold,
    );
  }

  // アチーブメントチェック
  void _checkAchievements() {
    if (_character == null) return;
    
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();
    final hardCompletedTasks = completedTasks.where((t) => t.difficulty == 'hard').length;
    final completedQuests = _quests.where((q) => q.isCompleted).toList();
    final completedBossQuests = completedQuests.where((q) => q.boss != null).length;
    final completedPomodoroSessions = _pomodoroSessions.where((s) => s.isCompleted).length;
    
    for (int i = 0; i < _achievements.length; i++) {
      if (_achievements[i].isUnlocked) continue;
      
      bool shouldUnlock = false;
      
      switch (_achievements[i].id) {
        case 'first_task':
          shouldUnlock = completedTasks.isNotEmpty;
          break;
        case 'level_5':
          shouldUnlock = _character!.level >= 5;
          break;
        case 'task_10':
          shouldUnlock = completedTasks.length >= 10;
          break;
        case 'hard_task_5':
          shouldUnlock = hardCompletedTasks >= 5;
          break;
        case 'first_purchase':
          shouldUnlock = _character!.purchasedItems.isNotEmpty;
          break;
        case 'first_quest':
          shouldUnlock = completedQuests.isNotEmpty;
          break;
        case 'boss_slayer':
          shouldUnlock = completedBossQuests > 0;
          break;
        case 'pomodoro_master':
          shouldUnlock = completedPomodoroSessions >= 10;
          break;
        case 'week_streak':
          // 簡単な実装：7日間で7つのタスクを完了
          final recentTasks = completedTasks.where((t) {
            final daysDiff = DateTime.now().difference(t.completedAt!).inDays;
            return daysDiff <= 7;
          });
          shouldUnlock = recentTasks.length >= 7;
          break;
      }
      
      if (shouldUnlock) {
        _achievements[i] = _achievements[i].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        
        // 報酬ゴールド付与
        _gainGold(_achievements[i].goldReward);
        
        print('🏆 アチーブメント解除: ${_achievements[i].title} (+${_achievements[i].goldReward}G)');
      }
    }
  }

  // ショップアイテム購入
  Future<bool> purchaseItem(ShopItem item) async {
    if (_character == null) return false;
    if (_character!.gold < item.price) return false;
    if (_character!.purchasedItems.contains(item.id)) return false;
    
    try {
      _character = _character!.copyWith(
        gold: _character!.gold - item.price,
        purchasedItems: [..._character!.purchasedItems, item.id],
      );
      
      // アチーブメントチェック
      _checkAchievements();
      
      await _saveCharacter();
      await _saveAchievements();
      notifyListeners();
      
      print('🛒 アイテム購入: ${item.name} (-${item.price}G)');
      return true;
    } catch (e) {
      print('❌ アイテム購入エラー: $e');
      return false;
    }
  }

  // 日付別タスク取得
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final due = task.dueDate!;
      return due.year == date.year && due.month == date.month && due.day == date.day;
    }).toList();
  }

  // クエスト完了
  Future<void> completeQuest(Quest quest) async {
    print('🏆 クエスト完了: ${quest.title}');
    
    try {
      final index = _quests.indexWhere((q) => q.id == quest.id);
      if (index != -1) {
        _quests[index] = quest.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        
        // 報酬獲得
        _gainExperience(quest.expReward);
        _gainGold(quest.goldReward);
        
        await _saveQuests();
        await _saveCharacter();
        
        // アチーブメントチェック（保存後に実行）
        _checkAchievements();
        await _saveAchievements();
        notifyListeners();
        print('✅ クエスト完了処理完了');
      }
    } catch (e) {
      print('❌ クエスト完了エラー: $e');
      rethrow;
    }
  }

  // ボス戦闘
  Future<bool> fightBoss(Quest quest, String action) async {
    if (quest.boss == null || _character == null) return false;
    
    final boss = quest.boss!;
    final character = _character!;
    final random = Random();
    
    int damage = 0;
    
    switch (action) {
      case '攻撃':
        damage = (character.level * 10) + random.nextInt(20);
        break;
      case '強攻撃':
        damage = (character.level * 15) + random.nextInt(30);
        break;
      case '魔法攻撃':
        damage = (character.level * 12) + random.nextInt(25);
        break;
      default:
        damage = character.level * 8;
    }
    
    // ボスにダメージを与える
    final newHp = (boss.currentHp - damage).clamp(0, boss.maxHp);
    final updatedBoss = boss.copyWith(
      currentHp: newHp,
      isDefeated: newHp <= 0,
    );
    
    // クエストを更新
    final index = _quests.indexWhere((q) => q.id == quest.id);
    if (index != -1) {
      _quests[index] = quest.copyWith(boss: updatedBoss);
      await _saveQuests();
      notifyListeners();
    }
    
    print('⚔️ ボス戦闘: ${boss.name}に${damage}ダメージ (残りHP: ${newHp}/${boss.maxHp})');
    
    return updatedBoss.isDefeated;
  }

  // ポモドーロセッション開始
  Future<void> startPomodoroSession({String? taskId}) async {
    final session = PomodoroSession.create(taskId: taskId);
    _pomodoroSessions.add(session);
    await _savePomodoroSessions();
    notifyListeners();
    print('🍅 ポモドーロセッション開始: ${session.id}');
  }

  // ポモドーロセッション完了
  Future<void> completePomodoroSession(String sessionId) async {
    final index = _pomodoroSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _pomodoroSessions[index] = _pomodoroSessions[index].copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
        completedCycles: _pomodoroSessions[index].completedCycles + 1,
      );
      
      // ポモドーロ完了報酬
      _gainExperience(15);
      _gainGold(5);
      
      await _savePomodoroSessions();
      await _saveCharacter();
      notifyListeners();
      print('✅ ポモドーロセッション完了: $sessionId');
    }
  }

  // データ保存
  Future<void> _saveCharacter() async {
    if (_character == null) {
      print('⚠️ 保存するキャラクターがありません');
      return;
    }
    
    try {
      final characterJson = _character!.toJson();
      
      // PlatformStorageに保存
      try {
        final success = await PlatformStorage.setString('taskquest_character', characterJson);
        print('💾 PlatformStorage キャラクター保存: ${success ? "成功" : "失敗"}');
      } catch (e) {
        print('⚠️ PlatformStorage 保存エラー: $e');
      }
      
      print('✅ キャラクターデータ保存完了 - $characterJson');
      
    } catch (e) {
      print('❌ キャラクター保存エラー: $e');
      rethrow;
    }
  }

  Future<void> _saveTasks() async {
    try {
      final tasksJson = _tasks.map((task) => task.toJson()).toList();
      
      // PlatformStorageに保存
      try {
        final success = await PlatformStorage.setStringList('taskquest_tasks', tasksJson);
        print('💾 PlatformStorage タスク保存: ${success ? "成功" : "失敗"} - ${tasksJson.length}件');
      } catch (e) {
        print('⚠️ PlatformStorage タスク保存エラー: $e');
      }
      
    } catch (e) {
      print('❌ タスク保存エラー: $e');
      rethrow;
    }
  }

  Future<void> _saveAchievements() async {
    try {
      final achievementsJson = _achievements.map((achievement) => achievement.toJson()).toList();
      
      // PlatformStorageに保存
      try {
        final success = await PlatformStorage.setStringList('taskquest_achievements', achievementsJson);
        print('💾 PlatformStorage アチーブメント保存: ${success ? "成功" : "失敗"} - ${achievementsJson.length}件');
      } catch (e) {
        print('⚠️ PlatformStorage アチーブメント保存エラー: $e');
      }
      
    } catch (e) {
      print('❌ アチーブメント保存エラー: $e');
      rethrow;
    }
  }

  Future<void> _saveQuests() async {
    try {
      final questsJson = _quests.map((quest) => quest.toJson()).toList();
      
      // PlatformStorageに保存
      try {
        final success = await PlatformStorage.setStringList('taskquest_quests', questsJson);
        print('💾 PlatformStorage クエスト保存: ${success ? "成功" : "失敗"} - ${questsJson.length}件');
      } catch (e) {
        print('⚠️ PlatformStorage クエスト保存エラー: $e');
      }
      
    } catch (e) {
      print('❌ クエスト保存エラー: $e');
      rethrow;
    }
  }

  Future<void> _savePomodoroSessions() async {
    try {
      final pomodoroJson = _pomodoroSessions.map((session) => session.toJson()).toList();
      
      // PlatformStorageに保存
      try {
        final success = await PlatformStorage.setStringList('taskquest_pomodoro', pomodoroJson);
        print('💾 PlatformStorage ポモドーロ保存: ${success ? "成功" : "失敗"} - ${pomodoroJson.length}件');
      } catch (e) {
        print('⚠️ PlatformStorage ポモドーロ保存エラー: $e');
      }
      
    } catch (e) {
      print('❌ ポモドーロ保存エラー: $e');
      rethrow;
    }
  }

  // デバッグ用：データリセット機能
  Future<void> resetAllData() async {
    print('🔄 全データリセット開始...');
    
    try {
      // PlatformStorageクリア
      try {
        await PlatformStorage.remove('taskquest_character');
        await PlatformStorage.remove('taskquest_tasks');
        await PlatformStorage.remove('taskquest_achievements');
        await PlatformStorage.remove('taskquest_quests');
        await PlatformStorage.remove('taskquest_pomodoro');
        print('🗑️ PlatformStorage クリア完了');
      } catch (e) {
        print('⚠️ PlatformStorage クリアエラー: $e');
      }
      
      _character = null;
      _tasks = [];
      _pomodoroSessions = [];
      _initializeAchievements(); // アチーブメントを初期状態に戻す
      _initializeQuests(); // クエストを初期状態に戻す
      notifyListeners();
      
      print('✅ 全データリセット完了');
    } catch (e) {
      print('❌ データリセットエラー: $e');
    }
  }

  Future<void> _clearAllData() async {
    await resetAllData();
  }
}

// Quest System Models
class Quest {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int expReward;
  final int goldReward;
  final String icon;
  final List<String> requirements;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final Boss? boss; // ボス戦があるクエスト

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.expReward,
    required this.goldReward,
    required this.icon,
    this.requirements = const [],
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.boss,
  });

  factory Quest.create(String title, String description, String difficulty, {Boss? boss}) {
    final expRewards = {'easy': 50, 'normal': 100, 'hard': 200};
    final goldRewards = {'easy': 25, 'normal': 50, 'hard': 100};
    final icons = {'easy': '📜', 'normal': '⚔️', 'hard': '🏆'};
    
    return Quest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      difficulty: difficulty,
      expReward: expRewards[difficulty] ?? 100,
      goldReward: goldRewards[difficulty] ?? 50,
      icon: icons[difficulty] ?? '📜',
      createdAt: DateTime.now(),
      boss: boss,
    );
  }

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    int? expReward,
    int? goldReward,
    String? icon,
    List<String>? requirements,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    Boss? boss,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      icon: icon ?? this.icon,
      requirements: requirements ?? this.requirements,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      boss: boss ?? this.boss,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'expReward': expReward,
      'goldReward': goldReward,
      'icon': icon,
      'requirements': requirements,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'boss': boss?.toMap(),
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'normal',
      expReward: map['expReward']?.toInt() ?? 100,
      goldReward: map['goldReward']?.toInt() ?? 50,
      icon: map['icon'] ?? '📜',
      requirements: List<String>.from(map['requirements'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      boss: map['boss'] != null ? Boss.fromMap(map['boss']) : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory Quest.fromJson(String source) => Quest.fromMap(json.decode(source));
}

// Boss Model
class Boss {
  final String id;
  final String name;
  final String icon;
  final int maxHp;
  final int currentHp;
  final int attack;
  final int defense;
  final List<String> skills;
  final bool isDefeated;

  Boss({
    required this.id,
    required this.name,
    required this.icon,
    required this.maxHp,
    required this.currentHp,
    required this.attack,
    required this.defense,
    this.skills = const [],
    this.isDefeated = false,
  });

  factory Boss.create(String name, String icon, int level) {
    final hp = 100 + (level * 50);
    return Boss(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      maxHp: hp,
      currentHp: hp,
      attack: 10 + (level * 5),
      defense: 5 + (level * 2),
      skills: ['通常攻撃', '強攻撃', '防御'],
    );
  }

  Boss copyWith({
    String? id,
    String? name,
    String? icon,
    int? maxHp,
    int? currentHp,
    int? attack,
    int? defense,
    List<String>? skills,
    bool? isDefeated,
  }) {
    return Boss(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      skills: skills ?? this.skills,
      isDefeated: isDefeated ?? this.isDefeated,
    );
  }

  double get hpPercentage => currentHp / maxHp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'attack': attack,
      'defense': defense,
      'skills': skills,
      'isDefeated': isDefeated,
    };
  }

  factory Boss.fromMap(Map<String, dynamic> map) {
    return Boss(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '👹',
      maxHp: map['maxHp']?.toInt() ?? 100,
      currentHp: map['currentHp']?.toInt() ?? 100,
      attack: map['attack']?.toInt() ?? 10,
      defense: map['defense']?.toInt() ?? 5,
      skills: List<String>.from(map['skills'] ?? []),
      isDefeated: map['isDefeated'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory Boss.fromJson(String source) => Boss.fromMap(json.decode(source));
}

// Pomodoro Session Model
class PomodoroSession {
  final String id;
  final int workMinutes;
  final int breakMinutes;
  final int completedCycles;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String? taskId; // 関連するタスクID

  PomodoroSession({
    required this.id,
    this.workMinutes = 25,
    this.breakMinutes = 5,
    this.completedCycles = 0,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.taskId,
  });

  factory PomodoroSession.create({String? taskId}) {
    return PomodoroSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      taskId: taskId,
    );
  }

  PomodoroSession copyWith({
    String? id,
    int? workMinutes,
    int? breakMinutes,
    int? completedCycles,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? taskId,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      workMinutes: workMinutes ?? this.workMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      completedCycles: completedCycles ?? this.completedCycles,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      taskId: taskId ?? this.taskId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workMinutes': workMinutes,
      'breakMinutes': breakMinutes,
      'completedCycles': completedCycles,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'taskId': taskId,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'] ?? '',
      workMinutes: map['workMinutes']?.toInt() ?? 25,
      breakMinutes: map['breakMinutes']?.toInt() ?? 5,
      completedCycles: map['completedCycles']?.toInt() ?? 0,
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      isCompleted: map['isCompleted'] ?? false,
      taskId: map['taskId'],
    );
  }

  String toJson() => json.encode(toMap());
  factory PomodoroSession.fromJson(String source) => PomodoroSession.fromMap(json.decode(source));
}

// Quest Screen
class QuestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('🗺️ クエスト'),
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
                // ヘッダー
                Container(
                  margin: EdgeInsets.all(16),
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
                        '⚔️ クエストボード',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'クエストを完了して経験値とゴールドを獲得しよう！\nボス戦があるクエストは戦闘が必要です。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // クエストリスト
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gameProvider.quests.length,
                    itemBuilder: (context, index) {
                      final quest = gameProvider.quests[index];
                      return _buildQuestCard(context, quest, gameProvider);
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

  Widget _buildQuestCard(BuildContext context, Quest quest, GameProvider gameProvider) {
    final difficulties = {
      'easy': {'name': '簡単', 'color': Colors.green},
      'normal': {'name': '普通', 'color': Colors.orange},
      'hard': {'name': '難しい', 'color': Colors.red},
    };
    final difficultyData = difficulties[quest.difficulty] ?? difficulties['normal']!;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: quest.isCompleted 
            ? Border.all(color: Colors.green, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  quest.icon,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: quest.isCompleted ? Colors.green[700] : Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 4),
                                              Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (difficultyData['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            difficultyData['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: difficultyData['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (quest.isCompleted)
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
              ],
            ),
            SizedBox(height: 12),
            Text(
              quest.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '+${quest.expReward}XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '+${quest.goldReward}G',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (quest.boss != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          quest.boss!.icon,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 8),
                        Text(
                          quest.boss!.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${quest.boss!.currentHp}/${quest.boss!.maxHp}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: quest.boss!.hpPercentage,
                      backgroundColor: Colors.red[100],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: quest.isCompleted 
                    ? null 
                    : () => _handleQuestAction(context, quest, gameProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: quest.isCompleted ? Colors.grey : Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  quest.isCompleted 
                      ? '完了済み'
                      : quest.boss != null 
                          ? quest.boss!.isDefeated 
                              ? 'クエスト完了'
                              : 'ボス戦闘'
                          : 'クエスト完了',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuestAction(BuildContext context, Quest quest, GameProvider gameProvider) {
    if (quest.boss != null && !quest.boss!.isDefeated) {
      _showBossBattleDialog(context, quest, gameProvider);
    } else {
      _completeQuest(context, quest, gameProvider);
    }
  }

  void _showBossBattleDialog(BuildContext context, Quest quest, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚔️ ボス戦闘'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${quest.boss!.icon} ${quest.boss!.name}'),
            SizedBox(height: 8),
            Text('HP: ${quest.boss!.currentHp}/${quest.boss!.maxHp}'),
            SizedBox(height: 16),
            Text('攻撃方法を選択してください：'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => _performBossAttack(context, quest, gameProvider, '攻撃'),
            child: Text('攻撃'),
          ),
          TextButton(
            onPressed: () => _performBossAttack(context, quest, gameProvider, '強攻撃'),
            child: Text('強攻撃'),
          ),
          TextButton(
            onPressed: () => _performBossAttack(context, quest, gameProvider, '魔法攻撃'),
            child: Text('魔法攻撃'),
          ),
        ],
      ),
    );
  }

  void _performBossAttack(BuildContext context, Quest quest, GameProvider gameProvider, String action) async {
    Navigator.pop(context);
    
    final isDefeated = await gameProvider.fightBoss(quest, action);
    
    if (isDefeated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${quest.boss!.name}を倒しました！クエストを完了できます。'),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚔️ ${quest.boss!.name}に攻撃しました！'),
          backgroundColor: Colors.orange[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _completeQuest(BuildContext context, Quest quest, GameProvider gameProvider) async {
    await gameProvider.completeQuest(quest);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🏆 クエスト「${quest.title}」を完了しました！ +${quest.expReward}XP +${quest.goldReward}G'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Pomodoro Screen
class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final CountDownController _controller = CountDownController();
  bool _isRunning = false;
  bool _isWorkTime = true;
  int _workMinutes = 25;
  int _breakMinutes = 5;
  int _completedCycles = 0;
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('🍅 ポモドーロタイマー'),
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
                  // ヘッダー
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
                          '🍅 ポモドーロテクニック',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '25分集中 → 5分休憩のサイクルで\n効率的に作業を進めましょう！',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // タイマー設定
                  if (!_isRunning) ...[
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
                            '⚙️ タイマー設定',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('作業時間'),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_workMinutes > 5) _workMinutes -= 5;
                                            });
                                          },
                                          icon: Icon(Icons.remove),
                                        ),
                                        Text(
                                          '${_workMinutes}分',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_workMinutes < 60) _workMinutes += 5;
                                            });
                                          },
                                          icon: Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('休憩時間'),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_breakMinutes > 1) _breakMinutes -= 1;
                                            });
                                          },
                                          icon: Icon(Icons.remove),
                                        ),
                                        Text(
                                          '${_breakMinutes}分',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_breakMinutes < 30) _breakMinutes += 1;
                                            });
                                          },
                                          icon: Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // タスク選択
                          if (gameProvider.tasks.where((t) => !t.isCompleted).isNotEmpty) ...[
                            Text(
                              'タスクを選択（オプション）',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButton<String?>(
                              value: _selectedTaskId,
                              hint: Text('タスクを選択'),
                              isExpanded: true,
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('なし'),
                                ),
                                ...gameProvider.tasks
                                    .where((t) => !t.isCompleted)
                                    .map((task) => DropdownMenuItem<String?>(
                                          value: task.id,
                                          child: Text(task.title),
                                        )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedTaskId = value;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                  
                  // タイマー表示
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
                          _isWorkTime ? '🎯 作業時間' : '☕ 休憩時間',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _isWorkTime ? Colors.red[600] : Colors.green[600],
                          ),
                        ),
                        SizedBox(height: 20),
                        CircularCountDownTimer(
                          duration: (_isWorkTime ? _workMinutes : _breakMinutes) * 60,
                          initialDuration: 0,
                          controller: _controller,
                          width: 200,
                          height: 200,
                          ringColor: Colors.grey[300]!,
                          fillColor: _isWorkTime ? Colors.red[400]! : Colors.green[400]!,
                          backgroundColor: Colors.white,
                          strokeWidth: 20.0,
                          strokeCap: StrokeCap.round,
                          textStyle: TextStyle(
                            fontSize: 32.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textFormat: CountdownTextFormat.MM_SS,
                          isReverse: true,
                          isReverseAnimation: true,
                          isTimerTextShown: true,
                          autoStart: false,
                          onStart: () {
                            setState(() {
                              _isRunning = true;
                            });
                          },
                          onComplete: () {
                            _onTimerComplete(gameProvider);
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_isRunning) {
                                  _controller.pause();
                                } else {
                                  _controller.start();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRunning ? Colors.orange : Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(_isRunning ? '一時停止' : '開始'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _controller.reset();
                                setState(() {
                                  _isRunning = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('リセット'),
                            ),
                          ],
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
                          '📊 今日の統計',
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
                            _buildStatCard('完了サイクル', '$_completedCycles', Colors.green),
                            _buildStatCard('総セッション', '${gameProvider.pomodoroSessions.length}', Colors.blue),
                            _buildStatCard('今日完了', '${gameProvider.pomodoroSessions.where((s) => s.isCompleted && _isToday(s.startTime)).length}', Colors.orange),
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
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _onTimerComplete(GameProvider gameProvider) async {
    setState(() {
      _isRunning = false;
    });

    if (_isWorkTime) {
      // 作業時間完了
      _completedCycles++;
      
      // 実際のポモドーロセッションを作成・完了
      await gameProvider.startPomodoroSession(taskId: _selectedTaskId);
      final sessions = gameProvider.pomodoroSessions;
      if (sessions.isNotEmpty) {
        await gameProvider.completePomodoroSession(sessions.last.id);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 作業時間完了！お疲れ様でした。+15XP +5G獲得！'),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 3),
        ),
      );
      
      // 休憩時間に切り替え
      setState(() {
        _isWorkTime = false;
      });
      
      _showBreakDialog();
    } else {
      // 休憩時間完了
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('☕ 休憩時間終了！次の作業を始めましょう。'),
          backgroundColor: Colors.blue[600],
          duration: Duration(seconds: 2),
        ),
      );
      
      // 作業時間に切り替え
      setState(() {
        _isWorkTime = true;
      });
    }
  }

  void _showBreakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 作業完了！'),
        content: Text('お疲れ様でした！${_breakMinutes}分間休憩しましょう。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.start();
            },
            child: Text('休憩開始'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isWorkTime = true;
              });
            },
            child: Text('スキップ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // CountDownControllerにはdisposeメソッドがないため削除
    super.dispose();
  }
}

