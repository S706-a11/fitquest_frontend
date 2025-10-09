import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Debug page to test API connectivity
/// Navigate to this page to test if your API is working correctly
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _result = 'Press a button to test the API';
  bool _isLoading = false;

  Future<void> _testEndpoint(
    String name,
    Future<dynamic> Function() apiCall,
  ) async {
    setState(() {
      _isLoading = true;
      _result = 'Testing $name...';
    });

    try {
      final response = await apiCall();
      setState(() {
        _result = '✅ $name SUCCESS\n\n${response.toString()}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ $name FAILED\n\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Base URL:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'http://localhost:5105/api',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Test Endpoints:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Get All Users',
              Icons.people,
              () => _testEndpoint('GET /api/users', ApiService.getUsers),
            ),
            _buildTestButton(
              'Get Exercise Types',
              Icons.fitness_center,
              () => _testEndpoint(
                'GET /api/exercise-types',
                ApiService.getExerciseTypes,
              ),
            ),
            _buildTestButton(
              'Get Exercises',
              Icons.directions_run,
              () =>
                  _testEndpoint('GET /api/exercises', ApiService.getExercises),
            ),
            _buildTestButton(
              'Create Test User',
              Icons.person_add,
              () => _testEndpoint(
                'POST /api/users',
                () => ApiService.createUser(
                  name: 'Test User ${DateTime.now().millisecondsSinceEpoch}',
                  email:
                      'test${DateTime.now().millisecondsSinceEpoch}@example.com',
                  password: 'password123',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFF1A1A1D),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.code,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Result:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      SelectableText(
                        _result,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade900.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Troubleshooting',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Make sure your API is running at http://localhost:5105\n'
                      '2. Check Swagger UI: http://localhost:5105/swagger/index.html\n'
                      '3. For Android emulator, use: http://10.0.2.2:5105\n'
                      '4. For physical device, use your computer\'s IP address',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          backgroundColor: const Color(0xFF00FF99),
          foregroundColor: Colors.black,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
