import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewer extends StatelessWidget {
  final String url;
  const PDFViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [SfPdfViewer.network(url)],
      ),
    );
  }
}
