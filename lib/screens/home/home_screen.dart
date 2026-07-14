import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/garden_card.dart';
import '../shop/shop_section.dart';

/// Ana sayfa: bahçe (üst) + mağaza (alt). Widget sadece alt bileşenleri
/// yerleştirir, veri okuma/işlem alt widget'lardaki provider'lardan gelir.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GardenCard(),
          SizedBox(height: 24),
          ShopSection(),
        ],
      ),
    );
  }
}
