import 'dart:async';

import 'dart:math';

import 'dart:io';

import 'dart:ui'; // ImageFilter için

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:record/record.dart';

import 'package:sensors_plus/sensors_plus.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:screenshot/screenshot.dart';

import 'package:share_plus/share_plus.dart';

import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    _cameras = await availableCameras();
  } catch (e) {
    _cameras = [];
  }

  runApp(const UltimateLieDetector());
}

class SettingsManager {
  static bool vibration = true;

  static bool sound = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    vibration = prefs.getBool('vibration') ?? true;

    sound = prefs.getBool('sound') ?? true;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('vibration', vibration);

    prefs.setBool('sound', sound);
  }
}

class Strings {
  static bool get isTurkish {
    try {
      return Platform.localeName.startsWith('tr');
    } catch (e) {
      return false;
    }
  }

  static String get(String key) {
    bool tr = isTurkish;

    switch (key) {
      case 'app_name':
        return tr ? "YALAN DEDEKTÖRÜ" : "LIE DETECTOR";

      case 'ai_badge':
        return tr ? "YAPAY ZEKA DESTEKLİ v2.0" : "POWERED BY AI v2.0";

      case 'settings':
        return tr ? "AYARLAR" : "SETTINGS";

      case 'vibration':
        return tr ? "Titreşim" : "Vibration";

      case 'sound':
        return tr ? "Ses Efektleri" : "Sound Effects";

      case 'share':
        return tr ? "PAYLAŞ" : "SHARE";

      case 'save_share':
        return tr ? "SONUCU PAYLAŞ" : "SHARE RESULT";

      case 'ppg_mode':
        return tr ? "NABIZ ANALİZİ" : "HEART RATE";

      case 'face_mode':
        return tr ? "YÜZ TARAMASI" : "FACE SCAN";

      case 'voice_mode':
        return tr ? "SES ANALİZİ" : "VOICE ANALYSIS";

      case 'tremor_mode':
        return tr ? "EL TİTREMESİ" : "TREMOR TEST";

      case 'instruction_title':
        return tr ? "GÖREV TALİMATLARI" : "MISSION INSTRUCTIONS";

      case 'start_btn':
        return tr ? "TESTİ BAŞLAT" : "START TEST";

      case 'cancel_btn':
        return tr ? "İPTAL" : "CANCEL";

      case 'face_inst':
        return tr
            ? "1. Telefonu yüzüne tut.\n2. Yüzünü ortadaki çerçeveye yerleştir.\n3. Analiz bitene kadar kıpırdama."
            : "1. Hold phone to face.\n2. Place face in the center frame.\n3. Don't move until analysis is done.";

      case 'ppg_inst':
        return tr
            ? "1. Parmağını kameraya ve flaşa koy.\n2. Kan akış hızın analiz edilecek.\n3. Sabit dur."
            : "1. Place finger on camera/flash.\n2. Blood flow will be analyzed.\n3. Stay still.";

      case 'voice_inst':
        return tr
            ? "1. Mikrofon ikonuna basılı tut.\n2. Soruya net cevap ver.\n3. Ses frekansındaki titremeler ölçülecek."
            : "1. Hold mic icon.\n2. Answer clearly.\n3. Jitter will be measured.";

      case 'tremor_inst':
        return tr
            ? "1. Telefonu havada tut.\n2. En ufak titreme grafiği bozar.\n3. Çizgiyi düz tutmaya çalış."
            : "1. Hold phone in air.\n2. Shaking disrupts the graph.\n3. Keep the line flat.";

      case 'pulse_found':
        return tr ? "NABIZ: " : "PULSE: ";

      case 'lie':
        return tr ? "YALAN!" : "LIE DETECTED!";

      case 'truth':
        return tr ? "DOĞRU" : "TRUTH";

      case 'analyzing':
        return tr ? "VERİLER İŞLENİYOR..." : "PROCESSING DATA...";

      case 'ok':
        return tr ? "TAMAM" : "OK";

      case 'high_stress':
        return tr
            ? "Kritik stres seviyesi tespit edildi."
            : "Critical stress levels detected.";

      case 'normal_stress':
        return tr ? "Fizyolojik veriler normal." : "Physiological data normal.";

      case 'face_locked':
        return tr ? "HEDEF KİLİTLENDİ" : "TARGET LOCKED";

      case 'scan_button':
        return tr ? "TARAMAYI BAŞLAT" : "START SCAN";

      default:
        return key;
    }
  }
}

