import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:heroicons/heroicons.dart';
import '../theme.dart';
import 'home_explore_screen.dart';
import 'categories_screen.dart';
import 'collections_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeExploreScreen(),
    CategoriesScreen(),
    CollectionsScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black45;
    final navTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: FlashyTabBar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) => setState(() => _selectedIndex = index),
          height: 62,
          iconSize: 24,
          showElevation: false,
          backgroundColor: isDark
              ? AppColors.secondary.withValues(alpha: 0.95)
              : Colors.white,
          items: [
            FlashyTabBarItem(
              icon: HeroIcon(
                HeroIcons.home,
                style: _selectedIndex == 0
                    ? HeroIconStyle.solid
                    : HeroIconStyle.outline,
              ),
              title: Text(
                'Home',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: navTextStyle,
              ),
              activeColor: primary,
              inactiveColor: inactiveColor,
            ),
            FlashyTabBarItem(
              icon: HeroIcon(
                HeroIcons.squares2x2,
                style: _selectedIndex == 1
                    ? HeroIconStyle.solid
                    : HeroIconStyle.outline,
              ),
              title: Text(
                'Categories',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: navTextStyle,
              ),
              activeColor: primary,
              inactiveColor: inactiveColor,
            ),
            FlashyTabBarItem(
              icon: HeroIcon(
                HeroIcons.folderOpen,
                style: _selectedIndex == 2
                    ? HeroIconStyle.solid
                    : HeroIconStyle.outline,
              ),
              title: Text(
                'Collections',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: navTextStyle,
              ),
              activeColor: primary,
              inactiveColor: inactiveColor,
            ),
            FlashyTabBarItem(
              icon: HeroIcon(
                HeroIcons.heart,
                style: _selectedIndex == 3
                    ? HeroIconStyle.solid
                    : HeroIconStyle.outline,
              ),
              title: Text(
                'Favorites',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: navTextStyle,
              ),
              activeColor: primary,
              inactiveColor: inactiveColor,
            ),
            FlashyTabBarItem(
              icon: HeroIcon(
                HeroIcons.cog6Tooth,
                style: _selectedIndex == 4
                    ? HeroIconStyle.solid
                    : HeroIconStyle.outline,
              ),
              title: Text(
                'Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: navTextStyle,
              ),
              activeColor: primary,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}
