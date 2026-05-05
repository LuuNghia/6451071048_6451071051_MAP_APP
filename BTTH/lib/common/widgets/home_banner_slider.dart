import 'dart:async'; 
import 'package:flutter/material.dart'; 
 
class HomeBannerSlider extends StatefulWidget {
   const HomeBannerSlider({super.key}); 
 
  @override 
  State<HomeBannerSlider> createState() => _HomeBannerSliderState(); 
} 
 
class _HomeBannerSliderState extends State<HomeBannerSlider> { 
  late PageController pageController; 
  late Timer autoSlideTimer; 
 
  int currentIndex = 0; 
 
  final List<String> bannerImages = [ 
    'assets/images/foods/Hai_San/Sieu_Topping_Xot_Mayonnaise.jpg',
    'assets/images/foods/Hai_San/Xot_Doi_Pho_Mai_Cay.jpg',
    'assets/images/foods/Bo/Bo_My_Xot_Pho_Mai.jpg',
    'assets/images/foods/Bo/bo_tom_nuong_kieu_my.jpg',
    'assets/images/foods/Ga/Ga_Pho_Mai.png',
    'assets/images/foods/Heo/Sieu_Topping_Xuc_Xich.jpg',
    'assets/images/foods/Heo/Sieu_Topping_Dam_Bong.jpg',
    'assets/images/foods/Rau_Cu/Rau_Cu_Thap_Cam.jpg',
  ]; 
 
  @override 
  void initState() { 
    super.initState(); 
 
    pageController = PageController(initialPage: 0); 
 
    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) 
{ 
      if (currentIndex < bannerImages.length - 1) { 
        currentIndex++; 
      } else { 
        currentIndex = 0; 
      } 
 
      pageController.animateToPage( 
        currentIndex, 
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeInOut, 
      ); 
    }); 
  } 
 
  @override 
  void dispose() { 
    autoSlideTimer.cancel(); 
    pageController.dispose(); 
    super.dispose();
     } 
 
  @override 
  Widget build(BuildContext context) { 
    return Column( 
      children: [ 
        /// BANNER 
        SizedBox( 
          height: 160, 
          child: PageView.builder( 
            controller: pageController, 
            itemCount: bannerImages.length, 
            onPageChanged: (index) { 
              setState(() { 
                currentIndex = index; 
              }); 
            }, 
            itemBuilder: (context, index) { 
              return Container( 
                margin: const EdgeInsets.only(right: 12), 
                decoration: BoxDecoration( 
                  borderRadius: BorderRadius.circular(16), 
                  image: DecorationImage( 
                    image: AssetImage(bannerImages[index]), 
                    fit: BoxFit.cover, 
                  ), 
                ), 
              ); 
            }, 
          ), 
        ), 
 
        const SizedBox(height: 8), 
 
        /// INDICATOR 
        Row( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: List.generate(bannerImages.length, (index) { 
            return AnimatedContainer( 
              duration: const Duration(milliseconds: 300), 
              width: currentIndex == index ? 16 : 8, 
              height: 8, 
              margin: const EdgeInsets.symmetric(horizontal: 4), 
              decoration: BoxDecoration( 
                color: currentIndex == index ? Colors.blue : 
Colors.grey, 
                borderRadius: BorderRadius.circular(4), 
              ), 
            ); 
          }),
           ), 
      ], 
    ); 
  } 
} 