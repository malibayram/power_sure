import 'package:flutter/material.dart';

import '../models/employee_profile.dart';
import '../models/service_request.dart';
import '../services/matching_service.dart';

class RequestMatchingPage extends StatefulWidget {
  final ServiceRequest request;
  const RequestMatchingPage({super.key, required this.request});

  @override
  State<RequestMatchingPage> createState() => _RequestMatchingPageState();
}

class _RequestMatchingPageState extends State<RequestMatchingPage> {
  final _matchingService = MatchingService();
  List<EmployeeProfile> _matchingEmployees = [];
  bool _isLoading = true;
  final Set<String> _selectedEmployees = {};

  @override
  void initState() {
    super.initState();
    _loadMatchingEmployees();
  }

  Future<void> _loadMatchingEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees =
          await _matchingService.findMatchingEmployees(widget.request);
      setState(() {
        _matchingEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      // Hata yönetimi
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eşleşen Çalışanlar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Talep detayları
                _buildRequestDetails(),

                // Eşleşen çalışanlar listesi
                Expanded(
                  child: ListView.builder(
                    itemCount: _matchingEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = _matchingEmployees[index];
                      return _buildEmployeeCard(employee);
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildEmployeeCard(EmployeeProfile employee) {
    final isSelected = _selectedEmployees.contains(employee.userId);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedEmployees.add(employee.userId);
              } else {
                _selectedEmployees.remove(employee.userId);
              }
            });
          },
        ),
        title: Text('${employee.name} (${employee.role})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uzmanlık: ${employee.specializations.join(", ")}'),
            Text('Konum: ${employee.location}'),
            Text('Sertifikalar: ${employee.certifications.join(", ")}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _selectedEmployees.isEmpty
            ? null
            : () async {
                try {
                  await _matchingService.createMatch(
                    widget.request,
                    _selectedEmployees.toList(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eşleştirme başarıyla oluşturuldu'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eşleştirme oluşturulurken hata oluştu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        child: const Text('Eşleştirmeyi Onayla'),
      ),
    );
  }

  Widget _buildRequestDetails() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proje: ${widget.request.description}'),
            Text('Konum: ${widget.request.location}'),
            Text('Bütçe: ${widget.request.budget}'),
            Text('Proje Boyutu: ${widget.request.projectSize}'),
            Text('Hizmet Türleri: ${widget.request.serviceTypes.join(", ")}'),
          ],
        ),
      ),
    );
  }
}
