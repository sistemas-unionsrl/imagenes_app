import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  File? _image;

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePicture(BuildContext context) async {
    if (_textController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor carga el código del artículo')),
      );
      return;
    }

    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final downloadsDir = Platform.isAndroid
          ? Directory('${directory?.parent.parent.parent.parent.path}/Download')
          : directory;
      final filePath = '${downloadsDir?.path}/${_textController.text}.jpg';

      final File newImage = await _image!.copy(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OK. Guardado en ${newImage.path}')),
      );

      _clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Se requiere permisos en la carpeta para guardar')),
      );
    }
  }

  void _clear() {
    setState(() {
      _textController.clear();
      _image = null;
    });
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'BACK') {
        if (_textController.text.isNotEmpty) {
          _textController.text = _textController.text
              .substring(0, _textController.text.length - 1);
        }
      } else {
        _textController.text += key;
      }
    });
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onKeyPressed(key),
          child: Text(
            key == 'BACK' ? '←' : key,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildKey('7'),
            _buildKey('8'),
            _buildKey('9'),
          ],
        ),
        Row(
          children: [
            _buildKey('4'),
            _buildKey('5'),
            _buildKey('6'),
          ],
        ),
        Row(
          children: [
            _buildKey('1'),
            _buildKey('2'),
            _buildKey('3'),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            _buildKey('0'),
            _buildKey('BACK'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mega Fotos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Ingrese un código y fotografíe',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              readOnly: true,
              showCursor: false,
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _takePicture,
                  child: const Text('Fotografiar'),
                ),
                ElevatedButton(
                  onPressed: () => _savePicture(context),
                  child: const Text('Guardar'),
                ),
                ElevatedButton(
                  onPressed: _clear,
                  child: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }
}
