import 'package:flutter/cupertino.dart';

class LoginTopCustomClipper extends CustomClipper<Path> {
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(size.width * 0.0025000, size.height * 0.9942857);
    path0.quadraticBezierTo(size.width * 0.1265500, size.height * 0.6838571,
        size.width * 0.5000000, size.height * 0.5685714);
    path0.quadraticBezierTo(size.width * 0.8757500, size.height * 0.4634286,
        size.width, size.height * 0.1596000);
    path0.lineTo(size.width, 0);
    path0.lineTo(0, 0);
    path0.lineTo(size.width * -0.0025000, size.height * 0.9942857);
    path0.close();

    return path0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
