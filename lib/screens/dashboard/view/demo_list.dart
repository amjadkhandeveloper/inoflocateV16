// import 'package:flutter/material.dart';

// class NumberListScreen extends StatefulWidget {
//   const NumberListScreen({super.key});

//   @override
//   _NumberListScreenState createState() => _NumberListScreenState();
// }

// class _NumberListScreenState extends State<NumberListScreen> {
//   final PageController _pageController = PageController(initialPage: 0);
//   int _currentPage = 0;

//   @override
//   Widget build(BuildContext context) {
//     List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Number List'),
//       ),
//       body: Column(
//         children: [
//           SizedBox(
//             height: 200,
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: numbers.length,
//               itemBuilder: (context, index) {
//                 bool isActive = index == _currentPage;

//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: EdgeInsets.symmetric(
//                     horizontal: isActive ? 0 : 16,
//                   ),
//                   height: 200,
//                   width: MediaQuery.of(context).size.width - 32,
//                   decoration: BoxDecoration(
//                     color: isActive ? Colors.blue : Colors.grey,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       numbers[index].toString(),
//                       style: const TextStyle(
//                         fontSize: 24,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentPage = index;
//                 });
//               },
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(numbers.length, (index) {
//               return Padding(
//                 padding: const EdgeInsets.all(4),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   height: 10,
//                   width: 10,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: index == _currentPage ? Colors.blue : Colors.grey,
//                   ),
//                 ),
//               );
//             }),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   if (_currentPage > 0) {
//                     _pageController.animateToPage(
//                       _currentPage - 1,
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//               ),
//               const SizedBox(width: 16),
//               IconButton(
//                 icon: const Icon(Icons.arrow_forward),
//                 onPressed: () {
//                   if (_currentPage < numbers.length - 1) {
//                     _pageController.animateToPage(
//                       _currentPage + 1,
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
// // import 'package:flutter/material.dart';

// // class YourWidget extends StatefulWidget {
// //   @override
// //   _YourWidgetState createState() => _YourWidgetState();
// // }

// // class _YourWidgetState extends State<YourWidget> {
// //   int _currentItem = 0;
// //   ScrollController alertController = ScrollController();
// //   List<AlertStatus>? alertStatusList; // Replace AlertStatus with your data model

// //   @override
// //   Widget build(BuildContext context) {
// //     return
 
// //   }
// // }