class UltimateLieDetector extends StatelessWidget {
  const UltimateLieDetector({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Lie Detector',

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00E5FF)),
        textTheme:
            const TextTheme(bodyMedium: TextStyle(fontFamily: 'Courier')),
      ),

      // ARTIK DİREKT MAIN MENU DEĞİL, SPLASH SCREEN İLE AÇILIYOR

      home: const SplashScreen(),
    );
  }
}

// --- YENİ: HAVALI GİRİŞ EKRANI (SPLASH SCREEN) ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 Saniye bekleyip ana menüye geç

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainMenu()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 100, color: Color(0xFF00E5FF)),
            const SizedBox(height: 20),
            const Text("LIE DETECTOR",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5)),
            const SizedBox(height: 10),
            const Text("SYSTEM INITIALIZING...",
                style: TextStyle(color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 50),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                  color: Color(0xFF00E5FF), backgroundColor: Colors.white10),
            ),
            const SizedBox(height: 10),
            const Text("v2.4.1 AI-CORE",
                style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();

    SettingsManager.load().then((_) => setState(() {}));
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            children: [
              Text(Strings.get('settings'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(Strings.get('vibration'),
                    style: const TextStyle(color: Colors.white)),
                value: SettingsManager.vibration,
                activeColor: const Color(0xFF00E5FF),
                onChanged: (val) {
                  setModalState(() => SettingsManager.vibration = val);

                  SettingsManager.save();

                  setState(() {});
                },
              ),
              SwitchListTile(
                title: Text(Strings.get('sound'),
                    style: const TextStyle(color: Colors.white)),
                value: SettingsManager.sound,
                activeColor: const Color(0xFF00E5FF),
                onChanged: (val) {
                  setModalState(() => SettingsManager.sound = val);

                  SettingsManager.save();

                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructionDialog(
      BuildContext context, String title, String instructionKey, Widget page) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFF00E5FF), width: 2)),
        title: Row(
          children: [
            const Icon(Icons.memory, color: Color(0xFF00E5FF)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(Strings.get('instruction_title'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(Strings.get(instructionKey),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 16, height: 1.5)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(Strings.get('cancel_btn'),
                  style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);

              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
            child: Text(Strings.get('start_btn'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings, color: Colors.grey))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Color(0xFF0A0A2A)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint,
                    size: 80, color: Color(0xFF00E5FF)),
                const SizedBox(height: 10),
                FittedBox(
                    child: Text(Strings.get('app_name'),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3))),
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF00E5FF), width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(Strings.get('ai_badge'),
                      style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: _btn(
                            context,
                            Strings.get('face_mode'),
                            Icons.face_retouching_natural,
                            const FacePage(),
                            'face_inst')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _btn(context, Strings.get('ppg_mode'),
                            Icons.monitor_heart, const PPGPage(), 'ppg_inst')),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: _btn(
                            context,
                            Strings.get('voice_mode'),
                            Icons.record_voice_over,
                            const VoicePage(),
                            'voice_inst')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _btn(context, Strings.get('tremor_mode'),
                            Icons.waves, const TremorPage(), 'tremor_inst')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(
      BuildContext ctx, String txt, IconData icn, Widget pg, String instKey) {
    return GestureDetector(
      onTap: () => _showInstructionDialog(ctx, txt, instKey, pg),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.05),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.1),
                  blurRadius: 10)
            ]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icn, color: const Color(0xFF00E5FF), size: 30),
          const SizedBox(height: 10),
          Text(txt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))
        ]),
      ),
    );
  }
}

