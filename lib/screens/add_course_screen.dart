import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});
  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', description = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (v) => title = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => loading = true);
                        await FirebaseFirestore.instance
                            .collection('courses')
                            .add({
                              'title': title,
                              'description': description,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                        setState(() => loading = false);
                        Navigator.of(context).pop();
                      },
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
