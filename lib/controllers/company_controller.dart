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

  // Função que cria a empresa
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

  // Função para editar a empresa atualizando o rating baseado na média dos ratings
  Future<bool> updateCompanyRating(String companyUUID) async {
    try {
      QuerySnapshot querySnapshot = await _companiesCollection
          .where('uuid', isEqualTo: companyUUID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Logger.logInfo('Empresa com UUID não encontrada.');
        return false;
      }

      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      CompanyModel company = CompanyModel.fromJson(
        docSnapshot.data() as Map<String, dynamic>,
      );

      if (company.ratings!.isEmpty) {
        Logger.logInfo('Empresa não possui ratings.');
        return false;
      }
      double averageRating =
          company.ratings!.reduce((a, b) => a + b) / company.ratings!.length;

      await docSnapshot.reference.update({
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
  Future<bool> addCompanyUserRating(
      String companyUUID, double userRating) async {
    try {
      QuerySnapshot querySnapshot = await _companiesCollection
          .where('uuid', isEqualTo: companyUUID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Logger.logInfo('Empresa com UUID não encontrada.');
        return false;
      }

      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      List<double> ratings = List<double>.from(data['ratings'] ?? []);

      ratings.add(userRating);

      await docSnapshot.reference.update({
        'ratings': ratings,
      });

      await updateCompanyRating(companyUUID);

      Logger.logInfo('Rating do usuário adicionado com sucesso.');
      return true;
    } catch (e) {
      Logger.logInfo('Erro ao adicionar rating do usuário: $e');
      return false;
    }
  }

  // Função para adição de um rating
  Future<void> addUserRating(String companyUUID, double userRating) async {
    bool result = await addCompanyUserRating(companyUUID, userRating);

    if (result) {
      Logger.logInfo('Rating adicionado com sucesso.');
    } else {
      Logger.logInfo('Falha ao adicionar o rating.');
    }

    final docSnapshot = await _companiesCollection.doc(companyUUID).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      Logger.logInfo('Ratings atuais: ${data['ratings']}');
    }
  }

  // Função que adiciona o comentário do usuario à empresa
  Future<bool> addUserComment(String companyUUID, String comment) async {
    try {
      QuerySnapshot querySnapshot = await _companiesCollection
          .where('uuid', isEqualTo: companyUUID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Logger.logInfo('Empresa com UUID não encontrada.');
        return false;
      }

      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> commentsData =
          List<Map<String, dynamic>>.from(data['commentsData'] ?? []);

      var commentData = {
        'userName': 'João Silva',
        'userImage': 'https://via.placeholder.com/50.png?text=João',
        'text': comment,
        'date': DateTime.now().toString(),
      };

      commentsData.add(commentData);

      await docSnapshot.reference.update({
        'commentsData': commentsData,
      });

      Logger.logInfo('Comentário do usuário adicionado com sucesso.');
      return true;
    } catch (e) {
      Logger.logInfo('Erro ao adicionar comentário do usuário: $e');
      return false;
    }
  }
}
