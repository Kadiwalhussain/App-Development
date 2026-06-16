import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/add_edit_todo_screen.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return const Color(0xFFFF6584);
      case Priority.medium:
        return const Color(0xFFFFB347);
      case Priority.low:
        return const Color(0xFF6BCB77);
    }
  }

  IconData _categoryIcon(Category c) {
    switch (c) {
      case Category.personal:
        return Icons.person_rounded;
      case Category.work:
        return Icons.work_rounded;
      case Category.shopping:
        return Icons.shopping_cart_rounded;
      case Category.health:
        return Icons.favorite_rounded;
      case Category.education:
        return Icons.school_rounded;
      case Category.other:
        return Icons.category_rounded;
    }
  }

  String _categoryLabel(Category c) => c.name[0].toUpperCase() + c.name.substring(1);

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final provider = context.read<TodoProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = _priorityColor(todo.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(todo.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => provider.toggleTodo(todo.id),
              backgroundColor: const Color(0xFF6BCB77),
              foregroundColor: Colors.white,
              icon: todo.isCompleted ? Icons.refresh : Icons.check_circle,
              label: todo.isCompleted ? 'Undo' : 'Done',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => _confirmDelete(context, provider),
              backgroundColor: const Color(0xFFFF6584),
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: () => _openEdit(context),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(color: priorityColor, width: 4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => provider.toggleTodo(todo.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: todo.isCompleted
                                ? colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: todo.isCompleted
                                  ? colorScheme.primary
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: todo.isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            if (todo.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                todo.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _Chip(
                                  icon: _categoryIcon(todo.category),
                                  label: _categoryLabel(todo.category),
                                  color: colorScheme.primary.withOpacity(0.1),
                                  textColor: colorScheme.primary,
                                ),
                                _Chip(
                                  icon: Icons.flag_rounded,
                                  label: todo.priority.name[0].toUpperCase() +
                                      todo.priority.name.substring(1),
                                  color: priorityColor.withOpacity(0.15),
                                  textColor: priorityColor,
                                ),
                                if (todo.dueDate != null)
                                  _Chip(
                                    icon: Icons.calendar_today_rounded,
                                    label: DateFormat('MMM d').format(todo.dueDate!),
                                    color: todo.isOverdue
                                        ? Colors.red.withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.12),
                                    textColor: todo.isOverdue ? Colors.red : Colors.grey,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTodoScreen(todo: widget.todo),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TodoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${widget.todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteTodo(widget.todo.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
