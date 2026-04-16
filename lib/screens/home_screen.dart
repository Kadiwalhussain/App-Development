import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import 'add_edit_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filters = [FilterType.all, FilterType.active, FilterType.completed];
        context.read<TodoProvider>().setFilter(filters[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(_showSearch ? Icons.search_off : Icons.search),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (!_showSearch) {
                    _searchCtrl.clear();
                    provider.setSearchQuery('');
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  provider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: provider.toggleTheme,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) {
                  if (v == 'clear') {
                    _confirmClearCompleted(context, provider);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Clear Completed'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withBlue(
                          (colorScheme.primary.blue + 60).clamp(0, 255)),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _StatBadge(
                              label: 'Total',
                              count: provider.totalCount,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 8),
                            _StatBadge(
                              label: 'Active',
                              count: provider.activeCount,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 8),
                            _StatBadge(
                              label: 'Done',
                              count: provider.completedCount,
                              color: Colors.white24,
                            ),
                            if (provider.overdueCount > 0) ...[
                              const SizedBox(width: 8),
                              _StatBadge(
                                label: 'Overdue',
                                count: provider.overdueCount,
                                color: Colors.red.withOpacity(0.6),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Active'),
                  Tab(text: 'Done'),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _showSearch
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: provider.setSearchQuery,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            _CategoryFilterBar(provider: provider),
            Expanded(
              child: _TodoList(provider: provider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditTodoScreen()),
        ),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context, TodoProvider provider) {
    if (provider.completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No completed tasks to clear')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Completed'),
        content: Text(
            'Remove all ${provider.completedCount} completed tasks?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              provider.clearCompleted();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final TodoProvider provider;

  const _CategoryFilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    const categories = [
      (null, 'All', Icons.apps_rounded),
      (Category.personal, 'Personal', Icons.person_rounded),
      (Category.work, 'Work', Icons.work_rounded),
      (Category.shopping, 'Shopping', Icons.shopping_cart_rounded),
      (Category.health, 'Health', Icons.favorite_rounded),
      (Category.education, 'Education', Icons.school_rounded),
      (Category.other, 'Other', Icons.category_rounded),
    ];

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final (cat, label, icon) = categories[i];
          final isSelected = provider.categoryFilter == cat;
          final colorScheme = Theme.of(ctx).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(icon, size: 16),
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => provider.setCategoryFilter(cat),
              selectedColor: colorScheme.primary.withOpacity(0.15),
              checkmarkColor: colorScheme.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : null,
              ),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  final TodoProvider provider;

  const _TodoList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final todos = provider.todos;

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'No tasks match your search'
                  : 'No tasks yet!\nTap + to add one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: todos.length,
      itemBuilder: (ctx, i) => TodoItem(todo: todos[i]),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
