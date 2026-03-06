import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyRadioApp());
}

class MyRadioApp extends StatelessWidget {
  const MyRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Radio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RadioHomePage(),
    );
  }
}

class RadioHomePage extends StatefulWidget {
  const RadioHomePage({super.key});

  @override
  State<RadioHomePage> createState() => _RadioHomePageState();
}

class _RadioHomePageState extends State<RadioHomePage> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  // CAMBIA ESTE ENLACE POR EL STREAM REAL DE TU RADIO
  final String streamUrl = 'https://stream.zeno.fm/rghmon0t9xauv';

  // CAMBIA ESTE ENLACE POR EL LINK DE TU RADIO EN ZENO
  final String zenoUrl = 'https://zeno.fm/radio/radio-adventista-en-reforma/';

  Future<void> playRadio() async {
    try {
      await _player.setUrl(streamUrl);
      await _player.play();
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir: $e')),
      );
    }
  }

  Future<void> pauseRadio() async {
    await _player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> openZeno() async {
    final Uri url = Uri.parse(zenoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Adventista de Dios en Reforma'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset('assets/logo.jpg',
                width: 150,
                ),
              const SizedBox(height: 24),
              const Text(
                'Radio Adventista en Reforma',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isPlaying ? 'En vivo reproduciendo...' : 'Radio detenida',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: playRadio,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Reproducir'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: pauseRadio,
                icon: const Icon(Icons.pause),
                label: const Text('Pausar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: openZeno,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Abrir en Zeno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}