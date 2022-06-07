import 'package:expandable_overlay/expandable_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.blue.shade50,
                height: 200,
                child: const Center(child: Text("empty space")),
              ),
              ExpandableOverlayLauncher(
                overlayParams: ExpandableOverlayParams(
                  contentBuilder: (context, dismissOverlay) =>
                      buildModalContents('Modal 1'),
                ),
                child: buildButton('Modal 1'),
              ),
              ExpandableOverlayLauncher(
                overlayParams: ExpandableOverlayParams(
                  contentBuilder: (context, dismissOverlay) =>
                      buildModalContents('Modal 2'),
                ),
                child: buildButton('Modal 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildModalContents(String title) {
    return Column(
      children: [
        Text('$title - Content 1'),
        Text('$title - Content 2'),
        Text('$title - Content 3'),
      ]
          .map((e) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: e,
              ))
          .toList(),
    );
  }

  Widget buildButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
