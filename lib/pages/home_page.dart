import 'dart:async';
import 'package:acesso_mapeado/controllers/user_controller.dart';
import 'package:acesso_mapeado/models/user_model.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:acesso_mapeado/shared/mock_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:acesso_mapeado/controllers/company_controller.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/pages/profile_user_page.dart';
import 'package:acesso_mapeado/pages/ranking_page.dart';
import 'package:acesso_mapeado/pages/sign_in_page.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:acesso_mapeado/shared/app_navbar.dart';
import 'package:acesso_mapeado/widgets/accessibility_sheet.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<CompanyModel> filteredCompanies = [];
  @override
  void initState() {
    getCompanies();
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getCompanies() async {
    try {
      companies = await _companyController.getAllCompanies();
      Logger.logInfo("Empresas carregadas: ${companies.length}");

      if (!mounted) return;
      Provider.of<CompanyController>(context, listen: false)
          .updateCompanies(companies);
      filteredCompanies = companies;

      setState(() {});
    } catch (e) {
      Logger.logError('Erro ao carregar empresas: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar empresas.')),
      );
    }
  }

  // Função para inserir dados de mock
  Future<void> _insertMockData() async {
    try {
      await _companyController.insertMockCompanies();

      if (!mounted) return;

      // Recarregar as empresas após a inserção
      await getCompanies();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados de mock inseridos com sucesso!')),
      );
    } catch (e) {
      Logger.logError('Erro ao inserir dados de mock: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao inserir dados de mock.')),
      );
    }
  }

  // Função para remover todas as empresas (opcional)
  Future<void> _removeAllCompanies() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('companies').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;

      setState(() {
        companies.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas as empresas foram removidas!')),
      );
    } catch (e) {
      Logger.logError('Erro ao remover empresas: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover empresas.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAccessibilitySheet(CompanyModel companyModel) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 185, 33, 33),
      builder: (BuildContext context) {
        return AccessibilitySheet(companyModel: companyModel);
      },
    );
  }

  // Função que filtra os dados na barra de pesquisa
  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredCompanies = companies.where((company) {
        return company.name.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  List<String> getSelectedAccessibilityOptions() {
    List<String> selectedOptions = [];
    accessibilityData.forEach((category, items) {
      for (var item in items) {
        if (item['status'] == true) {
          selectedOptions.add(item['tipo']);
        }
      }
    });
    return selectedOptions;
  }

  // Função para filtrar as empresas por acessibilidade
  void filterCompanies() {
    List<String> selectedOptions = getSelectedAccessibilityOptions();

    setState(() {
      filteredCompanies = companies.where((company) {
        bool hasAllSelectedOptions = true;

        if (company.accessibilityData != null) {
          var accessibilityMap = company.accessibilityData!.accessibilityData;

          for (String option in selectedOptions) {
            bool optionFound = false;

            for (var category in accessibilityMap.entries) {
              for (var item in category.value) {
                if (item.type == option && item.status == true) {
                  optionFound = true;
                  break;
                }
              }
              if (optionFound) break;
            }

            if (!optionFound) {
              hasAllSelectedOptions = false;
              break;
            }
          }
        } else {
          hasAllSelectedOptions = false;
        }

        // Retorna se a empresa atende todas as opções de acessibilidade selecionadas
        return hasAllSelectedOptions;
      }).toList();
    });
  }

  final CompanyController _companyController = CompanyController();

  int _selectedIndex = 0;

  List<CompanyModel> companies = [];

  final indexTitle = [
    'Empresas',
    'Ranking',
    'Perfil',
  ];

  // Métodos para construir cada página
  Widget _buildHomePage(CompanyController companyController) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: "Pesquisar",
              hintText: "Digite o nome da empresa",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
            ),
          ),
        ),
        Expanded(
          child: filteredCompanies.isEmpty // verificar se a lista está vazia
              ? Center(
                  child: Text(
                    'Nenhuma empresa encontrada.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredCompanies.length,
                  itemBuilder: (context, index) {
                    final company = filteredCompanies[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: company.imageUrl != null
                              ? NetworkImage(company.imageUrl!)
                              : AssetImage('assets/images/img-company.png')
                                  as ImageProvider,
                          radius: 29,
                        ),
                        title: Text(company.name),
                        subtitle: Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star,
                              color: starIndex < (company.rating ?? 0)
                                  ? Colors.yellow
                                  : Colors.grey,
                              size: 20,
                            );
                          }),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightPurple),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: AppColors.lightPurple,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Saiba mais',
                                  style:
                                      TextStyle(color: AppColors.lightPurple),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          _showAccessibilitySheet(company);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRankingPage() {
    return const RankingPage();
  }

  @override
  Widget build(BuildContext context) {
    final companyState = Provider.of<CompanyController>(context);
    final userController = Provider.of<UserController>(context);
    final user = userController.userModel;
    return Scaffold(
      appBar: homeAppBar(),
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(companyState),
          _buildRankingPage(),
          ProfileUserPage()
        ],
      ),
      drawer: homeDrawer(context),
      bottomNavigationBar: AppNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Drawer homeDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(height: 100),
          ...accessibilityData.entries.map((entry) {
            String category = entry.key;
            List<Map<String, dynamic>> items = entry.value;
            return ExpansionTile(
              title: Text(
                category,
                style: const TextStyle(
                    color: AppColors.black, fontWeight: FontWeight.bold),
              ),
              children: items.map((item) {
                return CheckboxListTile(
                  title: Text(
                    item["tipo"],
                    style: const TextStyle(color: AppColors.darkGray),
                  ),
                  value: item["status"],
                  onChanged: (bool? value) {
                    setState(() {
                      item["status"] = value ?? false;
                    });
                  },
                  activeColor: AppColors.lightPurple,
                  checkColor: AppColors.white,
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 45),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  filterCompanies();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text(
                  'Buscar',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar homeAppBar() {
    return AppBar(
      title: Text(
        indexTitle[_selectedIndex],
      ),
      backgroundColor: AppColors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ]),
      ),
    );
  }
}
