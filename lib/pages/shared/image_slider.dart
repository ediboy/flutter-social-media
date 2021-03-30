import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final List images;
  final int selectedIndex;

  ImageSlider({this.images, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0),
      insetPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        child: CarouselSlider.builder(
          options: CarouselOptions(
            initialPage: selectedIndex,
            viewportFraction: 1,
            aspectRatio: 600 / 650,
          ),
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) => Image.network(
            images[index],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
