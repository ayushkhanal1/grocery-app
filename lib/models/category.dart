import 'package:flutter/material.dart';

enum Categories{vegetables,fruit,meat,dairy,carbs,other,convenience,hygiene,sweets,spices}
class Category{
  const Category(this.title,this.color);
  final String title;
  final Color color;
}