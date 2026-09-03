import 'package:flutter/cupertino.dart';

class LoginBottomCustomClipper extends CustomClipper<Path> {
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(size.width*0.6668000,size.height*0.9968000);
    path0.quadraticBezierTo(size.width*0.6931250,size.height*0.1895333,size.width,size.height*0.2605333);
    path0.lineTo(size.width*1.0066750,size.height*1.0002000);
    path0.quadraticBezierTo(size.width*0.9476000,size.height*1.0683333,size.width*0.6668000,size.height*0.9968000);

    path0.close();
 
    return path0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}



