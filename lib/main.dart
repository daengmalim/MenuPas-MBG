import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MenuPas MBG',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SppgHomeScreen(),
    );
  }
}

class SppgHomeScreen extends StatefulWidget {
  const SppgHomeScreen({super.key});

  @override
  State<SppgHomeScreen> createState() => _SppgHomeScreenState();
}

class _SppgHomeScreenState extends State<SppgHomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _outputResult = "Masukkan data bahan dan anggaran untuk mulai menyusun menu.";
  bool _isLoading = false;

  final String _apiKey = "";

  Future<void> _generateMenu() async {
    if (_inputController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _outputResult = "Sedang menyusun draf menu gizi...";
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'Bertindaklah sebagai Ahli Gizi Utama dan Asisten Operasional untuk program Makan Bergizi Gratis (MBG) Badan Gizi Nasional. Tugas Anda adalah membantu pengelola SPPG menyusun draf menu harian yang memenuhi standar kalori, protein, serta gizi seimbang untuk anak sekolah, dengan mematuhi batasan anggaran per porsi dan memaksimalkan bahan pangan lokal.'
        ),
      );

      final prompt = _inputController.text;
      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _outputResult = response.text ?? "Tidak ada respons dari AI.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _outputResult = "Terjadi galat: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MenuPas MBG - Asisten Dapur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Contoh: Bahan ayam 5kg, tahu, beras. Anggaran 10rb/porsi untuk 100 anak.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateMenu,
              child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Buat Draf Menu Gizi'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_outputResult),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
