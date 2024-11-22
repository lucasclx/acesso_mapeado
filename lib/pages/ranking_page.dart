import 'dart:convert';
import 'package:acesso_mapeado/controllers/user_controller.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:flutter/material.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/controllers/company_controller.dart';
import 'package:acesso_mapeado/widgets/accessibility_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final CompanyController _companyController = CompanyController();
  List<CompanyModel> rankedCompanies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRankedCompanies();
  }

  String calculateDistance(double? companyLatitude, double? companyLongitude) {
    final userPosition =
        Provider.of<UserController>(context, listen: false).userPosition;
    if (userPosition == null ||
        companyLatitude == null ||
        companyLongitude == null) return "";
    final distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      companyLatitude,
      companyLongitude,
    );

    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    } else {
      final distanceInKm = distance / 1000;
      return "${distanceInKm.toStringAsFixed(0)} km";
    }
  }

  Future<void> _fetchRankedCompanies() async {
    try {
      rankedCompanies = await _companyController.getAllCompaniesOrderByRating();
    } catch (e) {
      Logger.logInfo('Error fetching ranked companies: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAccessibilitySheet(CompanyModel companyModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AccessibilitySheet(companyModel: companyModel);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyMessage() {
    return const Center(
      child: Text(
        'Nenhuma empresa encontrada.',
        style: TextStyle(fontSize: 18, color: AppColors.darkGray),
      ),
    );
  }

  Widget _buildCompanyCard(CompanyModel company, int index) {
    final distance = calculateDistance(company.latitude, company.longitude);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: company.imageUrl != null
              ? MemoryImage(base64Decode(company.imageUrl!.split(',')[1]))
              : const AssetImage('assets/images/img-company.png')
                  as ImageProvider,
          radius: 25,
        ),
        title: Text(
          '${index + 1}. ${company.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: List.generate(5, (starIndex) {
            return Icon(
              Icons.star,
              color: starIndex < (company.rating ?? 0)
                  ? AppColors.yellow
                  : Colors.grey[300],
              size: 18,
            );
          }),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              distance,
              style: const TextStyle(
                color: Color.fromARGB(255, 203, 5, 128),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        onTap: () {
          _showAccessibilitySheet(company);
        },
      ),
    );
  }

  // Widget _buildInfoButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: AppColors.lightPurple),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: const Padding(
  //       padding: EdgeInsets.all(8.0),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             Icons.info,
  //             color: AppColors.lightPurple,
  //           ),
  //           SizedBox(width: 5),
  //           Text(
  //             'Saiba mais',
  //             style: TextStyle(color: AppColors.lightPurple),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _isLoading
          ? _buildLoadingIndicator()
          : rankedCompanies.isEmpty
              ? _buildEmptyMessage()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 14),
                  itemCount: rankedCompanies.length,
                  itemBuilder: (context, index) {
                    final company = rankedCompanies[index];
                    return _buildCompanyCard(company, index);
                  },
                ),
    );
  }
}
