import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../widgets/note_list.dart';
import '../widgets/loading_indicator.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _databaseHelper.printDatabaseInfo();
      final notes = await _databaseHelper.getNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat catatan');
    }
  }

  void _addNote() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditNoteScreen(),
      ),
    );

    if (result != null && mounted) {
      try {
        final newNote = Note(
          title: result['title'] ?? 'No Title',
          description: result['description'] ?? 'No Description',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          label: result['label'] ?? 'Umum',
          color: result['color'] ?? '#2196F3',
          imagePath: result['imagePath'],
        );

        final id = await _databaseHelper.insertNote(newNote);
        newNote.id = id;
        await _loadNotes();
        _showSuccess('✅ Catatan berhasil ditambahkan');
      } catch (e) {
        _showError('Gagal menambah catatan: $e');
      }
    }
  }

  void _viewNote(Note note) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );

    if (result == 'edit' && mounted) {
      _editNote(note);
    } else if (result == 'deleted' && mounted) {
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
      _showSuccess('🗑️ Catatan "${note.title}" dihapus');
    }

    if (mounted) _loadNotes();
  }

  void _editNote(Note note) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    );

    if (result != null && mounted) {
      try {
        final updatedNote = Note(
          id: note.id,
          title: result['title'] ?? note.title,
          description: result['description'] ?? note.description,
          createdAt: note.createdAt,
          updatedAt: DateTime.now(),
          label: result['label'] ?? note.label,
          color: result['color'] ?? note.color,
          imagePath: result['imagePath'] ?? note.imagePath,
          isCompleted: note.isCompleted,
        );

        await _databaseHelper.updateNote(updatedNote);
        setState(() {
          final index = _notes.indexWhere((n) => n.id == note.id);
          if (index != -1) _notes[index] = updatedNote;
        });
        _showSuccess('✅ Catatan diperbarui');
      } catch (e) {
        _showError('Gagal memperbarui catatan: $e');
      }
    }
  }

  void _deleteNote(Note note) async {
    try {
      await _databaseHelper.deleteNote(note.id!);
      setState(() => _notes.removeWhere((n) => n.id == note.id));
      if (mounted) _showSuccess('🗑️ Catatan dihapus');
    } catch (e) {
      if (mounted) _showError('Gagal menghapus catatan: $e');
    }
  }

  void _toggleComplete(Note note, bool isCompleted) async {
    try {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        description: note.description,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
        isCompleted: isCompleted,
        imagePath: note.imagePath,
        label: note.label,
        color: note.color,
      );

      await _databaseHelper.updateNote(updatedNote);
      setState(() {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) _notes[index] = updatedNote;
      });
    } catch (e) {
      if (mounted) _showError('Gagal mengubah status: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Hapus Semua Catatan',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Apakah kamu yakin ingin menghapus semua catatan (${_notes.length})?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllNotes();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  void _deleteAllNotes() async {
    try {
      final count = _notes.length;
      for (var note in _notes) {
        await _databaseHelper.deleteNote(note.id!);
      }
      setState(() => _notes.clear());
      if (mounted) _showSuccess('🗑️ $count catatan dihapus');
    } catch (e) {
      if (mounted) _showError('Gagal menghapus semua catatan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Catatan Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 2,
        actions: [
          if (_notes.isNotEmpty)
            PopupMenuButton<String>(
              color: const Color(0xFF2C2C2C),
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'delete_all') {
                  _showDeleteAllConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Hapus Semua', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _notes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add, size: 80, color: Colors.white24),
                      SizedBox(height: 20),
                      Text('Belum ada catatan',
                          style: TextStyle(color: Colors.white70, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Tap tombol + untuk menambah',
                          style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.blueAccent,
                  onRefresh: _loadNotes,
                  child: NoteList(
                    notes: _notes,
                    onTap: _viewNote,
                    onDelete: _deleteNote,
                    onToggleComplete: _toggleComplete,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
