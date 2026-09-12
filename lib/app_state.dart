import 'package:flutter/material.dart';

// ==================== Models ====================

class EmployeeDocument {
  final String id;
  final String title;
  final String expiryDate;

  EmployeeDocument({
    required this.id,
    required this.title,
    required this.expiryDate,
  });
}

class AttendanceRecord {
  final String date;
  final String status; // حاضر, غائب, متأخر, غائب بعذر

  AttendanceRecord({
    required this.date,
    required this.status,
  });
}

class Employee {
  final String id;
  String name;
  String role;
  String dept;
  String email;
  double salary;
  double kpiScore;
  double attendancePercentage;
  List<AttendanceRecord> attendanceLogs;
  List<EmployeeDocument> documents;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.dept,
    required this.email,
    required this.salary,
    this.kpiScore = 85.0,
    this.attendancePercentage = 100.0,
    List<AttendanceRecord>? attendanceLogs,
    List<EmployeeDocument>? documents,
  })  : attendanceLogs = attendanceLogs ?? [],
        documents = documents ?? [];
}

class LeaveRequest {
  final String id;
  final String employeeName;
  final String type;
  final String startDate;
  final int days;
  String status;

  LeaveRequest({
    required this.id,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.days,
    this.status = 'قيد الانتظار',
  });
}

// ==================== App State Provider ====================

class AppState extends ChangeNotifier {
  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'أحمد علي',
      role: 'مطور تطبيقات',
      dept: 'تقنية المعلومات',
      email: 'ahmed@company.com',
      salary: 12000,
      kpiScore: 92.0,
      attendancePercentage: 96.0,
      attendanceLogs: [
        AttendanceRecord(date: '2026-09-10', status: 'حاضر'),
        AttendanceRecord(date: '2026-09-11', status: 'حاضر'),
      ],
      documents: [
        EmployeeDocument(id: 'd1', title: 'الهوية الوطنية', expiryDate: '2028-05-10'),
      ],
    ),
    Employee(
      id: '2',
      name: 'سارة محمود',
      role: 'مديرة HR',
      dept: 'الموارد البشرية',
      email: 'sara@company.com',
      salary: 15000,
      kpiScore: 88.0,
      attendancePercentage: 98.0,
      attendanceLogs: [
        AttendanceRecord(date: '2026-09-10', status: 'حاضر'),
      ],
    ),
  ];

  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'l1',
      employeeName: 'أحمد علي',
      type: 'سنوية',
      startDate: '2026-10-01',
      days: 5,
    ),
  ];

  String _searchQuery = '';

  // Getters
  List<Employee> get employees {
    if (_searchQuery.isEmpty) return _employees;
    return _employees.where((emp) {
      return emp.name.contains(_searchQuery) ||
          emp.role.contains(_searchQuery) ||
          emp.dept.contains(_searchQuery);
    }).toList();
  }

  List<LeaveRequest> get leaveRequests => _leaveRequests;
  int get totalEmployees => _employees.length;

  double get totalSalaries =>
      _employees.fold(0, (sum, item) => sum + item.salary);

  double get overallAttendanceRate {
    if (_employees.isEmpty) return 0.0;
    final total = _employees.fold(0.0, (sum, item) => sum + item.attendancePercentage);
    return total / _employees.length;
  }

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addEmployee(String name, String role, String dept, String email, double salary, double kpi) {
    final newEmp = Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: role,
      dept: dept,
      email: email,
      salary: salary,
      kpiScore: kpi,
    );
    _employees.add(newEmp);
    notifyListeners();
  }

  void updateEmployee(String id, String name, String role, String dept, double salary, double kpi) {
    final index = _employees.indexWhere((e) => e.id == id);
    if (index != -1) {
      _employees[index].name = name;
      _employees[index].role = role;
      _employees[index].dept = dept;
      _employees[index].salary = salary;
      _employees[index].kpiScore = kpi;
      notifyListeners();
    }
  }

  void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addLeaveRequest(String empName, String type, String startDate, int days) {
    _leaveRequests.add(
      LeaveRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeName: empName,
        type: type,
        startDate: startDate,
        days: days,
      ),
    );
    notifyListeners();
  }

  void approveLeave(String leaveId) {
    final index = _leaveRequests.indexWhere((l) => l.id == leaveId);
    if (index != -1) {
      _leaveRequests[index].status = 'مقبولة';
      notifyListeners();
    }
  }

  void recordAttendance(String empId, String date, String status) {
    final index = _employees.indexWhere((e) => e.id == empId);
    if (index != -1) {
      _employees[index].attendanceLogs.add(
        AttendanceRecord(date: date, status: status),
      );
      notifyListeners();
    }
  }

  void addDocument(String empId, String title, String expiryDate) {
    final index = _employees.indexWhere((e) => e.id == empId);
    if (index != -1) {
      _employees[index].documents.add(
        EmployeeDocument(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          expiryDate: expiryDate,
        ),
      );
      notifyListeners();
    }
  }

  void deleteDocument(String empId, String docId) {
    final index = _employees.indexWhere((e) => e.id == empId);
    if (index != -1) {
      _employees[index].documents.removeWhere((d) => d.id == docId);
      notifyListeners();
    }
  }
}