import 'package:flutter/cupertino.dart';

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Image.asset("assets/icon.png", height: 300)),
    );
  }
}
