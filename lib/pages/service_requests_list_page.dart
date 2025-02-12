import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/service_request.dart';
import 'request_matching_page.dart';

class ServiceRequestsListPage extends StatelessWidget {
  const ServiceRequestsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Talepleri'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text('Henüz servis talebi yok'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = ServiceRequest.fromFirestore(requests[index]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(request.description),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Konum: ${request.location}'),
                      Text('Durum: ${request.status}'),
                      Text('Hizmetler: ${request.serviceTypes.join(", ")}'),
                    ],
                  ),
                  trailing: request.status == 'pending'
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RequestMatchingPage(request: request),
                              ),
                            );
                          },
                          child: const Text('Eşleştir'),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
