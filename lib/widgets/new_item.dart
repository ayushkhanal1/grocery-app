import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/category.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var enteredname = '';
  var enteredquantity = 1;
  var selectedcategory = categories[Categories.vegetables]!;
  var issaving=false;
  void _additem() async{
    if (_formkey.currentState!.validate()) {
      setState(() {
        issaving=true;
      });
      _formkey.currentState!.save();
      final url = Uri.https(
          'flutter-91bc5-default-rtdb.firebaseio.com', 'list_grocery.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': enteredname,
            'quantity': enteredquantity,
            'category': selectedcategory.title,
          },
        ),
      );
      if(!context.mounted)
      {
        return;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 2 ||
                      value.trim().length > 50) {
                    return 'INVALID CHARACTER LENGTH';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  enteredname = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: enteredquantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'INVALID CHARACTER LENGTH';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        enteredquantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: selectedcategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(6),
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedcategory = value!;
                          });
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:issaving?null: () {
                      _formkey.currentState!.reset();
                    },
                    child: const Text("RESET"),
                  ),
                  ElevatedButton(
                    onPressed:issaving?null: _additem,
                    child: issaving?const SizedBox(height: 16,width: 16,child:CircularProgressIndicator() ,):const Text("ADD ITEM"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
