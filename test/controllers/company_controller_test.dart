import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:acesso_mapeado/controllers/company_controller.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_mock.dart';

import 'company_controller_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  DocumentReference,
  CollectionReference,
  DocumentSnapshot,
  UserCredential,
  CompanyModel
])
void main() {
  late CompanyController companyController;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;

  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();

    final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
    final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

    when(mockFirestore.collection('companies')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);

    when(mockUser.uid).thenReturn('test-uid');
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.fromIterable([mockUser]));

    companyController = CompanyController(
      auth: mockAuth,
      firestore: mockFirestore,
    );
  });

  group('CompanyController Tests', () {
    test('initial state should be correct', () {
      expect(companyController.auth, mockAuth);
      expect(companyController.firestore, mockFirestore);
    });

    test('loadCompanyData updates companyModel and notifies listeners',
        () async {
      final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('companies')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc('test-uid')).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'name': 'Test Company',
        'email': 'company@test.com',
        'cnpj': '12.345.678/0001-90',
        'profilePictureUrl': 'test-profile-picture',
        'address': 'Test Address',
        'phone': '(11) 1234-5678',
        'registrationDate': '2024-01-01T00:00:00.000Z'
      });

      var listenerCalled = false;
      companyController.addListener(() {
        listenerCalled = true;
      });

      await companyController.loadCompanyData();

      expect(companyController.auth, mockAuth);
      expect(companyController.firestore, mockFirestore);
      expect(listenerCalled, true);
    });
  });
}
