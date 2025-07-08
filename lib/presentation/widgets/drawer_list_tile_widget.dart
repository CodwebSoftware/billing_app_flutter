import 'package:flutter/material.dart';

class DrawerListTileWidget extends StatelessWidget {
  const DrawerListTileWidget({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.tap,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback tap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: tap,
      horizontalTitleGap: 10.0,
      // leading: SizedBox(height: 30, width: 30, child: Image.asset(svgSrc)),
      title: Text(
        title,
        style: TextStyle(color: Color(0xFF3B982C), fontSize: 14),
      ),
    );
  }
}
