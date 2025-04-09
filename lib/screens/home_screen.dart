import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/creature_model.dart';
import '../models/creature_data.dart';
import '../widgets/app_button.dart';
import '../widgets/result_card.dart';
import '../utils/constants.dart';
import 'details_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  Creature? _detectedCreature;
  bool _isLoading = false;
  late Interpreter _interpreter;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/sea_creatures.tflite');
      _labels = await rootBundle.loadString('assets/labels/sea_labels.txt')
          .then((string) => string.split('\n').map((s) => s.trim()).toList());
    } catch (e) {
      _showError('Model initialization failed: $e');
    }
  }

  Future<void> _processImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final file = File(image.path);
      final input = await _preprocessImage(file);
      final output = Float32List(23);

      _interpreter.run(input.buffer, output.buffer);

      final maxIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));
      final confidence = output[maxIndex] * 100;
      final creatureName = _labels[maxIndex];
      final creature = CreatureData.getCreature(creatureName);

      setState(() {
        _selectedImage = file;
        _detectedCreature = creature;
      });

      if (confidence > 50 && creature != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(
              creature: creature,
              selectedImage: file,
            ),
          ),
        );
      } else {
        _showError('Low confidence (${confidence.toStringAsFixed(1)}%) - Try another image');
      }
    } catch (e) {
      _showError('Processing error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Float32List> _preprocessImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final originalImage = img.decodeImage(bytes)!;
      final resizedImage = img.copyResize(originalImage, width: 128, height: 128);

      final input = Float32List(1 * 128 * 128 * 3);
      int index = 0;
      for (int y = 0; y < 128; y++) {
        for (int x = 0; x < 128; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[index++] = pixel.r.toDouble() / 255.0;
          input[index++] = pixel.g.toDouble() / 255.0;
          input[index++] = pixel.b.toDouble() / 255.0;
        }
      }
      return input;
    } catch (e) {
      _showError('Image processing failed: $e');
      throw Exception('Image processing error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sea Creature Discovery',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A9D8F), Color(0xFF1D7A6F)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showAppInfo,
          )
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Expanded(
              child: _buildMainContent(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ocean Explorer',
                style: AppTextStyles.headline.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 24),
            if (_detectedCreature != null) ...[
              _buildResultSection(),
              const SizedBox(height: 24),
            ],
            if (_isLoading) const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: AppColors.primary,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      elevation: 6,
      shadowColor: AppColors.primary.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE9F5F3)],
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: _selectedImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(_selectedImage!,
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.9),
              colorBlendMode: BlendMode.modulate,
            ),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera,
                  size: 50,
                  color: AppColors.primary.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Select an image to begin',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Detection Result',
            style: AppTextStyles.title.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 16),
        ResultCard(creature: _detectedCreature!),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.primary,
            elevation: 2,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(
                creature: _detectedCreature!,
                selectedImage: _selectedImage!,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.visibility, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text('View Details',
                  style: AppTextStyles.button.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(20).copyWith(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onPressed: () => _processImage(ImageSource.gallery),
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onPressed: () => _processImage(ImageSource.camera),
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('App Information',
            style: TextStyle(color: AppColors.secondary)),
        content: const Text('Identifies 23 different marine🌊 species using AI'),
        actions: [
          TextButton(
            child: const Text('OK🐚',
                style: TextStyle(color: AppColors.primary)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}