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
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81),
          brightness: Brightness.dark,
        ),
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
  bool isLoading = true;
  bool isReady = false;

  final String streamUrl = 'https://stream.zeno.fm/rghmon0t9xauv';
  final String zenoUrl = 'https://zeno.fm/radio/radio-adventista-en-reforma/';
  final String facebookUrl = 'https://www.facebook.com/';
  final String whatsappUrl = 'https://wa.me/50300000000';

  @override
  void initState() {
    super.initState();
    _prepareRadio();

    _player.playerStateStream.listen((state) {
      if (!mounted) return;

      setState(() {
        isPlaying = state.playing;
        if (state.processingState != ProcessingState.loading &&
            state.processingState != ProcessingState.buffering) {
          isLoading = false;
        }
      });
    });
  }

  Future<void> _prepareRadio() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(streamUrl)),
      );

      if (!mounted) return;
      setState(() {
        isReady = true;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isReady = false;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo preparar la radio: $e')),
      );
    }
  }

  Future<void> playRadio() async {
    try {
      if (!isReady) {
        await _prepareRadio();
      }

      setState(() {
        isLoading = true;
      });

      await _player.play();

      if (!mounted) return;
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir: $e')),
      );
    }
  }

  Future<void> pauseRadio() async {
    await _player.pause();

    if (!mounted) return;
    setState(() {
      isPlaying = false;
      isLoading = false;
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
    try {
      final uri = Uri.parse(link);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir enlace: $e')),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget waveBar(double height, double opacity) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = isLoading
        ? 'Conectando transmisión...'
        : isPlaying
            ? 'Ahora estás escuchando la radio'
            : isReady
                ? 'Lista para reproducir'
                : 'No se pudo conectar';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF081521),
              Color(0xFF10263A),
              Color(0xFF163A57),
              Color(0xFF1D4E75),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'RADIO ONLINE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 165,
                        height: 165,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 2,
                          ),
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
                                  color: Colors.white,
                                  size: 75,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Radio Adventista en Reforma',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? Colors.redAccent.withOpacity(0.15)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isPlaying
                                ? Colors.redAccent.withOpacity(0.45)
                                : Colors.white.withOpacity(0.10),
                          ),
                        ),
                        child: Text(
                          isPlaying ? '● EN DIRECTO' : '● TRANSMISIÓN ONLINE',
                          style: TextStyle(
                            color: isPlaying ? Colors.redAccent : Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        statusText,
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
                          waveBar(18, 0.35),
                          const SizedBox(width: 5),
                          waveBar(28, 0.45),
                          const SizedBox(width: 5),
                          waveBar(46, 0.70),
                          const SizedBox(width: 5),
                          waveBar(62, 1),
                          const SizedBox(width: 5),
                          waveBar(46, 0.70),
                          const SizedBox(width: 5),
                          waveBar(28, 0.45),
                          const SizedBox(width: 5),
                          waveBar(18, 0.35),
                        ],
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: toggleRadio,
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3B82F6),
                                Color(0xFF2563EB),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.35),
                                blurRadius: 20,
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
                                    color: Colors.white,
                                    size: 56,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                const SizedBox(height: 22),
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
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
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