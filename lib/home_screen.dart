import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _EmployeesView(),
    const _LeavesView(),
    const _AttendanceView(),
    const _PayrollView(),
    const _DocumentsView(),
    const _PerformanceView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF24243E), Color(0xFF312A6C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFFF7675)],
                    ).createShader(bounds),
                    child: const Text(
                      'HR NOVA',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildNavItem(0, Icons.people_alt_rounded, 'إدارة الموظفين'),
                  _buildNavItem(1, Icons.event_note_rounded, 'طلبات الإجازات'),
                  _buildNavItem(2, Icons.touch_app_rounded, 'الحضور والغياب اليدوي'),
                  _buildNavItem(3, Icons.payments_rounded, 'مسير الرواتب'),
                  _buildNavItem(4, Icons.folder_shared_rounded, 'إدارة الوثائق'),
                  _buildNavItem(5, Icons.analytics_rounded, 'مؤشرات الأداء والتقارير'),
                ],
              ),
            ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFFF7675)])
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white60),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// 1. شاشة الموظفين
class _EmployeesView extends StatelessWidget {
  const _EmployeesView();

  void _showEmployeeDialog(BuildContext context, {Employee? employee}) {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final roleController = TextEditingController(text: employee?.role ?? '');
    final deptController = TextEditingController(text: employee?.dept ?? '');
    final salaryController = TextEditingController(text: employee?.salary.toString() ?? '10000');
    final kpiController = TextEditingController(text: employee?.kpiScore.toString() ?? '85.0');

    final appState = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(
          employee == null ? 'إضافة موظف جديد' : 'تعديل بيانات الموظف',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'اسم الموظف'),
              _buildTextField(roleController, 'المسمى الوظيفي'),
              _buildTextField(deptController, 'القسم'),
              _buildTextField(salaryController, 'الراتب الشهرى (\$)'),
              _buildTextField(kpiController, 'تقييم الأداء (KPIs %)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final salary = double.tryParse(salaryController.text) ?? 10000;
                final kpi = double.tryParse(kpiController.text) ?? 85.0;

                if (employee == null) {
                  appState.addEmployee(nameController.text, roleController.text, deptController.text, 'emp@company.com', salary, kpi);
                } else {
                  appState.updateEmployee(employee.id, nameController.text, roleController.text, deptController.text, salary, kpi);
                }
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ التغييرات', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF6C5CE7))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => state.setSearchQuery(val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن موظف، قسم، أو مسمى وظيفي...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7675),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
                onPressed: () => _showEmployeeDialog(context),
                icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                label: const Text('إضافة موظف جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('إجمالي الموظفين', '${state.totalEmployees}', Icons.group, Colors.blue),
              _buildStatCard('معدل الحضور العام', '${state.overallAttendanceRate.toStringAsFixed(1)}%', Icons.check_circle, Colors.green),
              _buildStatCard('إجمالي الرواتب', '\$${state.totalSalaries.toStringAsFixed(0)}', Icons.attach_money, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final emp = state.employees[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6C5CE7),
                      child: Text(emp.name.isNotEmpty ? emp.name[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(emp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${emp.role} - ${emp.dept} | نسبة الحضور: ${emp.attendancePercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white60)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.cyan),
                          onPressed: () => _showEmployeeDialog(context, employee: emp),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => state.deleteEmployee(emp.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 2. شاشة الإجازات
class _LeavesView extends StatelessWidget {
  const _LeavesView();

  void _showAddLeaveDialog(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    String selectedEmp = state.employees.isNotEmpty ? state.employees.first.name : '';
    final typeController = TextEditingController(text: 'سنوية');
    final dateController = TextEditingController(text: '2026-10-01');
    final daysController = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('تقديم طلب إجازة جديد', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1E1E2C),
              initialValue: selectedEmp.isNotEmpty ? selectedEmp : null,
              items: state.employees.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (val) => selectedEmp = val ?? '',
              decoration: const InputDecoration(labelText: 'اختر الموظف', labelStyle: TextStyle(color: Colors.white60)),
            ),
            TextField(controller: typeController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'نوع الإجازة', labelStyle: TextStyle(color: Colors.white60))),
            TextField(controller: dateController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'تاريخ البدء', labelStyle: TextStyle(color: Colors.white60))),
            TextField(controller: daysController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'عدد الأيام', labelStyle: TextStyle(color: Colors.white60))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
            onPressed: () {
              if (selectedEmp.isNotEmpty) {
                final days = int.tryParse(daysController.text) ?? 1;
                state.addLeaveRequest(selectedEmp, typeController.text, dateController.text, days);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('إرسال الطلب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
              onPressed: () => _showAddLeaveDialog(context),
              icon: const Icon(Icons.add_task, color: Colors.white),
              label: const Text('طلب إجازة جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: state.leaveRequests.length,
              itemBuilder: (context, index) {
                final leave = state.leaveRequests[index];
                final isPending = leave.status == 'قيد الانتظار';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    title: Text('${leave.employeeName} - إجازة ${leave.type}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('تاريخ البدء: ${leave.startDate} | المدة: ${leave.days} أيام | الحالة: ${leave.status}', style: const TextStyle(color: Colors.white60)),
                    trailing: isPending
                        ? ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => state.approveLeave(leave.id),
                      child: const Text('موافقة وخصم الرصيد', style: TextStyle(color: Colors.white)),
                    )
                        : const Chip(label: Text('مقبولة', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blueAccent),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 3. شاشة التحضير والغياب اليدوي
class _AttendanceView extends StatefulWidget {
  const _AttendanceView();

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  String selectedDate = '2026-09-12';

  void _recordAttendanceDialog(BuildContext context, Employee emp) {
    String status = 'حاضر';
    final dateController = TextEditingController(text: selectedDate);
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text('تسجيل حالة للموظف: ${emp.name}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'التاريخ (YYYY-MM-DD)', labelStyle: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1E1E2C),
              initialValue: status,
              items: ['حاضر', 'غائب', 'غائب بعذر', 'متأخر']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (val) => status = val ?? 'حاضر',
              decoration: const InputDecoration(labelText: 'حالة الحضور', labelStyle: TextStyle(color: Colors.white60)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
            onPressed: () {
              state.recordAttendance(emp.id, dateController.text, status);
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ الحالة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إدارة الحضور والغياب اليدوي', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('التاريخ اليوم: $selectedDate', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final emp = state.employees[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white60,
                    title: Text(emp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('نسبة الحضور التراكمية: ${emp.attendancePercentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white60)),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: () => _recordAttendanceDialog(context, emp),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('تسجيل حالة', style: TextStyle(color: Colors.white)),
                    ),
                    children: [
                      const Divider(color: Colors.white12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('سجل الحضور والغياب السابق:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      ...emp.attendanceLogs.map((log) => ListTile(
                        dense: true,
                        title: Text('التاريخ: ${log.date}', style: const TextStyle(color: Colors.white70)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: log.status == 'حاضر'
                                ? Colors.green.withValues(alpha: 0.2)
                                : log.status == 'متأخر'
                                ? Colors.orange.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            log.status,
                            style: TextStyle(
                              color: log.status == 'حاضر'
                                  ? Colors.greenAccent
                                  : log.status == 'متأخر'
                                  ? Colors.orangeAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 4. شاشة مسير الرواتب
class _PayrollView extends StatelessWidget {
  const _PayrollView();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مسير الرواتب والمستحقات الماليّة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final emp = state.employees[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('القسم: ${emp.dept} | المسمى: ${emp.role}', style: const TextStyle(color: Colors.white60)),
                        ],
                      ),
                      Text('\$${emp.salary.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 5. شاشة إدارة الوثائق
class _DocumentsView extends StatelessWidget {
  const _DocumentsView();

  void _showAddDocDialog(BuildContext context, String empId) {
    final titleController = TextEditingController();
    final expiryController = TextEditingController(text: '2027-12-31');
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('إضافة وثيقة جديدة', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'عنوان الوثيقة (مثل: الهوية)', labelStyle: TextStyle(color: Colors.white60))),
            TextField(controller: expiryController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'تاريخ الانتهاء (YYYY-MM-DD)', labelStyle: TextStyle(color: Colors.white60))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                state.addDocument(empId, titleController.text, expiryController.text);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إدارة الوثائق والمستندات الرسمية', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final emp = state.employees[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white60,
                    title: Text('وثائق الموظف: ${emp.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('عدد الوثائق المرفوعة: ${emp.documents.length}', style: const TextStyle(color: Colors.white60)),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: () => _showAddDocDialog(context, emp.id),
                      icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                      label: const Text('رفع وثيقة', style: TextStyle(color: Colors.white)),
                    ),
                    children: emp.documents
                        .map((doc) => ListTile(
                      leading: const Icon(Icons.description, color: Colors.amberAccent),
                      title: Text(doc.title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('تاريخ الانتهاء: ${doc.expiryDate}', style: const TextStyle(color: Colors.white60)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => state.deleteDocument(emp.id, doc.id),
                      ),
                    ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 6. شاشة مؤشرات الأداء والتقارير الشاملة
class _PerformanceView extends StatelessWidget {
  const _PerformanceView();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مؤشرات الأداء والبيانات الإحصائية الشاملة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildReportCard('معدل الانضباط والتسجيل', '${state.overallAttendanceRate.toStringAsFixed(1)}%', Colors.purpleAccent),
              _buildReportCard('إجمالي رواتب الشركة', '\$${state.totalSalaries.toStringAsFixed(0)}', const Color(0xFF2ECC71)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('تقييم أداء الموظفين (KPIs)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final emp = state.employees[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Text('مؤشر الأداء: ', style: TextStyle(color: Colors.white60)),
                          Text('${emp.kpiScore}%', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}