// --- 1. MOD: PROFESYONEL HACKER/FBI YÜZ ANALİZİ ---

class FacePage extends StatefulWidget {
  const FacePage({super.key});

  @override
  State<FacePage> createState() => _FacePageState();
}

class _FacePageState extends State<FacePage>
    with SingleTickerProviderStateMixin {
  CameraController? controller;

  bool faceDetected = false;

  bool isScanning = false;

  final FaceDetector _detector = FaceDetector(
      options: FaceDetectorOptions(
          enableClassification: true, enableLandmarks: true));

  final AudioPlayer _player = AudioPlayer();

  late AnimationController _scannerController;

  final List<String> _logs = [];

  Timer? _logTimer;

  final List<String> _techTerms = [
    "Decrypting...",
    "Matching Bio-ID...",
    "Heartbeat Sync...",
    "Thermal Anomaly...",
    "Retina Scan...",
    "Accessing DB..."
  ];

  @override
  void initState() {
    super.initState();

    _scannerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _init();
  }

  void _init() async {
    if (_cameras.isEmpty) return;

    var cam = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first);

    controller =
        CameraController(cam, ResolutionPreset.high, enableAudio: false);

    await controller!.initialize();

    if (mounted) setState(() {});

    _check();
  }

  void _check() async {
    if (!mounted || isScanning) return;

    if (controller != null && controller!.value.isInitialized) {
      try {
        final img = await controller!.takePicture();

        final faces =
            await _detector.processImage(InputImage.fromFilePath(img.path));

        if (mounted) {
          setState(() {
            faceDetected = faces.isNotEmpty;

            if (faceDetected && _logs.isEmpty) _addLog("TARGET ACQUIRED");
          });
        }
      } catch (e) {}
    }

    Future.delayed(const Duration(milliseconds: 600), _check);
  }

  void _addLog(String text) {
    if (!mounted) return;

    setState(() {
      _logs.add("> $text");

      if (_logs.length > 4) _logs.removeAt(0);
    });
  }

  void _scan() async {
    setState(() => isScanning = true);

    _playSound('tara.mp3');

    int tick = 0;

    _logTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      _addLog(_techTerms[tick % _techTerms.length]);

      tick++;
    });

    await Future.delayed(const Duration(seconds: 4));

    _logTimer?.cancel();

    bool lie = Random().nextBool();

    _playSound(lie ? 'yanlis.mp3' : 'dogru.mp3');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ResultScreen(
                isLie: lie,
                message: "AI Confidence: ${(85 + Random().nextInt(14))}%")));

    setState(() {
      isScanning = false;

      _logs.clear();
    });
  }

  void _playSound(String f) {
    if (SettingsManager.sound)
      try {
        _player.stop();

        _player.play(AssetSource('sounds/$f'));
      } catch (e) {}
  }

  @override
  void dispose() {
    controller?.dispose();

    _detector.close();

    _player.dispose();

    _scannerController.dispose();

    _logTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- 1. KATMAN: DIGITAL RAIN (MATRIX EFFECT) ---

          // Arka planda sürekli akan kodlar

          Positioned.fill(child: MatrixEffect()),

          // --- 2. KATMAN: KAMERA VE HUD ---

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Kamera Çerçevesi

                Container(
                  width: size.width * 0.7,
                  height: size.height * 0.5,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: faceDetected
                              ? const Color(0xFF00E5FF)
                              : Colors.grey.withOpacity(0.5),
                          width: 2),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                            color: faceDetected
                                ? const Color(0xFF00E5FF).withOpacity(0.3)
                                : Colors.transparent,
                            blurRadius: 20)
                      ]),
                  child: Stack(
                    children: [
                      ClipRect(
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller!.value.previewSize!.height,
                              height: controller!.value.previewSize!.width,
                              child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: CameraPreview(controller!)),
                            ),
                          ),
                        ),
                      ),

                      // Tarama Lazeri (Sadece kutu içinde)

                      if (isScanning)
                        AnimatedBuilder(
                          animation: _scannerController,
                          builder: (context, child) {
                            return Positioned(
                              top: (size.height * 0.5) *
                                  _scannerController.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF00E5FF),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color(0xFF00E5FF),
                                            blurRadius: 10)
                                      ])),
                            );
                          },
                        ),

                      // Hedef İşaretleri

                      const Positioned(
                          top: 5,
                          left: 5,
                          child:
                              Icon(Icons.crop_free, color: Color(0xFF00E5FF))),

                      const Positioned(
                          bottom: 5,
                          right: 5,
                          child:
                              Icon(Icons.crop_free, color: Color(0xFF00E5FF))),

                      if (faceDetected && !isScanning)
                        const Center(
                            child: Text("LOCKED",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: 5,
                                    backgroundColor: Colors.black54))),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Log Kutusu

                Container(
                  height: 100,
                  width: size.width * 0.8,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      border: Border.all(color: Colors.white24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("TERMINAL_OUTPUT:",
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ..._logs.map((l) => Text(l,
                          style: const TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 12,
                              fontFamily: 'Courier'))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // HUD Sabit Yazılar

          const Positioned(
              top: 40,
              left: 20,
              child: Text("SECURE CONNECTION",
                  style: TextStyle(color: Colors.green, fontSize: 12))),

          const Positioned(
              top: 40,
              right: 20,
              child: Text("ENCRYPTION: 256-BIT",
                  style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12))),

          // Buton

          if (faceDetected && !isScanning)
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15)),
                        onPressed: _scan,
                        child: Text(Strings.get('scan_button'),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))))),
        ],
      ),
    );
  }
}

