import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class EnrolledScreen extends StatelessWidget {
  const EnrolledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Enrolled')),
        body: const Center(child: Text('Not logged in')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Enrollments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('enrollments')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final enrollDocs = snap.data!.docs;
          if (enrollDocs.isEmpty)
            return const Center(child: Text('No enrollments yet.'));
          return ListView.builder(
            itemCount: enrollDocs.length,
            itemBuilder: (context, i) {
              final enroll = enrollDocs[i];
              final courseId = enroll['courseId'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .get(),
                builder: (context, cSnap) {
                  if (!cSnap.hasData)
                    return const ListTile(title: Text('Loading...'));
                  final course = cSnap.data!;
                  return ListTile(
                    title: Text(course['title'] ?? 'No title'),
                    subtitle: Text(course['description'] ?? ''),
                    trailing: Text('Enrolled'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
