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
      title: 'Radio Adventista en Reforma',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
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
  bool isLoading = false;

  final String streamUrl = 'https://stream.zeno.fm/rghmon0t9xauv';
  final String zenoUrl = 'https://zeno.fm/radio/radio-adventista-en-reforma/';
  final String facebookUrl = 'https://facebook.com/';
  final String whatsappUrl = 'https://wa.me/50300000000';

  Future<void> playRadio() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _player.setUrl(streamUrl);
      await _player.play();

      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
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

  Future<void> toggleRadio() async {
    if (isPlaying) {
      await pauseRadio();
    } else {
      await playRadio();
    }
  }

  Future<void> openLink(String link) async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget buildWaveBar(double height, double opacity) {
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff09111f),
              Color(0xff15243d),
              Color(0xff1d3557),
              Color(0xff233b6e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                const Text(
                  'RADIO ONLINE',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 3,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: 170,
                  height: 170,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white.withOpacity(0.08),
                          child: const Icon(
                            Icons.radio,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Radio Adventista en Reforma',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? Colors.redAccent.withOpacity(0.18)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isPlaying
                          ? Colors.redAccent.withOpacity(0.5)
                          : Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: Text(
                    isPlaying ? '● EN DIRECTO' : '● LISTA PARA REPRODUCIR',
                    style: TextStyle(
                      color: isPlaying ? Colors.redAccent : Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isLoading
                            ? 'Conectando transmisión...'
                            : isPlaying
                                ? 'Ahora estás escuchando la radio'
                                : 'Presiona el botón para escuchar en vivo',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildWaveBar(18, 0.35),
                          const SizedBox(width: 6),
                          buildWaveBar(32, 0.50),
                          const SizedBox(width: 6),
                          buildWaveBar(48, 0.75),
                          const SizedBox(width: 6),
                          buildWaveBar(62, 1),
                          const SizedBox(width: 6),
                          buildWaveBar(42, 0.70),
                          const SizedBox(width: 6),
                          buildWaveBar(28, 0.45),
                          const SizedBox(width: 6),
                          buildWaveBar(18, 0.35),
                        ],
                      ),

                      const SizedBox(height: 30),

                      GestureDetector(
                        onTap: toggleRadio,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff3b82f6),
                                Color(0xff2563eb),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.40),
                                blurRadius: 22,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 58,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        isPlaying ? 'Toca para pausar' : 'Toca para reproducir',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    actionButton(
                      icon: Icons.radio_outlined,
                      text: 'Zeno',
                      onTap: () => openLink(zenoUrl),
                    ),
                    const SizedBox(width: 12),
                    actionButton(
                      icon: Icons.facebook,
                      text: 'Facebook',
                      onTap: () => openLink(facebookUrl),
                    ),
                    const SizedBox(width: 12),
                    actionButton(
                      icon: Icons.message_outlined,
                      text: 'WhatsApp',
                      onTap: () => openLink(whatsappUrl),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Una señal de esperanza para tu vida',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Escucha alabanzas, mensajes y programación especial desde cualquier lugar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}