import 'package:flutter/material.dart';

class ContentForm extends StatefulWidget {
  const ContentForm({super.key});

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('하루 한 평')),
        body: FractionallySizedBox(
          heightFactor: 0.8,
          widthFactor: 1,
          alignment: const Alignment(0, -1),
          child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: '책 제목을 입력하세요', label: Text('제목')),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: '저자를 입력해주세요', label: Text('저자')),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        hintText: '감상평을 입력해주세요', label: Text('감상평')),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    maxLines: null,
                    minLines: null,
                    expands: true,
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 40))),
                  onPressed: () {},
                  child: const Text('제출'),
                ),
              ])),
        ));
  }
}
