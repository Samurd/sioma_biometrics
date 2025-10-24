import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sioma_biometrics/domain/entities/employee.dart';
import 'package:sioma_biometrics/presentation/providers/local_db_repository_provider.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _detectionResult = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    // Usa la cámara frontal si está disponible
    CameraDescription selectedCamera = cameras.first;
    for (final cam in cameras) {
      if (cam.lensDirection == CameraLensDirection.front) {
        selectedCamera = cam;
        break;
      }
    }

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    setState(() => _isCameraInitialized = true);
  }

  Future<void> _detectFaces(String imagePath) async {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    );
    final faceDetector = FaceDetector(options: options);

    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      setState(() => _detectionResult = '❌ No se detectaron rostros');
    } else {
      setState(
        () => _detectionResult = '✅ Rostros detectados: ${faces.length}',
      );

      // Si hay rostro, guarda en la base de datos
      final savedPath = await saveImageLocally(File(imagePath));
      await _saveEmployee(savedPath);
    }

    await faceDetector.close();
  }

  Future<String> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = File('${directory.path}/$fileName');
    await image.copy(savedImage.path);
    return savedImage.path;
  }

  Future<void> _saveEmployee(String photoPath) async {
    final repo = ref.read(localDbRepositoryProvider);
    final employee = Employee(
      name: 'Empleado ${DateTime.now().millisecondsSinceEpoch}',
      photoPath: photoPath,
      faceEmbedding: [], // se puede llenar luego
    );
    await repo.createEmployee(employee);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Empleado guardado en ObjectBox')),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                if (_detectionResult.isNotEmpty)
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        _detectionResult,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final image = await _cameraController!.takePicture();
                        await _detectFaces(image.path);
                      },
                      child: const Text('Detectar rostro'),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
