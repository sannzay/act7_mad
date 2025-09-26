import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MoodModel(),
      child: const MyApp(),
    ),
  );
}

enum Mood { happy, sad, excited }

class MoodModel with ChangeNotifier {
  Mood _currentMood = Mood.happy;
  Color _backgroundColor = Colors.yellow;
  final Map<String, int> _counts = {
    'Happy': 0,
    'Sad': 0,
    'Excited': 0,
  };

  Mood get currentMood => _currentMood;
  Color get backgroundColor => _backgroundColor;

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

  Map<String, int> get counts => Map<String, int>.from(_counts);

  void setHappy() {
    _currentMood = Mood.happy;
    _backgroundColor = Colors.yellow;
    _counts['Happy'] = (_counts['Happy'] ?? 0) + 1;
    notifyListeners();
  }

  void setSad() {
    _currentMood = Mood.sad;
    _backgroundColor = Colors.blue.shade200;
    _counts['Sad'] = (_counts['Sad'] ?? 0) + 1;
    notifyListeners();
  }

  void setExcited() {
    _currentMood = Mood.excited;
    _backgroundColor = Colors.deepOrangeAccent.shade100;
    _counts['Excited'] = (_counts['Excited'] ?? 0) + 1;
    notifyListeners();
  }
}

/// Main App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Toggle Challenge',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = context.watch<MoodModel>().backgroundColor;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'How are you feeling?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 24),
                MoodDisplay(),
                SizedBox(height: 28),
                MoodButtons(),
                SizedBox(height: 24),
                MoodCounter(),
              ],
            ),
          ),
        ),
      ),
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

class MoodButtons extends StatelessWidget {
  const MoodButtons({super.key});

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
            SizedBox(
              width: 44,
              height: 44,
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      // if narrow, stack vertically
      if (constraints.maxWidth < 420) {
        return Column(
          mainAxisSize: MainAxisSize.min,
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
              elevation: 4,
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
