import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const MyApp(),
    ),
  );
}

enum Mood { happy, sad, excited }

enum ThemePack { classic, dark, pastel }

class MoodModel with ChangeNotifier {
  Mood _currentMood = Mood.happy;
  Color _backgroundColor = Colors.yellow;
  final Map<String, int> _counts = {
    'Happy': 0,
    'Sad': 0,
    'Excited': 0,
  };

  final List<String> _history = [];

  final Random _rand = Random();

  Mood get currentMood => _currentMood;
  Color get backgroundColor => _backgroundColor;
  Map<String, int> get counts => Map<String, int>.from(_counts);
  List<String> get history => List<String>.unmodifiable(_history);

  String get currentMoodLabel {
    switch (_currentMood) {
      case Mood.happy:
        return 'Happy';
      case Mood.sad:
        return 'Sad';
      case Mood.excited:
        return 'Excited';
    }
  }

  String get currentImageAsset {
    switch (_currentMood) {
      case Mood.happy:
        return 'assets/happy.png';
      case Mood.sad:
        return 'assets/sad.png';
      case Mood.excited:
        return 'assets/excited.png';
    }
  }

  String getEmojiFor(Mood m) {
    switch (m) {
      case Mood.happy:
        return '😊';
      case Mood.sad:
        return '😢';
      case Mood.excited:
        return '🎉';
    }
  }

  void _pushHistory(String item) {
    _history.insert(0, item);
    if (_history.length > 3) {
      _history.removeLast();
    }
  }

  void setHappy({bool fromRandom = false}) {
    _currentMood = Mood.happy;
    _backgroundColor = Colors.yellow;
    _counts['Happy'] = (_counts['Happy'] ?? 0) + 1;

    final entry = (fromRandom ? '🤪 ' : '') + '${getEmojiFor(Mood.happy)} Happy';
    _pushHistory(entry);

    notifyListeners();
  }

  void setSad({bool fromRandom = false}) {
    _currentMood = Mood.sad;
    _backgroundColor = Colors.blue.shade200;
    _counts['Sad'] = (_counts['Sad'] ?? 0) + 1;

    final entry = (fromRandom ? '🤪 ' : '') + '${getEmojiFor(Mood.sad)} Sad';
    _pushHistory(entry);

    notifyListeners();
  }

  void setExcited({bool fromRandom = false}) {
    _currentMood = Mood.excited;
    _backgroundColor = Colors.deepOrangeAccent.shade100;
    _counts['Excited'] = (_counts['Excited'] ?? 0) + 1;

    final entry = (fromRandom ? '🤪 ' : '') + '${getEmojiFor(Mood.excited)} Excited';
    _pushHistory(entry);

    notifyListeners();
  }

