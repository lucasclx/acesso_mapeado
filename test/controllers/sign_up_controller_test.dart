import 'package:acesso_mapeado/controllers/user_controller.dart';
import 'package:acesso_mapeado/models/user_model.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:acesso_mapeado/controllers/sign_up_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';

import './sign_up_controller_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  User,
  UserCredential,
  UserModel,
  FormState,
  GlobalKey<FormState>,
  DocumentSnapshot,
  BuildContext,
  Query,
  QueryDocumentSnapshot,
  UserController,
  ScaffoldMessenger,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late SignUpController signUpController;
  late MockGlobalKey<FormState> formKey;
  late MockBuildContext mockContext;
  late MockFormState mockFormState;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();

    // Add these mock implementations
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock Firestore Platform Interface
    const channel = MethodChannel('plugins.flutter.io/firebase_firestore');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    formKey = MockGlobalKey<FormState>();
    mockContext = MockBuildContext();
    mockFormState = MockFormState();

    when(formKey.currentState).thenReturn(mockFormState);
    when(mockFormState.validate()).thenReturn(true);

    // Setup ScaffoldMessenger mock
    final mockScaffoldMessenger = MockScaffoldMessenger();

    when(mockContext.findAncestorWidgetOfExactType<ScaffoldMessenger>())
        .thenReturn(mockScaffoldMessenger);

    signUpController = SignUpController(
      formKey: formKey,
      nameController: TextEditingController(),
      emailController: TextEditingController(),
      cpfController: MaskedTextController(mask: '000.000.000-00'),
      dateOfBirthController: MaskedTextController(mask: '00/00/0000'),
      passwordController: TextEditingController(),
      confirmPasswordController: TextEditingController(),
      userController: MockUserController(),
      auth: mockAuth,
      firestore: mockFirestore,
    );
  });

  group('SignUpController Validation Tests', () {
    test('isValidCpf validates CPF correctly', () {
      expect(signUpController.isValidCpf('52736370821'), true);
      expect(signUpController.isValidCpf('52998224725'), true);
      expect(signUpController.isValidCpf('11111111111'), false);
      expect(signUpController.isValidCpf('invalid-cpf'), false);
    });

    test('isValidDateOfBirth validates date correctly', () {
      expect(signUpController.isValidDateOfBirth('01/01/2000'), true);
      expect(signUpController.isValidDateOfBirth('32/13/2000'), false);
      expect(signUpController.isValidDateOfBirth('01/01/2025'), false);
    });

    test('isValidPassword validates password correctly', () {
      expect(signUpController.isValidPassword('Ab1@defgh'), true);
      expect(signUpController.isValidPassword('weakpassword'), false);
      expect(signUpController.isValidPassword('123456'), false);
      expect(signUpController.isValidPassword('Ab1@'), false);
    });
  });

  group('SignUpController Registration Tests', () {
    testWidgets('signUp creates new user successfully',
        (WidgetTester tester) async {
      // Setup test data
      signUpController.nameController.text = 'Test User';
      signUpController.emailController.text = 'test@example.com';
      signUpController.cpfController.text = '527.363.708-21';
      signUpController.dateOfBirthController.text = '01/01/2000';
      signUpController.passwordController.text = 'Test@123!';
      signUpController.confirmPasswordController.text = 'Test@123!';

      // Mock Firestore query for CPF check
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.where('cpf', isEqualTo: '52736370821'))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Mock user creation
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);

      when(mockAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Test@123!',
      )).thenAnswer((_) async => mockUserCredential);

      // Mock Firestore document operations
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.set(any)).thenAnswer((_) async => {});

      // TODO: Implementar teste
    });

    testWidgets('signUp fails with existing CPF', (WidgetTester tester) async {
      signUpController.cpfController.text = '527.363.708-21';

      // Mock existing CPF query
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();

      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.where('cpf', isEqualTo: '52736370821'))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      //TODO: Implementar teste
    });

    testWidgets('signUp fails with invalid email', (WidgetTester tester) async {
      signUpController.emailController.text = 'invalid-email';
      signUpController.passwordController.text = 'Test@123';

      when(mockAuth.createUserWithEmailAndPassword(
        email: 'invalid-email',
        password: 'Test@123',
      )).thenThrow(FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is badly formatted.',
      ));

      //TODO: Implementar teste
    });

    testWidgets('signUp fails with existing email',
        (WidgetTester tester) async {
      signUpController.emailController.text = 'existing@example.com';
      signUpController.passwordController.text = 'Test@123';

      when(mockAuth.createUserWithEmailAndPassword(
        email: 'existing@example.com',
        password: 'Test@123',
      )).thenThrow(FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      ));

      //TODO: Implementar teste
    });
  });
}
