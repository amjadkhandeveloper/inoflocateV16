import 'package:flutter/material.dart';

import '../widgets/dashboard_card.dart';

class TripDashBoard extends StatelessWidget {
   static String routeName = '/tripDashboard';
  const TripDashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last 10 Trips'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [for (int i = 0; i < 10; i++) const TripDashBoardCard()],
          ),
        ),
      ),
    );
  }
}
