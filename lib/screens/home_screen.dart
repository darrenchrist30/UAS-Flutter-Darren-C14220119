import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  late AnimationController _statsAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _statsAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _statsAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.bounceOut),
    );

    // Start animations
    _statsAnimationController.forward();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _statsAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Daily Planner',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        actions: [
          // Profile/Logout Button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, TaskProvider>(
        builder: (context, authProvider, taskProvider, child) {
          if (authProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Task>>(
            stream: taskProvider.getTasksStream(authProvider.user!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data ?? [];
              // Update the task provider with the new data
              taskProvider.updateTaskList(tasks);

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh is handled by the stream
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(authProvider.user!.email ?? 'User'),
                      const SizedBox(height: 24),

                      // Date Selector
                      _buildDateSelector(),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      _buildStatsCards(taskProvider.tasks),
                      const SizedBox(height: 24),

                      // Tasks Section
                      _buildTasksSection(
                        taskProvider.tasks,
                        authProvider.user!.id,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddTaskDialog(context),
              backgroundColor: Colors.indigo.shade400,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Task',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 8,
              heroTag: 'addTask',
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(String userEmail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail.split('@')[0],
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s make today productive!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.emoji_emotions, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      children: [
        // Date picker button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _selectDateFromPicker,
            icon: Icon(Icons.calendar_today, size: 18),
            label: Text(
              DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              foregroundColor: Colors.grey.shade700,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        // Quick date options
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickDateOption('Today', DateTime.now()),
              _buildQuickDateOption(
                'Tomorrow',
                DateTime.now().add(Duration(days: 1)),
              ),
              _buildQuickDateOption('This Week', _getThisWeekEnd()),
              _buildQuickDateOption('Next Week', _getNextWeekEnd()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickDateOption(String label, DateTime date) {
    final isSelected = DateUtils.isSameDay(date, selectedDate);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.indigo.shade400 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateFromPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildStatsCards(List<Task> tasks) {
    final selectedTasks = _getTasksForSelectedDate(tasks);

    final completedTasks = selectedTasks
        .where((task) => task.isCompleted)
        .length;
    final totalTasks = selectedTasks.length;
    final pendingTasks = totalTasks - completedTasks;

    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  totalTasks.toString(),
                  Icons.task_alt,
                  Colors.indigo.shade400,
                  0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedTasks.toString(),
                  Icons.check_circle,
                  Colors.green.shade400,
                  100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingTasks.toString(),
                  Icons.pending,
                  Colors.orange.shade400,
                  200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    int animationDelay,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + animationDelay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 600 + animationDelay),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, iconValue, child) {
                    return Transform.scale(
                      scale: iconValue,
                      child: Icon(icon, color: color, size: 24),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<int>(
                  duration: Duration(milliseconds: 1000 + animationDelay),
                  tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                  builder: (context, animatedValue, child) {
                    return Text(
                      animatedValue.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    );
                  },
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksSection(List<Task> tasks, String userId) {
    final selectedDateTasks = _getTasksForSelectedDate(tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getTasksSectionTitle(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        selectedDateTasks.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedDateTasks.length,
                itemBuilder: (context, index) {
                  final task = selectedDateTasks[index];
                  return TaskCard(
                    task: task,
                    onToggleComplete: (isCompleted) {
                      context.read<TaskProvider>().toggleTaskCompletion(
                        task.id!,
                        isCompleted,
                      );
                      _showSuccessSnackBar(
                        context,
                        isCompleted
                            ? 'Task marked as completed!'
                            : 'Task marked as pending!',
                        isCompleted ? Icons.check_circle : Icons.pending,
                      );
                    },
                    onDelete: () {
                      context.read<TaskProvider>().deleteTask(task.id!);
                      _showSuccessSnackBar(
                        context,
                        'Task deleted successfully!',
                        Icons.delete,
                      );
                    },
                    onEdit: () {
                      _showEditTaskDialog(context, task);
                    },
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.task_alt_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tasks for this date',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddTaskDialog(
        selectedDate: selectedDate,
        onTaskAdded: (task) {
          context.read<TaskProvider>().addTask(task);
          _showSuccessSnackBar(
            context,
            'Task added successfully!',
            Icons.add_task,
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddTaskDialog(
        selectedDate: selectedDate,
        task: task,
        onTaskAdded: (updatedTask) {
          context.read<TaskProvider>().updateTask(updatedTask);
          _showSuccessSnackBar(
            context,
            'Task updated successfully!',
            Icons.edit,
          );
        },
      ),
    );
  }

  void _showSuccessSnackBar(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();

        if (context.mounted) {
          // Show success message
          _showSuccessSnackBar(
            context,
            'Logged out successfully!',
            Icons.logout,
          );

          // Use GoRouter for navigation
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to logout. Please try again.');
        }
      }
    }
  }

  // Helper methods untuk menghitung tanggal week
  DateTime _getThisWeekEnd() {
    final now = DateTime.now();
    // This week = hari ini + 6 hari kedepan
    return now.add(Duration(days: 6));
  }

  DateTime _getNextWeekEnd() {
    final now = DateTime.now();
    // Next week = hari ini + 7 hari (mulai minggu depan) + 6 hari (akhir minggu depan)
    return now.add(Duration(days: 13));
  }

  // Helper method untuk filter tasks berdasarkan range tanggal
  List<Task> _getTasksForSelectedDate(List<Task> allTasks) {
    if (_isThisWeekSelected()) {
      // Filter untuk minggu ini (hari ini sampai 6 hari kedepan)
      final now = DateTime.now();
      final endOfWeek = now.add(Duration(days: 6));
      return allTasks.where((task) {
        return task.dateTime.isAfter(now.subtract(Duration(days: 1))) &&
            task.dateTime.isBefore(endOfWeek.add(Duration(days: 1)));
      }).toList();
    } else if (_isNextWeekSelected()) {
      // Filter untuk minggu depan (7-13 hari dari hari ini)
      final now = DateTime.now();
      final startOfNextWeek = now.add(Duration(days: 7));
      final endOfNextWeek = now.add(Duration(days: 13));
      return allTasks.where((task) {
        return task.dateTime.isAfter(
              startOfNextWeek.subtract(Duration(days: 1)),
            ) &&
            task.dateTime.isBefore(endOfNextWeek.add(Duration(days: 1)));
      }).toList();
    } else {
      // Filter untuk tanggal spesifik
      return allTasks.where((task) {
        return DateUtils.isSameDay(task.dateTime, selectedDate);
      }).toList();
    }
  }

  bool _isThisWeekSelected() {
    return DateUtils.isSameDay(selectedDate, _getThisWeekEnd());
  }

  bool _isNextWeekSelected() {
    return DateUtils.isSameDay(selectedDate, _getNextWeekEnd());
  }

  String _getTasksSectionTitle() {
    if (_isThisWeekSelected()) {
      final now = DateTime.now();
      final endOfWeek = now.add(Duration(days: 6));
      return 'Tasks This Week (${DateFormat('MMM dd').format(now)} - ${DateFormat('MMM dd').format(endOfWeek)})';
    } else if (_isNextWeekSelected()) {
      final now = DateTime.now();
      final startOfNextWeek = now.add(Duration(days: 7));
      final endOfNextWeek = now.add(Duration(days: 13));
      return 'Tasks Next Week (${DateFormat('MMM dd').format(startOfNextWeek)} - ${DateFormat('MMM dd').format(endOfNextWeek)})';
    } else {
      return 'Tasks for ${DateFormat('MMM dd').format(selectedDate)}';
    }
  }
}
