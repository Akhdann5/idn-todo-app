import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../utils/text_formatter.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedLabel = 'Umum';
  String _selectedColor = '#2196F3';
  String? _imagePath;
  String _previousText = '';

  final List<String> _labels = [
    'Umum',
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Kesehatan'
  ];

  final Map<String, Color> _colors = {
    '#2196F3': Colors.blue,
    '#4CAF50': Colors.green,
    '#FF9800': Colors.orange,
    '#F44336': Colors.red,
    '#9C27B0': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _selectedLabel = widget.note!.label;
      _selectedColor = widget.note!.color;
      _imagePath = widget.note!.imagePath;
    }
    _previousText = _descriptionController.text;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() => _imagePath = pickedFile.path);
      }
    } catch (e) {
      _showError('Gagal memilih gambar');
    }
  }

  void _removeImage() => setState(() => _imagePath = null);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'label': _selectedLabel,
        'color': _selectedColor,
        'imagePath': _imagePath,
      };
      Navigator.of(context).pop(result);
    }
  }

  void _addChecklistItem(bool checked) {
    final cursor = _descriptionController.selection.baseOffset;
    final newText = TextFormatter.addChecklistItem(
        _descriptionController.text, cursor,
        checked: checked);
    _descriptionController.text = newText;
  }

  void _addNumberedItem() {
    final cursor = _descriptionController.selection.baseOffset;
    final newText =
        TextFormatter.addNumberedItem(_descriptionController.text, cursor);
    _descriptionController.text = newText;
  }

  void _toggleChecklistItem() {
    final cursor = _descriptionController.selection.baseOffset;
    final newText = TextFormatter.toggleChecklistAtCursor(
        _descriptionController.text, cursor);
    _descriptionController.text = newText;
  }

  void _handleTextChange(String newValue) {
    _previousText = newValue;
  }

  Widget _buildFormatButton(
      {required IconData icon,
      required String tooltip,
      required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text(
          isEditing ? 'Edit Catatan' : 'Tambah Catatan',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Judul
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Judul *',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Toolbar
              Row(
                children: [
                  _buildFormatButton(
                    icon: Icons.check_box_outline_blank,
                    tooltip: 'Checklist Kosong',
                    onPressed: () => _addChecklistItem(false),
                  ),
                  const SizedBox(width: 8),
                  _buildFormatButton(
                    icon: Icons.check_box,
                    tooltip: 'Checklist Tercentang',
                    onPressed: () => _addChecklistItem(true),
                  ),
                  const SizedBox(width: 8),
                  _buildFormatButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Nomor',
                    onPressed: _addNumberedItem,
                  ),
                  const SizedBox(width: 8),
                  _buildFormatButton(
                    icon: Icons.toggle_on,
                    tooltip: 'Toggle Checklist',
                    onPressed: _toggleChecklistItem,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Deskripsi *',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _handleTextChange,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Label
              DropdownButtonFormField<String>(
                value: _selectedLabel,
                dropdownColor: const Color(0xFF1A1A1A),
                decoration: InputDecoration(
                  labelText: 'Label',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                items: _labels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedLabel = v!),
              ),
              const SizedBox(height: 16),

              // Warna
              DropdownButtonFormField<String>(
                value: _selectedColor,
                dropdownColor: const Color(0xFF1A1A1A),
                decoration: InputDecoration(
                  labelText: 'Warna',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                items: _colors.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedColor = v!),
              ),
              const SizedBox(height: 16),

              // Gambar
              Card(
                color: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gambar',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library, color: Colors.white),
                          label: const Text('Pilih dari Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (_imagePath != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _imagePath!.split('/').last,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          )
                        ]
                      ]),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'UPDATE CATATAN' : 'SIMPAN CATATAN',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
