import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

const String databaseUrl =
    'https://radio-adventista-reforma-default-rtdb.firebaseio.com/';
const String adminPassword = 'locutor2026';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  final TextEditingController chatController = TextEditingController();

  final DatabaseReference messagesRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: databaseUrl,
  ).ref('mensajes_cabina');

  bool isPlaying = false;
  bool isLoading = true;
  bool isReady = false;
  bool isSending = false;

  String savedName = '';
  int logoTapCount = 0;

  final String streamUrl = 'https://stream.zeno.fm/rghmon0t9xauv';
  final String zenoUrl = 'https://zeno.fm/radio/radio-adventista-en-reforma/';
  final String facebookUrl = 'https://www.facebook.com/';
  final String whatsappUrl = 'https://wa.me/50300000000';

  @override
  void initState() {
    super.initState();
    _prepareRadio();
    _loadSavedName();

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

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedName = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() {
      savedName = name;
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
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

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

  Future<void> sendChatMessage() async {
    final mensaje = chatController.text.trim();
    if (mensaje.isEmpty) return;

    try {
      setState(() {
        isSending = true;
      });

      final nombreFinal =
          savedName.trim().isEmpty ? 'Anónimo' : savedName.trim();

      await messagesRef.push().set({
        'nombre': nombreFinal,
        'mensaje': mensaje,
        'fecha': DateTime.now().toIso8601String(),
        'leido': false,
      });

      chatController.clear();

      if (!mounted) return;
      setState(() {
        isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar mensaje: $e')),
      );
    }
  }

  void openNameDialog() {
    final TextEditingController nameController =
        TextEditingController(text: savedName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10263A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tu nombre en el chat',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ejemplo: Robert',
              hintStyle: const TextStyle(color: Colors.white54),
              labelText: 'Nombre opcional',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _saveName('');
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Anónimo'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveName(nameController.text.trim());
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  

  void openAdminLoginDialog() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10263A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Modo locutor',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Clave',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.trim() == adminPassword) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPanelScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clave incorrecta')),
                  );
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  String formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';
    try {
      final date = DateTime.parse(fecha).toLocal();
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    chatController.dispose();
    _player.dispose();
    super.dispose();
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

  Widget miniButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageItem({
    required String nombre,
    required String mensaje,
    required String fecha,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                fecha,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mensaje,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ],
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

    final displayName = savedName.trim().isEmpty ? 'Anónimo' : savedName;

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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    children: [
                      // RADIO ARRIBA
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(28),
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
                            const Text(
                              'RADIO ONLINE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
  onLongPress: openAdminLoginDialog,
  child: Container(
    width: 130,
    height: 130,
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
        'assets/icon.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white.withOpacity(0.08),
            child: const Icon(
              Icons.radio,
              color: Colors.white,
              size: 65,
            ),
          );
        },
      ),
    ),
  ),
),
                            const SizedBox(height: 18),
                            const Text(
                              'Radio Adventista en Reforma',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
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
                            const SizedBox(height: 16),
                            Text(
                              statusText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 18),
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
                            const SizedBox(height: 22),
                            GestureDetector(
                              onTap: toggleRadio,
                              child: Container(
                                width: 90,
                                height: 90,
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
                                          width: 32,
                                          height: 32,
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
                                          size: 50,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isPlaying ? 'Toca para pausar' : 'Toca para reproducir',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // CHAT
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chat en vivo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Comunidad conectada ahora',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 260,
                              child: StreamBuilder<DatabaseEvent>(
                                stream: messagesRef.onValue,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                        'Error al cargar mensajes',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data?.snapshot.value == null) {
                                    return const Center(
                                      child: Text(
                                        'Aún no hay mensajes',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    );
                                  }

                                  final data = snapshot.data!.snapshot.value;
                                  if (data is! Map) {
                                    return const Center(
                                      child: Text(
                                        'Aún no hay mensajes',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    );
                                  }

                                  final entries = data.entries.toList().reversed.toList();

                                  return ListView.builder(
                                    itemCount: entries.length,
                                    itemBuilder: (context, index) {
                                      final item = entries[index];
                                      final value = item.value as Map<dynamic, dynamic>;

                                      final nombre =
                                          value['nombre']?.toString() ?? 'Anónimo';
                                      final mensaje =
                                          value['mensaje']?.toString() ?? '';
                                      final fecha =
                                          formatFecha(value['fecha']?.toString());

                                      return buildMessageItem(
                                        nombre: nombre,
                                        mensaje: mensaje,
                                        fecha: fecha,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ABAJO PEQUEÑO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nombre: $displayName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: openNameDialog,
                              child: const Text('Cambiar'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          miniButton(
                            icon: Icons.radio_outlined,
                            label: 'Zeno',
                            onTap: () => openLink(zenoUrl),
                          ),
                          const SizedBox(width: 8),
                          miniButton(
                            icon: Icons.facebook,
                            label: 'Facebook',
                            onTap: () => openLink(facebookUrl),
                          ),
                          const SizedBox(width: 8),
                          miniButton(
                            icon: Icons.message,
                            label: 'WhatsApp',
                            onTap: () => openLink(whatsappUrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // CAJA MENSAJE
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C2D),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSending ? null : sendChatMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference messagesRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref('mensajes_cabina');

    String formatFecha(String? fecha) {
      if (fecha == null || fecha.isEmpty) return '';
      try {
        final date = DateTime.parse(fecha).toLocal();
        final h = date.hour.toString().padLeft(2, '0');
        final m = date.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } catch (_) {
        return '';
      }
    }

    Future<void> deleteMessage(String key) async {
      await messagesRef.child(key).remove();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081521),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10263A),
        foregroundColor: Colors.white,
        title: const Text('Panel de Locutor'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: messagesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar mensajes',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                'No hay mensajes',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!.snapshot.value;
          if (data is! Map) {
            return const Center(
              child: Text(
                'No hay mensajes',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final entries = data.entries.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final item = entries[index];
              final key = item.key.toString();
              final value = item.value as Map<dynamic, dynamic>;

              final nombre = value['nombre']?.toString() ?? 'Anónimo';
              final mensaje = value['mensaje']?.toString() ?? '';
              final fecha = formatFecha(value['fecha']?.toString());

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          fecha,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mensaje,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => deleteMessage(key),
                        icon: const Icon(Icons.delete),
                        label: const Text('Borrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}