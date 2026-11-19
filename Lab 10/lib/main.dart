import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'services/classifier.dart';

void main() {
  runApp(const TmClassifierApp());
}

class TmClassifierApp extends StatefulWidget {
  const TmClassifierApp({super.key});

  @override
  State<TmClassifierApp> createState() => _TmClassifierAppState();
}

class _TmClassifierAppState extends State<TmClassifierApp> {
  Classifier? _classifier;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initClassifier();
  }

  Future<void> _initClassifier() async {
    try {
      final classifier = await Classifier.load();
      _classifier = classifier;
      _runSmokeTest(classifier);
    } catch (e) {
      _errorMessage = 'Could not load model file from assets/model/:\n$e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runSmokeTest(Classifier classifier) async {
    try {
      final byteData = await rootBundle.load('assets/model/sample.jpg');
      final bytes = byteData.buffer.asUint8List();
      final predictions = classifier.classify(bytes);
      debugPrint('=== SMOKE TEST PREDICTIONS ===');
      for (final p in predictions) {
        debugPrint('${p.label}: ${(p.confidence * 100).toStringAsFixed(1)}%');
      }
    } catch (e) {
      debugPrint('Smoke test error: $e');
    }
  }

  @override
  void dispose() {
    _classifier?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finger Classifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Finger Gesture Classifier')),
        body: Center(
          child: _isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading model...'),
                  ],
                )
              : _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          const Text('Model Initialization Failed',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : const Text('Classifier Ready'),
        ),
      ),
    );
  }
}
