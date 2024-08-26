import 'package:acesso_mapeado/shared/app_colors.dart';
import 'package:acesso_mapeado/shared/app_text_styles.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.lightPurple, AppColors.darkPurple])),
            child: Text(
              'Acesso Mapeado',
              style: AppTextStyles.splashTitleStyle
                  .copyWith(color: AppColors.white),
            )));
  }
}
