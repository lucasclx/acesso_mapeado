import 'package:acesso_mapeado/models/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyController {
  Future<List<CompanyModel>> getAllCompanies() async {
    try {
      final companiesSnapshot =
          await FirebaseFirestore.instance.collection('companies').get();

      // Verificação de se a lista de docs não está vazia
      if (companiesSnapshot.docs.isEmpty) {
        print('Nenhuma empresa encontrada');
        return [];
      }

      print(
          'Empresas: ${companiesSnapshot.docs.length}'); // Imprime o número de documentos

      // Mapeando os dados para CompanyModel
      return companiesSnapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data != null && data is Map<String, dynamic>) {
              return CompanyModel.fromJson(data);
            } else {
              print('Documento com formato inválido: ${doc.id}');
              return null; // Pular documentos inválidos
            }
          })
          .whereType<CompanyModel>() // Filtrar os nulos
          .toList();
    } catch (error) {
      print('Error getting documents: $error');
      return [];
    }
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