// --- YENİ: MATRIX EFFECT WIDGET (ARKA PLAN İÇİN) ---

class MatrixEffect extends StatefulWidget {
  const MatrixEffect({super.key});

  @override
  State<MatrixEffect> createState() => _MatrixEffectState();
}

class _MatrixEffectState extends State<MatrixEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<List<double>> _drops = []; // [x, y, speed, length]

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();

    _controller.addListener(() {
      setState(() {
        _updateDrops();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_drops.isEmpty) {
      double width = MediaQuery.of(context).size.width;

      int columns = (width / 15).floor(); // Her 15 pikselde bir sütun

      for (int i = 0; i < columns; i++) {
        _drops.add([
          i * 15.0,
          _rnd.nextDouble() * -1000,
          2 + _rnd.nextDouble() * 5,
          10 + _rnd.nextDouble() * 10
        ]);
      }
    }
  }

  void _updateDrops() {
    double height = MediaQuery.of(context).size.height;

    for (var drop in _drops) {
      drop[1] += drop[2]; // Y konumunu hız kadar artır

      if (drop[1] > height) {
        // Ekrandan çıktıysa başa al

        drop[1] = -100 - _rnd.nextDouble() * 100;

        drop[2] = 2 + _rnd.nextDouble() * 5; // Hızı değiştir
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: MatrixPainter(_drops));
  }
}

class MatrixPainter extends CustomPainter {
  final List<List<double>> drops;

  MatrixPainter(this.drops);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var drop in drops) {
      // Basit çizgi yerine "1 0 1 0" gibi karakterler çizmek daha havalı ama performans için dikdörtgen kullanıyoruz

      // Hacker hissi için kesik çizgiler

      canvas.drawRect(Rect.fromLTWH(drop[0], drop[1], 2, 15), paint);

      // İkinci bir parlak kafa kısmı

      paint.color = const Color(0xFF00E5FF).withOpacity(0.8);

      canvas.drawRect(Rect.fromLTWH(drop[0], drop[1] + 15, 2, 5), paint);

      paint.color = const Color(0xFF00E5FF).withOpacity(0.3); // Rengi geri al
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- DİĞER MODLAR AYNEN DEVAM ---

class TremorPage extends StatefulWidget {
  const TremorPage({super.key});

  @override
  State<TremorPage> createState() => _TremorPageState();
}

class _TremorPageState extends State<TremorPage> {
  bool isScanning = false;

  double stabilityScore = 100.0;

  double instantMovement = 0.0;

  StreamSubscription<AccelerometerEvent>? _streamSubscription;

  final AudioPlayer _player = AudioPlayer();

  double? _lastX, _lastY, _lastZ;

  void _startScan() {
    setState(() {
      isScanning = true;

      stabilityScore = 100.0;

      _lastX = null;

      _lastY = null;

      _lastZ = null;
    });

    _playSound('tara.mp3');

    _streamSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_lastX != null) {
        double totalDelta = (event.x - _lastX!).abs() +
            (event.y - _lastY!).abs() +
            (event.z - _lastZ!).abs();

        setState(() {
          instantMovement = totalDelta;

          if (totalDelta > 0.3) stabilityScore -= totalDelta * 0.5;

          if (stabilityScore < 0) stabilityScore = 0;
        });
      }

      _lastX = event.x;

      _lastY = event.y;

      _lastZ = event.z;
    });

    Future.delayed(const Duration(seconds: 6), _finishScan);
  }

  void _finishScan() async {
    _streamSubscription?.cancel();

    setState(() {
      isScanning = false;

      instantMovement = 0.0;
    });

    bool lie = stabilityScore < 50.0;

    _playSound(lie ? 'yanlis.mp3' : 'dogru.mp3');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ResultScreen(
                isLie: lie,
                message: "Stability Score: ${stabilityScore.toInt()}%")));
  }

  void _playSound(String f) {
    if (SettingsManager.sound)
      try {
        _player.stop();

        _player.play(AssetSource('sounds/$f'));
      } catch (e) {}
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = stabilityScore > 70
        ? const Color(0xFF00E5FF)
        : (stabilityScore > 40 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Center(
              child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: statusColor.withOpacity(0.3), width: 1),
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        statusColor.withOpacity(0.1),
                        Colors.transparent
                      ])),
                  child: Center(
                      child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: statusColor, shape: BoxShape.circle))))),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const SizedBox(height: 350),
                if (!isScanning)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15)),
                      onPressed: _startScan,
                      child: Text(Strings.get('scan_button'),
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                if (isScanning) ...[
                  Text("${stabilityScore.toInt()}%",
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier')),
                  Text("STABILITY INTEGRITY",
                      style: TextStyle(
                          color: statusColor.withOpacity(0.7),
                          fontSize: 10,
                          letterSpacing: 2))
                ]
              ])),
          if (isScanning)
            Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: ScannerAnimation(
                    isScanning: true, externalNoise: instantMovement))
        ],
      ),
    );
  }
}

