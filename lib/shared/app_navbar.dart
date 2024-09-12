import 'package:acesso_mapeado/shared/app_colors.dart';
import 'package:flutter/material.dart';

class AppNavbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: AppColors.lightPurple,
        unselectedItemColor: AppColors.lightGray,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: AppColors.white,
            icon: Icon(Icons.map_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.white,
            icon: Icon(Icons.chat_outlined),
            label: 'Bate-Papo',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.white,
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.white,
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: widget.selectedIndex,
        onTap: widget.onItemTapped,
      ),
    );
  }
}
