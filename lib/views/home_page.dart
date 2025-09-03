import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_flutter/viewmodels/consultation_view_model.dart';
import 'package:firebase_flutter/routes/app_router.dart';
import 'package:firebase_flutter/views/consultation_details_screen.dart';

class MainPage extends StatefulWidget {
  final String email;
  const MainPage({super.key, required this.email});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshConsultations();
    });
  }

  Future<void> _refreshConsultations() async {
    await Provider.of<ConsultationViewModel>(
      context,
      listen: false,
    ).fetchConsultations();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, RouteManager.profile);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Helper method to group consultations by date
  Map<String, List<dynamic>> _groupConsultationsByDate(
    List<dynamic> consultations,
  ) {
    final Map<String, List<dynamic>> grouped = {};

    for (var consultation in consultations) {
      final dateTime = consultation['dateTime'] as DateTime;
      final dateKey = DateFormat('yyyy-MM-dd').format(dateTime);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(consultation);
    }

    // Sort dates in chronological order
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

    final Map<String, List<dynamic>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  // Helper method to get status indicator widget
  Widget _buildStatusIndicator(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'confirmed' ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: status == 'confirmed' ? Colors.green[800] : Colors.orange[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consultationViewModel = Provider.of<ConsultationViewModel>(context);
    final groupedConsultations = _groupConsultationsByDate(
      consultationViewModel.consultations,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Consultations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, RouteManager.loginPage);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteManager.addConsultation);
        },
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshConsultations,
        child:
            consultationViewModel.isLoading &&
                    consultationViewModel.consultations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Welcome back, ${widget.email.split('@')[0]}!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Consultation List Section
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month, color: Color(0xFF6A1B9A)),
                          SizedBox(width: 8),
                          Text(
                            'Upcoming Consultations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          consultationViewModel.consultations.isEmpty
                              ? const Center(
                                child: Text(
                                  'No consultations booked yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                itemCount: groupedConsultations.length,
                                itemBuilder: (context, index) {
                                  final dateKey = groupedConsultations.keys
                                      .elementAt(index);
                                  final consultationsForDate =
                                      groupedConsultations[dateKey]!;
                                  final formattedDate = DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(DateTime.parse(dateKey));

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF6A1B9A),
                                          ),
                                        ),
                                      ),
                                      ...consultationsForDate.map((
                                        consultation,
                                      ) {
                                        final dateTime =
                                            consultation['dateTime']
                                                as DateTime;
                                        final status =
                                            consultation['status'] ??
                                            'pending'; 

                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 16,
                                                ),
                                            leading: const Icon(
                                              Icons.event,
                                              color: Color(0xFF6A1B9A),
                                            ),
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    consultation['title'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                _buildStatusIndicator(status),
                                              ],
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormat(
                                                    'hh:mm a',
                                                  ).format(dateTime),
                                                ),
                                                if (consultation['location'] !=
                                                        null &&
                                                    consultation['location']
                                                        .isNotEmpty)
                                                  Text(
                                                    consultation['location'],
                                                  ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () {
                                                consultationViewModel
                                                    .removeConsultation(
                                                      consultation['id'],
                                                    );
                                           
                                              },
                                            ),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                RouteManager
                                                    .consultationDetails,
                                                arguments: consultation,
                                              );
                                            },
                                          ),
                                        );
                                      }).toList(),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6A1B9A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'
          ),
        ],
      ),
    );
  }
}