class PPGPage extends StatefulWidget {
  const PPGPage({super.key});

  @override
  State<PPGPage> createState() => _PPGPageState();
}

class _PPGPageState extends State<PPGPage> {
  CameraController? controller;

  bool isScanning = false;

  bool fingerDetected = false;

  double redness = 0.0;

  int bpm = 0;

  final AudioPlayer _player = AudioPlayer();

  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();

    _initCam();
  }

  Future<void> _initCam() async {
    if (_cameras.isEmpty) return;

    var backCam = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first);

    controller = CameraController(backCam, ResolutionPreset.low,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);

    await controller!.initialize();

    await controller!.startImageStream((CameraImage image) {
      if (!isScanning) _processImage(image);
    });

    if (mounted) setState(() {});
  }

  void _processImage(CameraImage image) {
    int totalVal = 0;

    int count = 0;

    final int uvRowStride = image.planes[2].bytesPerRow;

    final int uvPixelStride = image.planes[2].bytesPerPixel ?? 1;

    for (int y = image.height ~/ 2 - 10; y < image.height ~/ 2 + 10; y++) {
      for (int x = image.width ~/ 2 - 10; x < image.width ~/ 2 + 10; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);

        if (uvIndex < image.planes[2].bytes.length) {
          totalVal += image.planes[2].bytes[uvIndex];

          count++;
        }
      }
    }

    double avg = count > 0 ? totalVal / count : 0;

    if (mounted) {
      setState(() {
        redness = avg;

        fingerDetected = avg > 100;
      });
    }
  }

  Future<void> _startScan() async {
    if (!fingerDetected) return;

    setState(() => isScanning = true);

    try {
      await controller!.setFlashMode(FlashMode.torch);
    } catch (e) {}

    _playSound('tara.mp3');

    int tick = 0;

    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      tick++;

      setState(() {
        bpm = 70 + (redness % 50).toInt();
      });

      if (tick >= 40) {
        _finish();
      }
    });
  }

  Future<void> _finish() async {
    _scanTimer?.cancel();

    try {
      await controller!.setFlashMode(FlashMode.off);
    } catch (e) {}

    bool lie = bpm > 100;

    _showResult(lie);
  }

  void _showResult(bool lie) {
    _playSound(lie ? 'yanlis.mp3' : 'dogru.mp3');

    if (SettingsManager.vibration) {
      if (lie)
        HapticFeedback.heavyImpact();
      else
        HapticFeedback.mediumImpact();
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ResultScreen(
                isLie: lie,
                message: "${Strings.get('pulse_found')} $bpm BPM")));

    setState(() => isScanning = false);
  }

  void _playSound(String f) {
    if (SettingsManager.sound)
      try {
        _player.stop();

        _player.play(AssetSource('sounds/$f'));
      } catch (e) {}
  }

  @override
  void dispose() {
    _scanTimer?.cancel();

    try {
      controller?.setFlashMode(FlashMode.off);
    } catch (e) {}

    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                      width: controller!.value.previewSize!.height,
                      height: controller!.value.previewSize!.width,
                      child: CameraPreview(controller!)))),
          Container(color: Colors.black87),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: fingerDetected ? Colors.red : Colors.grey,
                            width: 5),
                        borderRadius: BorderRadius.circular(20),
                        color: fingerDetected
                            ? Colors.red.withOpacity(0.3)
                            : Colors.transparent),
                    child: fingerDetected
                        ? const Icon(Icons.favorite,
                            size: 80, color: Colors.red)
                        : const Icon(Icons.fingerprint,
                            size: 80, color: Colors.grey)),
                const SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ScannerAnimation(isScanning: isScanning)),
                const SizedBox(height: 20),
                if (fingerDetected && !isScanning)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15)),
                      onPressed: _startScan,
                      child: Text(Strings.get('scan_button'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                if (isScanning)
                  Text(Strings.get('analyzing'),
                      style: const TextStyle(
                          color: Colors.redAccent, letterSpacing: 2))
              ]))
        ],
      ),
    );
  }
}

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final AudioRecorder _recorder = AudioRecorder();

  bool isRecording = false;

  double maxAmp = -160;

  Timer? _t;

  @override
  void initState() {
    super.initState();

    Permission.microphone.request();
  }

  void _start() async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(const RecordConfig(),
          path: '${Directory.systemTemp.path}/temp.m4a');

      setState(() {
        isRecording = true;

        maxAmp = -160;
      });

      _t = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        final amp = await _recorder.getAmplitude();

        if (amp.current > maxAmp) maxAmp = amp.current;

        setState(() {});
      });
    }
  }

  void _stop() async {
    await _recorder.stop();

    _t?.cancel();

    setState(() => isRecording = false);

    bool lie = maxAmp > -5.0 || maxAmp < -40.0;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ResultScreen(
                isLie: lie,
                message: "Amplitude Jitter: ${maxAmp.toStringAsFixed(1)} dB")));
  }

  @override
  void dispose() {
    _recorder.dispose();

    _t?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
              onLongPressStart: (_) => _start(),
              onLongPressEnd: (_) => _stop(),
              child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? Colors.red
                          : Colors.grey.withOpacity(0.2),
                      boxShadow: isRecording
                          ? [
                              BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5)
                            ]
                          : []),
                  child: const Icon(Icons.mic, size: 60, color: Colors.white))),
          const SizedBox(height: 40),
          Text(isRecording ? "RECORDING..." : Strings.get('voice_hint'),
              style: const TextStyle(color: Colors.white, letterSpacing: 2)),
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ScannerAnimation(isScanning: isRecording))
        ]),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final bool isLie;

  final String message;

  final ScreenshotController screenshotController = ScreenshotController();

  ResultScreen({super.key, required this.isLie, required this.message});

  void _shareResult(BuildContext context) async {
    final image = await screenshotController.capture();

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();

      final imagePath = await File('${directory.path}/result.png').create();

      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath.path)],
          text: 'AI Lie Detector Result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          color: Colors.black,
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(isLie ? Icons.warning : Icons.check_circle,
                  size: 100, color: isLie ? Colors.red : Colors.green),
              const SizedBox(height: 20),
              Text(isLie ? Strings.get('lie') : Strings.get('truth'),
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: isLie ? Colors.red : Colors.green)),
              const SizedBox(height: 20),
              Text(message,
                  style: const TextStyle(color: Colors.grey, fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                  isLie
                      ? Strings.get('high_stress')
                      : Strings.get('normal_stress'),
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                  onPressed: () => _shareResult(context),
                  icon: const Icon(Icons.share),
                  label: Text(Strings.get('save_share')),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black)),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(Strings.get('ok'),
                      style: const TextStyle(color: Colors.white)))
            ]),
          ),
        ),
      ),
    );
  }
}

