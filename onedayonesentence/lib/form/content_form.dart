import 'package:flutter/material.dart';

class ContentForm extends StatefulWidget {
  const ContentForm({super.key});

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateTime _now = DateTime.now();
  String _title = "";
  String _author = "";
  DateTime _selectedDate = DateTime.now();
  String _impresstion = "";
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _dateController.text = getDateFromDateTime(_selectedDate);
  }

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
                  onChanged: (newValue) => {
                    setState(() {
                      _title = newValue;
                    })
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  onChanged: (newValue) => {
                    setState(() {
                      _author = newValue;
                    })
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: '날짜를 선택해주세요',
                          labelText: '날짜',
                        ),
                        readOnly: true,
                        controller: _dateController,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate:
                                  _now.subtract(const Duration(days: 50)),
                              lastDate: _now);

                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _dateController.text =
                                  getDateFromDateTime(_selectedDate);
                            });
                          }
                        },
                        child: const Text('날짜 선택'),
                      ),
                    )
                  ],
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
                    onChanged: (newValue) => {
                      setState(() {
                        _impresstion = newValue;
                      })
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 40))),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                    }
                  },
                  child: const Text('제출'),
                ),
              ])),
        ));
  }
}

String getDateFromDateTime(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
