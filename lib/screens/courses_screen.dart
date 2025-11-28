import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'add_course_screen.dart';
import 'enrolled_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EnrolledScreen()));
            },
            icon: const Icon(Icons.school),
          ),
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddCourseScreen())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('No courses yet. Add one.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final title = doc['title'] ?? '';
              final desc = doc['description'] ?? '';
              return ListTile(
                title: Text(title),
                subtitle: Text(desc),
                trailing: ElevatedButton(
                  child: const Text('Enroll'),
                  onPressed: () async {
                    if (uid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not logged in')),
                      );
                      return;
                    }
                    // store enrollment under 'enrollments' collection
                    await FirebaseFirestore.instance
                        .collection('enrollments')
                        .add({
                          'userId': uid,
                          'courseId': doc.id,
                          'enrolledAt': FieldValue.serverTimestamp(),
                        });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Enrolled')));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
