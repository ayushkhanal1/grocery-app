import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/category.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> newlist = [];
  var isloading = true;
  @override
  void initState() {
    super.initState();
    _loaditem();
  }

  void _loaditem() async {
    final url = Uri.https(
        'flutter-91bc5-default-rtdb.firebaseio.com', 'list_grocery.json');
    final response = await http.get(url);
    if(response.body=='null')
    { 
      setState(() {
      isloading=false;
       });
       return;   
    }
    final Map<String, dynamic> listdata = jsonDecode(response.body);
    final List<GroceryItem> addedlist = [];
    for (final item in listdata.entries) {
      final category = categories.entries
          .firstWhere(
              (catitem) => catitem.value.title == item.value['category'])
          .value;
      addedlist.add(
        GroceryItem(
          category: category,
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
        ),
      );
      setState(() {
        newlist = addedlist;
        isloading = false;
      });
    }
  }

  void _additem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    _loaditem();
  }

  void removeitem(GroceryItem item) {
    final url = Uri.https(
        'flutter-91bc5-default-rtdb.firebaseio.com', 'list_grocery/${item.id}.json');
        http.delete(url);
    setState(() {
      newlist.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("NO ITEMS ADDED CURRENTLY"),
    );
    if (isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (newlist.isNotEmpty) {
      content = ListView.builder(
        itemCount: newlist.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            removeitem(newlist[index]);
          },
          key: ValueKey(newlist[index].id),
          child: ListTile(
            title: Text(newlist[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: newlist[index].category.color,
            ),
            trailing: Text(
              newlist[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: _additem,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: content);
  }
}
