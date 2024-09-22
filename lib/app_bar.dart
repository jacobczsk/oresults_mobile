import 'package:flutter/material.dart';

class ORMBar extends AppBar {
  ORMBar(BuildContext context, {String title = "OResults Mobile", super.key})
      : super(
          title: Text(title),
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        );
}
