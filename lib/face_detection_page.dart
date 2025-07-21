import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as imglib;

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({Key? key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  List<Face> _faces = [];
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      if (!mounted) {
        return;
      }
      await _cameraController.startImageStream(_processCameraImage); // Tambahkan await di sini
      setState(() {});
    } catch (e) {
      print("Error initializing camera: $e"); // Menangani kesalahan inisialisasi
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      _detectFacesFromImage(image);
    } catch (e) {
      debugPrint("ERROR: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _detectFacesFromImage(CameraImage image) async {
    InputImageRotation imageRotation =
        InputImageRotationValue.fromRawValue(_cameraController.description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);

    setState(() {
      _faces = faces;
    });
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = BytesBuilder(); // Menggunakan BytesBuilder
    for (final plane in planes) {
      allBytes.add(plane.bytes);
    }
    return allBytes.toBytes();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Deteksi Wajah Realtime')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController),
          ..._faces.map((face) {
            final box = face.boundingBox;
            return Positioned(
              left: box.left,
              top: box.top,
              width: box.width,
              height: box.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
