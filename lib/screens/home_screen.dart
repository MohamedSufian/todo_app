import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_tile.dart';
import 'task_form_screen.dart';

/// خيارات ترتيب قائمة المهام.
enum _SortOption {
  newest,
  oldest,
  dueDate,
  priority,
  alphabetical;

  String get label {
    switch (this) {
      case _SortOption.newest:
        return 'الأحدث أولاً';
      case _SortOption.oldest:
        return 'الأقدم أولاً';
      case _SortOption.dueDate:
        return 'حسب تاريخ الاستحقاق';
      case _SortOption.priority:
        return 'حسب الأولوية';
      case _SortOption.alphabetical:
        return 'أبجديًا (أ-ي)';
    }
  }
}

/// الشاشة الرئيسية: تعرض قائمة المهام من قاعدة البيانات (عبر TaskProvider)،
/// مع بحث، فرز، فلترة حسب التصنيف، وحالة فارغة لطيفة.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';
  _SortOption _sortOption = _SortOption.newest;
  TaskCategory? _categoryFilter; // null = الكل

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _query = '';
      _searchController.clear();
    });
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'الوضع الفاتح مفعّل';
      case ThemeMode.dark:
        return 'الوضع الغامق مفعّل';
      case ThemeMode.system:
        return 'يتبع إعدادات الجهاز';
    }
  }

  List<Task> _applyFilters(List<Task> tasks) {
    var result = tasks;

    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    final sorted = [...result];
    switch (_sortOption) {
      case _SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.dueDate:
        sorted.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1; // بدون تاريخ آخر شي
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case _SortOption.priority:
        sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      case _SortOption.alphabetical:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن مهمة...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _query = value),
              )
            : const Text('مهامي'),
        actions: [
          IconButton(
            tooltip: _isSearching ? 'إغلاق البحث' : 'بحث',
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _isSearching ? _stopSearch : _startSearch,
          ),
          if (!_isSearching) ...[
            PopupMenuButton<_SortOption>(
              tooltip: 'ترتيب حسب',
              icon: const Icon(Icons.sort),
              initialValue: _sortOption,
              onSelected: (value) => setState(() => _sortOption = value),
              itemBuilder: (context) => _SortOption.values
                  .map(
                    (option) => PopupMenuItem(
                      value: option,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
            ),
            IconButton(
              tooltip: _themeModeLabel(themeProvider.themeMode),
              icon: Icon(_themeModeIcon(themeProvider.themeMode)),
              onPressed: () => themeProvider.cycleThemeMode(),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _CategoryFilterBar(
            selected: _categoryFilter,
            onSelected: (category) =>
                setState(() => _categoryFilter = category),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final visibleTasks = _applyFilters(provider.tasks);

                if (provider.tasks.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'ما في مهام لسا',
                    subtitle: 'اضغط على + تحت حتى تضيف أول مهمة',
                  );
                }

                if (visibleTasks.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'ولا مهمة مطابقة',
                    subtitle: 'جرب تغيّر كلمة البحث أو الفلتر',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: visibleTasks.length,
                  itemBuilder: (context, index) {
                    final task = visibleTasks[index];
                    return TaskTile(
                      task: task,
                      onToggle: (_) => provider.toggleDone(task),
                      onDelete: () => provider.deleteTask(task),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskFormScreen(task: task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final TaskCategory? selected;
  final ValueChanged<TaskCategory?> onSelected;

  const _CategoryFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: const Text('الكل'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...TaskCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(category.label),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
