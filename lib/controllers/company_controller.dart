import 'package:acesso_mapeado/shared/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/shared/mock_companies.dart';

class CompanyController {
  final CollectionReference _companiesCollection =
      FirebaseFirestore.instance.collection('companies');

  // Função para obter todas as empresas
  Future<List<CompanyModel>> getAllCompanies() async {
    try {
      final response =
          await FirebaseFirestore.instance.collection('companies').get();

      List<CompanyModel> companies = response.docs
          .map((doc) => CompanyModel.fromJson(doc.data()))
          .toList();
      return companies;
    } catch (e) {
      Logger.logInfo('Erro ao obter empresas: $e');
      return [];
    }
  }

  // Função para buscar empresas pelo nome
  Future<List<CompanyModel>> searchCompaniesByName(String searchTerm) async {
    try {
      final querySnapshot = await _companiesCollection
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThan: '$searchTerm\uf8ff')
          .get();

      List<CompanyModel> companies = querySnapshot.docs
          .map((doc) =>
              CompanyModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return companies;
    } catch (e) {
      Logger.logInfo('Erro ao buscar empresas: $e');
      return [];
    }
  }

  // Função para inserir dados de mock no Firestore
  Future<void> insertMockCompanies() async {
    try {
      for (var company in mockCompanies) {
        await _companiesCollection.add(company.toJson());
      }
      Logger.logInfo('Dados de mock inseridos com sucesso!');
    } catch (e) {
      Logger.logInfo('Erro ao inserir dados de mock: $e');
    }
  }

  // Função para obter todas as empresas ordenadas por rating decrescente
  Future<List<CompanyModel>> getAllCompaniesOrderByRating() async {
    try {
      final response =
          await _companiesCollection.orderBy('rating', descending: true).get();

      List<CompanyModel> companies = response.docs
          .map((doc) =>
              CompanyModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return companies;
    } catch (e) {
      Logger.logInfo('Erro ao obter empresas ordenadas por rating: $e');
      return [];
    }
  }

  Future<bool> createCompany(CompanyModel company) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('companies')
          .add(company.toJson());
      Logger.logInfo('Document ID: ${docRef.id}');
      return true;
    } catch (error) {
      Logger.logInfo('Error adding document: $error');
      return false;
    }
  }

  // Função para editar a empresa e atualizar o rating baseado na média dos ratings
  Future<bool> updateCompanyRating(String companyId) async {
    try {
      // Obter o documento da empresa
      final docSnapshot = await _companiesCollection.doc(companyId).get();

      if (!docSnapshot.exists) {
        Logger.logInfo('Empresa não encontrada.');
        return false;
      }

      CompanyModel company = CompanyModel.fromJson(
        docSnapshot.data() as Map<String, dynamic>,
      );

      if (company.ratings!.isEmpty) {
        Logger.logInfo('Empresa não possui ratings.');
        return false;
      }
      double averageRating =
          company.ratings!.reduce((a, b) => a + b) / company.ratings!.length;

      await _companiesCollection.doc(companyId).update({
        'rating': averageRating,
      });

      Logger.logInfo('Rating atualizado com sucesso para $averageRating.');
      return true;
    } catch (e) {
      Logger.logInfo('Erro ao atualizar o rating da empresa: $e');
      return false;
    }
  }

  // Função para adicionar o rating de um usuário à empresa
  Future<bool> addCompanyUserRating(String companyId, double userRating) async {
    try {
      final docSnapshot = await _companiesCollection.doc(companyId).get();

      if (!docSnapshot.exists) {
        Logger.logInfo('Empresa não encontrada.');
        return false;
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      List<double> ratings = List<double>.from(data['ratings'] ?? []);

      ratings.add(userRating);

      await _companiesCollection.doc(companyId).update({
        'ratings': ratings,
      });

      await updateCompanyRating(companyId);

      Logger.logInfo('Rating do usuário adicionado com sucesso.');
      return true;
    } catch (e) {
      Logger.logInfo('Erro ao adicionar rating do usuário: $e');
      return false;
    }
  }

  // Função para adição de um rating
  Future<void> addUserRating() async {
    String companyId = '2mzbcytEWZyhpFihwKTk';
    double userRating = 0;

    bool result = await addCompanyUserRating(companyId, userRating);

    if (result) {
      Logger.logInfo('Rating adicionado com sucesso.');
    } else {
      Logger.logInfo('Falha ao adicionar o rating.');
    }

    final docSnapshot = await _companiesCollection.doc(companyId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      Logger.logInfo('Ratings atuais: ${data['ratings']}');
    }
  }
}