class ScannerAnimation extends StatefulWidget {
  final bool isScanning;

  final double? externalNoise;

  const ScannerAnimation(
      {super.key, required this.isScanning, this.externalNoise});

  @override
  State<ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<double> _dataPoints = [];

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50))
      ..addListener(_updateGraph);

    if (widget.isScanning) _controller.repeat();

    for (int i = 0; i < 50; i++) _dataPoints.add(0.5);
  }

  void _updateGraph() {
    if (_dataPoints.length > 50) _dataPoints.removeAt(0);

    double noise;

    if (widget.externalNoise != null) {
      double shake = widget.externalNoise! * 10.0;

      noise = (shake * (_rnd.nextDouble() - 0.5)).clamp(-0.5, 0.5);
    } else {
      noise = widget.isScanning
          ? (_rnd.nextDouble() - 0.5) * 0.8
          : (_rnd.nextDouble() - 0.5) * 0.05;
    }

    double newVal = (0.5 + noise).clamp(0.0, 1.0);

    setState(() {
      _dataPoints.add(newVal);
    });
  }

  @override
  void didUpdateWidget(covariant ScannerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isScanning) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 10)
          ]),
      child: CustomPaint(painter: GraphPainter(_dataPoints)),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<double> data;

  GraphPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.1)
      ..strokeWidth = 1;

    double stepX = size.width / 10;

    for (double i = 0; i <= size.width; i += stepX)
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);

    for (double i = 0; i <= size.height; i += stepX)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);

    if (data.isEmpty) return;

    double xStep = size.width / (data.length - 1);

    path.moveTo(0, data[0] * size.height);

    for (int i = 1; i < data.length; i++) {
      path.lineTo(i * xStep, data[i] * size.height);
    }

    canvas.drawPath(path, paint);

    final shadowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.close();

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
