import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';

class DistanceTrackerPage extends StatefulWidget {
  final int?
  exerciseTypeId; // e.g., 91 for Running, 92 for Cycling, 93 for Swimming
  final String exerciseTypeName;

  const DistanceTrackerPage({
    Key? key,
    this.exerciseTypeId,
    this.exerciseTypeName = 'Distance Exercise',
  }) : super(key: key);

  @override
  State<DistanceTrackerPage> createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  final LocationService _locationService = LocationService();
  bool _isTracking = false;
  bool _isPaused = false;
  double _distance = 0.0;
  double _currentSpeed = 0.0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _locationService.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await LocationService.checkPermissions();
    if (!hasPermission && mounted) {
      setState(() {
        _errorMessage =
            'Location permission required. Please enable location services and grant permission.';
      });
    }
  }

  void _startTracking() async {
    final hasPermission = await LocationService.checkPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isTracking = true;
      _isPaused = false;
      _distance = 0.0;
      _currentSpeed = 0.0;
      _elapsedSeconds = 0;
      _errorMessage = null;
    });

    // Start location tracking
    await _locationService.startTracking((distance, speed) {
      if (!_isPaused && mounted) {
        setState(() {
          _distance = distance;
          _currentSpeed = speed;
        });
      }
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseResume() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopTracking() {
    _locationService.stopTracking();
    _timer?.cancel();

    if (_distance < 10) {
      // Less than 10 meters, probably not a real workout
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Distance Too Short'),
              content: const Text(
                'You need to cover at least 10 meters to save this workout.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isTracking = false;
                      _distance = 0;
                      _elapsedSeconds = 0;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // Show save dialog
    _showSaveDialog();
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Workout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exerciseTypeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Distance: ${(_distance / 1000).toStringAsFixed(2)} km'),
                Text('Duration: ${_formatDuration(_elapsedSeconds)}'),
                Text(
                  'Avg Speed: ${_calculateAverageSpeed().toStringAsFixed(2)} km/h',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isTracking = false;
                    _distance = 0;
                    _elapsedSeconds = 0;
                  });
                },
                child: const Text('Discard'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _saveWorkout();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveWorkout() async {
    // TODO: Implement API call to save exercise session
    // This would involve calling an endpoint like:
    // POST /api/exercises with data:
    // {
    //   "exerciseTypeId": widget.exerciseTypeId,
    //   "durationSeconds": _elapsedSeconds,
    //   "distanceMeters": _distance,
    //   "avgSpeed": _calculateAverageSpeed(),
    //   "date": DateTime.now().toIso8601String()
    // }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.exerciseTypeName} workout saved!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isTracking = false;
        _distance = 0;
        _elapsedSeconds = 0;
      });
    }
  }

  double _calculateAverageSpeed() {
    if (_elapsedSeconds == 0) return 0.0;
    final hours = _elapsedSeconds / 3600;
    return (_distance / 1000) / hours;
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatPace() {
    if (_distance == 0) return '--:--';
    final kmPerHour = _currentSpeed;
    if (kmPerHour == 0) return '--:--';

    final minutesPerKm = 60 / kmPerHour;
    final minutes = minutesPerKm.floor();
    final seconds = ((minutesPerKm - minutes) * 60).round();

    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseTypeName)),
      body:
          _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _checkPermissions,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Again'),
                      ),
                    ],
                  ),
                ),
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Distance Display
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          children: [
                            Text(
                              (_distance / 1000).toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              'km',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            'Time',
                            _formatDuration(_elapsedSeconds),
                            Icons.timer,
                          ),
                          _buildStatCard(
                            'Speed',
                            '${_currentSpeed.toStringAsFixed(1)} km/h',
                            Icons.speed,
                          ),
                          _buildStatCard(
                            'Pace',
                            '${_formatPace()} /km',
                            Icons.trending_down,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Control Buttons
                      if (!_isTracking)
                        ElevatedButton.icon(
                          onPressed: _startTracking,
                          icon: const Icon(Icons.play_arrow, size: 32),
                          label: const Text(
                            'Start',
                            style: TextStyle(fontSize: 24),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pauseResume,
                              icon: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                size: 28,
                              ),
                              label: Text(
                                _isPaused ? 'Resume' : 'Pause',
                                style: const TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _stopTracking,
                              icon: const Icon(Icons.stop, size: 28),
                              label: const Text(
                                'Stop',
                                style: TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
