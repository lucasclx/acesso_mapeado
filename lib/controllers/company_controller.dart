import 'package:acesso_mapeado/models/company_model.dart';

class CompanyController {
//getAllCompanies

  Future<List<CompanyModel>> getAllCompanies() async {
    try {
      final companies =
          await FirebaseFirestore.instance.collection('companies').get();
      return companies.docs.map((doc) => CompanyModel.fromJson(doc)).toList();
    } catch (error) {
      print('Error getting documents: $error');
      return [];
    } finally // finally is called every time after try or catch
    {}
  }

  Future<bool> createCompany(CompanyModel company) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('companies')
          .add(company.toJson());
      print('Document ID: ${docRef.id}');
      return true;
    } catch (error) {
      print('Error adding document: $error');
      return false;
    }
  }
}
