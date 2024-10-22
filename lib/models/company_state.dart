import 'package:acesso_mapeado/models/company_model.dart';
import 'package:flutter/material.dart';

class CompanyState extends ChangeNotifier {
  List<CompanyModel> _companies = [];

  List<CompanyModel> get companies => _companies;

  void updateCompanies(List<CompanyModel> newCompanies) {
    _companies = newCompanies;
    notifyListeners(); // Notifica as mudanças para os widgets
  }
}
