import 'package:flutter/material.dart';
import 'dart:io';
import '../models/note.dart';
import '../utils/text_formatter.dart';
import '../database/database_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note currentNote;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    currentNote = widget.note;
  }

  Future<void> _toggleChecklist(int lineIndex) async {
    try {
      final newDescription = TextFormatter.toggleChecklistAtPosition(
          currentNote.description, lineIndex);

      final updatedNote = Note(
        id: currentNote.id,
        title: currentNote.title,
        description: newDescription,
        createdAt: currentNote.createdAt,
        updatedAt: DateTime.now(),
        isCompleted: currentNote.isCompleted,
        imagePath: currentNote.imagePath,
        label: currentNote.label,
        color: currentNote.color,
      );

      await _databaseHelper.updateNote(updatedNote);

      setState(() {
        currentNote = updatedNote;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Checklist diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal memperbarui checklist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _getColorFromHex(currentNote.color),
        title: Text(
          currentNote.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop('edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            currentNote.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: currentNote.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorFromHex(currentNote.color),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            currentNote.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          currentNote.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: currentNote.isCompleted
                              ? Colors.green
                              : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentNote.isCompleted
                              ? 'Selesai'
                              : 'Belum selesai',
                          style: TextStyle(
                            color: currentNote.isCompleted
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...TextFormatter.buildInteractiveFormattedText(
                      currentNote.description,
                      baseStyle: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.5,
                        decoration: currentNote.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      onChecklistToggle: _toggleChecklist,
                    ),
                  ],
                ),
              ),

              if (currentNote.imagePath != null) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gambar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(currentNote.imagePath!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Dibuat',
                      value: _formatDate(currentNote.createdAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.update,
                      label: 'Diupdate',
                      value: _formatDate(currentNote.updatedAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.palette,
                      label: 'Warna',
                      value: currentNote.color,
                      trailing: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getColorFromHex(currentNote.color),
                          borderRadius: BorderRadius.circular(4),
                        ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse("0x$hexColor"));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Catatan',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus catatan ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _databaseHelper.deleteNote(currentNote.id!);
                if (mounted) Navigator.of(context).pop('deleted');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
