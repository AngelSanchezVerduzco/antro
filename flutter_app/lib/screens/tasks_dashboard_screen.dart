import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/stats_widget.dart';

class TasksDashboardScreen extends StatefulWidget {
  const TasksDashboardScreen({super.key});

  @override
  State<TasksDashboardScreen> createState() => _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends State<TasksDashboardScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.media;

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Revisar reservaciones del viernes',
      description: 'Confirmar mesas VIP y lista de invitados.',
      priority: TaskPriority.alta,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Task(
      id: '2',
      title: 'Actualizar carta de cócteles',
      description: 'Agregar promo 2x1 de la semana.',
      priority: TaskPriority.media,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Task(
      id: '3',
      title: 'Publicar flyer en redes',
      description: 'Neon Party — subir a Instagram y TikTok.',
      completed: true,
      priority: TaskPriority.baja,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  int get _total => _tasks.length;
  int get _completed => _tasks.where((t) => t.completed).length;
  int get _pending => _total - _completed;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _tasks.insert(
        0,
        Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: _descController.text.trim(),
          priority: _priority,
          createdAt: DateTime.now(),
        ),
      );
      _titleController.clear();
      _descController.clear();
      _priority = TaskPriority.media;
    });
  }

  void _toggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index == -1) return;
      _tasks[index] = _tasks[index].copyWith(completed: !_tasks[index].completed);
    });
  }

  void _removeTask(String id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
  }

  Color _priorityColor(TaskPriority p) {
    return switch (p) {
      TaskPriority.alta => const Color(0xFFEF4444),
      TaskPriority.media => const Color(0xFFF59E0B),
      TaskPriority.baja => const Color(0xFF22C55E),
    };
  }

  String _priorityLabel(TaskPriority p) {
    return switch (p) {
      TaskPriority.alta => 'Alta',
      TaskPriority.media => 'Media',
      TaskPriority.baja => 'Baja',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C12),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Dashboard de tareas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Componente Flutter Web integrado en Angular',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 14),
            ),
            const SizedBox(height: 20),
            StatsWidget(
              total: _total,
              pending: _pending,
              completed: _completed,
            ),
            const SizedBox(height: 24),
            _buildAddForm(),
            const SizedBox(height: 24),
            Text(
              'Tareas (${_pending} pendientes)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (_tasks.isEmpty)
              Card(
                color: const Color(0xFF1A1A24),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No hay tareas. Agrega una arriba.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              )
            else
              ..._tasks.map(_buildTaskTile),
          ],
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1A1A24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nueva tarea',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Título'),
              onSubmitted: (_) => _addTask(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: _inputDecoration('Descripción (opcional)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              dropdownColor: const Color(0xFF1A1A24),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Prioridad'),
              items: TaskPriority.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(_priorityLabel(p)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _priority = v);
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar tarea'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    final priorityColor = _priorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: const Color(0xFF1A1A24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => _toggleTask(task.id),
          activeColor: const Color(0xFF8B5CF6),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white54,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _priorityLabel(task.priority),
                style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.white.withValues(alpha: 0.4), size: 20),
              onPressed: () => _removeTask(task.id),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}
