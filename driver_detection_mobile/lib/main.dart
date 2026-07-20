import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:gal/gal.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const GuardianEyeApp());
}

class GuardianEyeApp extends StatelessWidget {
  const GuardianEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardianEye',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.blueAccent,
          inactiveTrackColor: Colors.grey.shade800,
          thumbColor: Colors.blueAccent,
          overlayColor: Colors.blueAccent.withOpacity(0.2),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// HOME SCREEN
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // AI Settings matching the original web app
  double _eyeClosureStrictness = 0.30; 
  int _drowsinessFrames = 15;
  double _distractionTimeSeconds = 1.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GuardianEye', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 10,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Welcome to GuardianEye.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your intelligent AI co-pilot for road safety.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 30),
                
                // User Manual Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text('User Manual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.grey, height: 30),
                      _buildManualStep(Icons.phone_iphone, '1. Mount Phone', 'Secure your phone on the dashboard facing you directly.'),
                      const SizedBox(height: 15),
                      _buildManualStep(Icons.camera_front, '2. Ensure Visibility', 'Make sure your face is well-lit and fully visible to the camera.'),
                      const SizedBox(height: 15),
                      _buildManualStep(Icons.warning_amber_rounded, '3. AI Monitoring', 'The app will sound a loud alarm if you close your eyes or look away.'),
                      const SizedBox(height: 15),
                      _buildManualStep(Icons.video_library, '4. Accident Dashcam', 'Press "Report Accident" to instantly save the last 15s to your Gallery.'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // AI Sensitivity Settings Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, color: Colors.orangeAccent),
                          SizedBox(width: 10),
                          Text('AI Sensitivity Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.grey, height: 20),
                      
                      _buildSettingRow(
                        title: 'Eye Closure Strictness',
                        valueText: '${(_eyeClosureStrictness * 100).toInt()}%',
                        slider: Slider(
                          value: _eyeClosureStrictness,
                          min: 0.1,
                          max: 0.5,
                          divisions: 40,
                          onChanged: (val) => setState(() => _eyeClosureStrictness = val),
                        ),
                      ),
                      
                      _buildSettingRow(
                        title: 'Drowsiness Alert Time',
                        valueText: '$_drowsinessFrames frames',
                        slider: Slider(
                          value: _drowsinessFrames.toDouble(),
                          min: 5,
                          max: 100,
                          divisions: 95,
                          onChanged: (val) => setState(() => _drowsinessFrames = val.toInt()),
                        ),
                      ),
                      
                      _buildSettingRow(
                        title: 'Distraction Alert Time',
                        valueText: '${_distractionTimeSeconds.toStringAsFixed(1)} sec',
                        slider: Slider(
                          value: _distractionTimeSeconds,
                          min: 0.5,
                          max: 5.0,
                          divisions: 45,
                          onChanged: (val) => setState(() => _distractionTimeSeconds = val),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen(
                        eyeClosureStrictness: _eyeClosureStrictness,
                        drowsinessFrames: _drowsinessFrames,
                        distractionTimeSeconds: _distractionTimeSeconds,
                      )),
                    );
                  },
                  icon: const Icon(Icons.power_settings_new, size: 28, color: Colors.white),
                  label: const Text(
                    'START MONITORING',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualStep(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({required String title, required String valueText, required Widget slider}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(valueText, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        SizedBox(
          height: 30,
          child: slider,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// DASHBOARD SCREEN
// -----------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  final double eyeClosureStrictness;
  final int drowsinessFrames;
  final double distractionTimeSeconds;

  const DashboardScreen({
    super.key,
    required this.eyeClosureStrictness,
    required this.drowsinessFrames,
    required this.distractionTimeSeconds,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isProcessing = false;
  
  bool _isDrowsy = false;
  int _closedFramesCounter = 0;
  late int _drowsyThreshold; 

  bool _isDistracted = false;
  int _distractedFramesCounter = 0;
  late int _distractedThreshold;

  final List<CameraImage> _frameBuffer = [];
  DateTime _lastFrameTime = DateTime.now();
  bool _isSavingAccident = false;

  // Calibration baselines
  double _baselinePitchX = 0.0;
  double _baselineYawY = 0.0;
  
  // Real-time tracking for calibration button
  double _currentPitchX = 0.0;
  double _currentYawY = 0.0;

  // Real-time debug info
  String _debugInfo = "Initializing AI...";

  @override
  void initState() {
    super.initState();
    _drowsyThreshold = widget.drowsinessFrames;
    // We assume ML Kit processes roughly 10 frames per second on average 
    _distractedThreshold = (widget.distractionTimeSeconds * 10).toInt();

    _initializeCamera();
    
    final options = FaceDetectorOptions(
      enableClassification: true, 
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});

      _controller!.startImageStream((CameraImage image) {
        if (DateTime.now().difference(_lastFrameTime).inMilliseconds > 66) {
          _frameBuffer.add(image);
          if (_frameBuffer.length > 225) _frameBuffer.removeAt(0);
          _lastFrameTime = DateTime.now();
        }

        if (!_isProcessing) {
          _processCameraImage(image);
        }
      });
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessing = true;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      bool isEyesClosed = false;
      bool isLookingAway = false;

      for (Face face in faces) {
        final leftEyeOpen = face.leftEyeOpenProbability;
        final rightEyeOpen = face.rightEyeOpenProbability;

        int visibleEyes = 0;
        int closedEyes = 0;

        if (leftEyeOpen != null) {
          visibleEyes++;
          if (leftEyeOpen < widget.eyeClosureStrictness) closedEyes++;
        }

        if (rightEyeOpen != null) {
          visibleEyes++;
          if (rightEyeOpen < widget.eyeClosureStrictness) closedEyes++;
        }

        // Since the phone is sideways, the AI might miscalculate the far eye (e.g. thinking it's 0.80 open when it's closed).
        // To fix this, if *at least one* eye is definitively closed for 1.5 seconds, we sound the alarm.
        // Prolonged winking for 1.5 seconds isn't safe anyway!
        if (closedEyes > 0) {
          isEyesClosed = true;
        }

        if (face.headEulerAngleY != null) _currentYawY = face.headEulerAngleY!;
        if (face.headEulerAngleX != null) _currentPitchX = face.headEulerAngleX!;

        if (face.headEulerAngleY != null) {
          double deltaY = (face.headEulerAngleY! - _baselineYawY).abs();
          if (deltaY > 30) {
            isLookingAway = true;
          }
        }
        if (face.headEulerAngleX != null) {
          double deltaX = face.headEulerAngleX! - _baselinePitchX;
          if (deltaX < -20 || deltaX > 20) { 
            isLookingAway = true;
          }
        }
      }

      if (isEyesClosed) {
        _closedFramesCounter++;
      } else {
        if (_closedFramesCounter > 0) _closedFramesCounter--;
      }

      if (isLookingAway) {
        _distractedFramesCounter++;
      } else {
        if (_distractedFramesCounter > 0) _distractedFramesCounter--;
      }

      bool nowDrowsy = _closedFramesCounter >= _drowsyThreshold;
      bool nowDistracted = _distractedFramesCounter >= _distractedThreshold;

      if ((nowDrowsy != _isDrowsy) || (nowDistracted != _isDistracted)) {
        setState(() {
          _isDrowsy = nowDrowsy;
          _isDistracted = nowDistracted;
        });

        if (nowDrowsy || nowDistracted) {
          _audioPlayer.play(AssetSource('alarm.wav'));
        } else {
          _audioPlayer.stop();
        }
      }

      // Update Debug Info
      if (mounted) {
        setState(() {
          if (faces.isNotEmpty) {
             final f = faces.first;
             _debugInfo = "Left Eye: ${f.leftEyeOpenProbability?.toStringAsFixed(2) ?? 'N/A'}\n"
                          "Right Eye: ${f.rightEyeOpenProbability?.toStringAsFixed(2) ?? 'N/A'}\n"
                          "Drowsy Frames: $_closedFramesCounter / $_drowsyThreshold\n"
                          "Pitch: ${_currentPitchX.toStringAsFixed(1)} | Yaw: ${_currentYawY.toStringAsFixed(1)}";
          } else {
             _debugInfo = "No face detected.";
          }
        });
      }

    } catch (e) {
      debugPrint("Face Detection Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _saveAccidentVideo() async {
    if (_isSavingAccident || _frameBuffer.isEmpty) return;
    
    // Stop the camera stream and detector entirely!
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }

    setState(() {
      _isSavingAccident = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      final accidentDir = Directory('${directory.path}/AccidentFrames');
      if (await accidentDir.exists()) {
        await accidentDir.delete(recursive: true);
      }
      await accidentDir.create();

      int logicalWidth = _frameBuffer[0].width;
      int logicalHeight = _frameBuffer[0].height;
      int bytesPerRow = _frameBuffer[0].planes[0].bytesPerRow;
      
      // Determine the true orientation of the raw memory buffer.
      // If bytesPerRow is closer to the logical height, the memory is swapped (landscape vs portrait).
      int nativeWidth = logicalWidth;
      int nativeHeight = logicalHeight;
      if ((bytesPerRow - logicalHeight).abs() < (bytesPerRow - logicalWidth).abs()) {
        nativeWidth = logicalHeight;
        nativeHeight = logicalWidth;
      }
      
      final yuvFile = File('${accidentDir.path}/raw_frames.yuv');
      final lumaSize = nativeWidth * nativeHeight;
      
      if (nativeWidth == bytesPerRow) {
        // Fast path: No padding. Just write the Y-plane directly.
        final sink = yuvFile.openWrite();
        for (int i = 0; i < _frameBuffer.length; i++) {
          final bytes = _frameBuffer[i].planes[0].bytes;
          // Only extract the Y-plane (lumaSize). Prevents FFmpeg from misaligning into the UV plane!
          if (bytes.length >= lumaSize) {
            sink.add(bytes.sublist(0, lumaSize));
          } else {
            sink.add(bytes);
          }
        }
        await sink.close();
      } else {
        // Slow path: Memory is padded. We must strip the padding row-by-row.
        final totalBytes = lumaSize * _frameBuffer.length;
        final cleanBuffer = Uint8List(totalBytes);
        int offset = 0;
        
        for (int i = 0; i < _frameBuffer.length; i++) {
          final bytes = _frameBuffer[i].planes[0].bytes;
          for (int r = 0; r < nativeHeight; r++) {
            int srcStart = r * bytesPerRow;
            int rowLength = nativeWidth;
            if (srcStart + rowLength > bytes.length) {
              rowLength = bytes.length - srcStart;
            }
            if (rowLength > 0 && srcStart >= 0) {
              cleanBuffer.setRange(offset, offset + rowLength, bytes, srcStart);
              offset += rowLength;
            }
          }
        }
        // Write perfectly contiguous pixels to disk in one shot
        await yuvFile.writeAsBytes(cleanBuffer.buffer.asUint8List(0, offset));
      }

      // Encode MP4 using FFmpeg natively from raw bytes (Zero Dart lag)
      final mp4Path = '${directory.path}/GuardianEye_Accident_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ffmpegCommand = '-f rawvideo -pixel_format gray -video_size ${nativeWidth}x${nativeHeight} -framerate 15 -i "${yuvFile.path}" -c:v mpeg4 -q:v 5 "$mp4Path"';
      
      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // Save to Phone Gallery
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) await Gal.requestAccess();
        await Gal.putVideo(mp4Path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Incident MP4 Video saved directly to your Gallery!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception("FFmpeg encoding failed");
      }
    } catch (e) {
      debugPrint("Error saving accident video: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save MP4: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSavingAccident = false);
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.greenAccent;
    Color glowColor = Colors.greenAccent;
    String statusText = "DRIVER AWAKE";
    String subText = "Monitoring active...";
    Color bottomBarColor = Colors.black.withOpacity(0.7);

    if (_isDrowsy) {
      borderColor = Colors.redAccent;
      glowColor = Colors.redAccent;
      statusText = "DROWSINESS DETECTED!";
      subText = "Please pull over immediately.";
      bottomBarColor = Colors.red.shade900.withOpacity(0.85);
    } else if (_isDistracted) {
      borderColor = Colors.orangeAccent;
      glowColor = Colors.orangeAccent;
      statusText = "DISTRACTED!";
      subText = "Keep your eyes on the road.";
      bottomBarColor = Colors.orange.shade900.withOpacity(0.85);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('GuardianEye Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _controller != null && _controller!.value.isInitialized
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller!.value.previewSize!.height,
                                  height: _controller!.value.previewSize!.width,
                                  child: CameraPreview(_controller!),
                                ),
                              ),
                              // Live Debug Overlay
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _debugInfo,
                                    style: const TextStyle(color: Colors.yellowAccent, fontSize: 12, fontFamily: 'monospace'),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isSavingAccident ? null : _saveAccidentVideo,
                      icon: _isSavingAccident 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      label: Text(
                        _isSavingAccident ? 'ENCODING MP4 VIDEO...' : 'REPORT ACCIDENT',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _baselinePitchX = _currentPitchX;
                          _baselineYawY = _currentYawY;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Camera Calibrated to Road Center!'),
                            backgroundColor: Colors.blueAccent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.my_location, color: Colors.white, size: 24),
                      label: const Text(
                        'CALIBRATE CENTER',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Go back to Home Screen
                      },
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.white, size: 24),
                      label: const Text(
                        'STOP MONITORING',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: bottomBarColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border(
                      top: BorderSide(color: glowColor.withOpacity(0.3), width: 2),
                    )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [Shadow(color: glowColor, blurRadius: 10)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subText,
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