  void setRandomMood() {
    final n = _rand.nextInt(3);
    final bool surprise = _rand.nextInt(6) == 0; 
    switch (n) {
      case 0:
        setHappy(fromRandom: surprise);
        break;
      case 1:
        setSad(fromRandom: surprise);
        break;
      case 2:
      default:
        setExcited(fromRandom: surprise);
        break;
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}

class ThemeModel with ChangeNotifier {
  ThemePack _selected = ThemePack.classic;

  ThemePack get selected => _selected;

  void setPack(ThemePack pack) {
    _selected = pack;
    notifyListeners();
  }

  Color adjustBackground(Color moodColor) {
    switch (_selected) {
      case ThemePack.dark:
        return Colors.grey.shade900;
      case ThemePack.pastel:
        return Color.lerp(moodColor, Colors.white, 0.6) ?? moodColor.withOpacity(0.7);
      case ThemePack.classic:
      default:
        return moodColor;
    }
  }

  Color textColorOnBackground(Color moodColor) {
    switch (_selected) {
      case ThemePack.dark:
        return Colors.white;
      case ThemePack.pastel:
        return Colors.black87;
      case ThemePack.classic:
      default:
        return ThemeData.estimateBrightnessForColor(moodColor) == Brightness.dark
            ? Colors.white
            : Colors.black;
    }
  }

  ThemeData appTheme() {
    switch (_selected) {
      case ThemePack.dark:
        return ThemeData.dark().copyWith(useMaterial3: true);
      case ThemePack.pastel:
        return ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.light(primary: Colors.pink.shade200),
        );
      case ThemePack.classic:
      default:
        return ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          primarySwatch: Colors.blue,
        );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeModel>().appTheme();

    return MaterialApp(
      title: 'Mood Toggle Challenge',
      theme: theme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodModel = context.watch<MoodModel>();
    final themeModel = context.watch<ThemeModel>();

    final bgColor = themeModel.adjustBackground(moodModel.backgroundColor);
    final textColor = themeModel.textColorOnBackground(moodModel.backgroundColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Mood Toggle Challenge'),
        backgroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: DefaultTextStyle(
              style: TextStyle(color: textColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Header(),
                  const SizedBox(height: 24),
                  const MoodDisplay(),
                  const SizedBox(height: 20),
                  const MoodButtonsRow(),
                  const SizedBox(height: 16),
                  const RandomAndClearRow(),
                  const SizedBox(height: 20),
                  const MoodCounter(),
                  const SizedBox(height: 18),
                  const MoodHistory(),
                  const SizedBox(height: 22),
                  const ThemeSelector(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'How are you feeling?',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
    );
  }
}

class MoodDisplay extends StatelessWidget {
  const MoodDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final imagePath = moodModel.currentImageAsset;
        final label = moodModel.currentMoodLabel;

        return Column(
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: Colors.black26)
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }
}

class MoodButtonsRow extends StatelessWidget {
  const MoodButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MoodModel>(context, listen: false);

    Widget moodButton({
      required String label,
      required String asset,
      required VoidCallback onPressed,
    }) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 44, height: 44, child: Image.asset(asset, fit: BoxFit.contain)),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 420) {
        return Column(
          children: [
            moodButton(label: 'Happy', asset: 'assets/happy.png', onPressed: model.setHappy),
            const SizedBox(height: 10),
            moodButton(label: 'Sad', asset: 'assets/sad.png', onPressed: model.setSad),
            const SizedBox(height: 10),
            moodButton(label: 'Excited', asset: 'assets/excited.png', onPressed: model.setExcited),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            moodButton(label: 'Happy', asset: 'assets/happy.png', onPressed: model.setHappy),
            moodButton(label: 'Sad', asset: 'assets/sad.png', onPressed: model.setSad),
            moodButton(label: 'Excited', asset: 'assets/excited.png', onPressed: model.setExcited),
          ],
        );
      }
    });
  }
}

class RandomAndClearRow extends StatelessWidget {
  const RandomAndClearRow({super.key});

  @override
  Widget build(BuildContext context) {
    final moodModel = Provider.of<MoodModel>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: moodModel.setRandomMood,
          icon: const Text('🎲'),
          label: const Text('Random Mood'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 6,
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            moodModel.clearHistory();
          },
          icon: const Icon(Icons.clear),
          label: const Text('Clear History'),
        ),
      ],
    );
  }
}

class MoodCounter extends StatelessWidget {
  const MoodCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final counts = moodModel.counts;

        Widget counterCard(String title, int count) {
          return Expanded(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(count.toString(), style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
          );
        }

        return Row(
          children: [
            counterCard('Happy', counts['Happy'] ?? 0),
            const SizedBox(width: 8),
            counterCard('Sad', counts['Sad'] ?? 0),
            const SizedBox(width: 8),
            counterCard('Excited', counts['Excited'] ?? 0),
          ],
        );
      },
    );
  }
}

class MoodHistory extends StatelessWidget {
  const MoodHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final hist = moodModel.history;

        if (hist.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
              child: Text('No history yet', style: TextStyle(color: Theme.of(context).hintColor)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent moods:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: hist.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(entry),
                      backgroundColor: Colors.white.withOpacity(0.8),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final selected = themeModel.selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Theme Pack:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Default'),
              selected: selected == ThemePack.classic,
              onSelected: (_) => themeModel.setPack(ThemePack.classic),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Dark'),
              selected: selected == ThemePack.dark,
              onSelected: (_) => themeModel.setPack(ThemePack.dark),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Pastel'),
              selected: selected == ThemePack.pastel,
              onSelected: (_) => themeModel.setPack(ThemePack.pastel),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Active: ${selected.name}',
          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
