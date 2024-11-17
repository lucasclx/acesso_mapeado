import 'dart:convert';

import 'package:acesso_mapeado/controllers/user_controller.dart';
import 'package:acesso_mapeado/controllers/company_controller.dart';
import 'package:acesso_mapeado/models/accessibility_model.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acesso_mapeado/pages/edit_company_profile_page.dart';

class CompanyHomePage extends StatefulWidget {
  const CompanyHomePage({super.key});

  @override
  State<CompanyHomePage> createState() => _CompanyHomePageState();
}

class _CompanyHomePageState extends State<CompanyHomePage> {
  CompanyModel? companyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('companies')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            companyData = CompanyModel.fromJson(doc.data()!);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar dados da empresa')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityData = companyData?.accessibilityData?.accessibilityData;
    print(accessibilityData);
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (companyData == null) {
      return const Scaffold(
        body: Center(
          child: Text('Erro ao carregar dados da empresa'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel da Empresa'),
        backgroundColor: AppColors.lightPurple,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<UserController>(context, listen: false)
                  .signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('onboarding');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadCompanyData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com informações principais
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.veryLightPurple,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: companyData!.imageUrl != null
                          ? MemoryImage(base64Decode(companyData!.imageUrl!
                              .substring(
                                  companyData!.imageUrl!.indexOf(',') + 1)))
                          : const AssetImage(
                              'assets/images/img-company.png',
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      companyData!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(
                          ' ${companyData!.rating?.toStringAsFixed(1) ?? '0.0'}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          ' (${companyData!.ratings?.length ?? 0} avaliações)',
                          style: const TextStyle(color: AppColors.darkGray),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Informações de Contato
              _buildSection(
                'Informações de Contato',
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.location_on, 'Endereço',
                            companyData!.address),
                        const Divider(),
                        _buildInfoRow(Icons.phone, 'Telefone',
                            companyData!.phoneNumber ?? 'Não informado'),
                        const Divider(),
                        _buildWorkingHoursRow(companyData!.workingHours ?? []),
                      ],
                    ),
                  ),
                ),
              ),

              // Dashboard de Acessibilidade
              accessibilityData?.isNotEmpty ?? false
                  ? _buildSection(
                      'Dashboard de Acessibilidade',
                      _buildAccessibilityDashboard(),
                    )
                  : const SizedBox.shrink(),

              // Estatísticas expandidas
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Comentários',
                      '${companyData!.commentsData?.length ?? 0}',
                      Icons.comment,
                    ),
                    _buildStatCard(
                      'Acessibilidade',
                      '${_calculateAccessibilityScore()}%',
                      Icons.accessibility_new,
                    ),
                  ],
                ),
              ),

              // Seção de Comentários Recentes
              _buildSection(
                'Comentários Recentes',
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: companyData!.commentsData?.take(3).length ?? 0,
                  itemBuilder: (context, index) {
                    final comment = companyData!.commentsData![index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: comment.userImage != null
                              ? MemoryImage(base64Decode(comment.userImage!
                                  .substring(
                                      comment.userImage!.indexOf(',') + 1)))
                              : const AssetImage(
                                  'assets/images/placeholder-user.png',
                                ),
                        ),
                        title: Text(comment.userName),
                        subtitle: Text(comment.text),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text(comment.rate.toString()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Botões de Ação
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      'Editar Perfil',
                      Icons.edit,
                      () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCompanyProfilePage(
                              company: companyData!,
                            ),
                          ),
                        );

                        if (result == true) {
                          // Reload company data after successful edit
                          loadCompanyData();
                        }
                      },
                    ),
                    _buildActionButton(
                      'Acessibilidade',
                      Icons.accessibility_new,
                      () {
                        // TODO: Implementar gestão de acessibilidade
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.lightPurple),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: AppColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPurple,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }

  int _calculateAccessibilityScore() {
    if (companyData?.accessibilityData?.accessibilityData == null) {
      return 0;
    }

    int totalItems = 14;
    int selectedItems = 0;

    companyData!.accessibilityData!.accessibilityData.forEach((_, items) {
      selectedItems += items.where((item) => item.status).length;
    });

    return ((selectedItems / totalItems) * 100).round();
  }

  Widget _buildWorkingHoursRow(List<WorkingHours> workingHours) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workingHours.length,
      itemBuilder: (context, index) {
        final workingText =
            '${workingHours[index].open} - ${workingHours[index].close}';
        final workingTextColor =
            workingHours[index].open != workingHours[index].close
                ? AppColors.green
                : AppColors.darkGray;
        final weekDay = workingHours[index];
        return ListTile(
          leading: Text(weekDay.day, style: const TextStyle(fontSize: 16)),
          trailing: Text(
            workingText,
            style: TextStyle(fontSize: 14, color: workingTextColor),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightPurple),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityDashboard() {
    final accessibilityData = companyData?.accessibilityData?.accessibilityData;
    if (accessibilityData == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: accessibilityData.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            final completedItems = items.where((item) => item.status).length;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category),
                    Text('$completedItems/${items.length}'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: items.isEmpty ? 0 : completedItems / items.length,
                  backgroundColor: AppColors.veryLightPurple,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.lightPurple),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
