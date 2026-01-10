import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/app/app.dart';
import 'package:app_todo/features/tasks/repository/auth_repository.dart';
import 'package:app_todo/features/tasks/repository/firebase_auth_repository.dart';
import 'package:app_todo/features/tasks/repository/firebase_task_repository.dart';
import 'package:app_todo/features/tasks/repository/firebase_user_repository.dart';
import 'package:app_todo/features/tasks/repository/task_repository.dart';
import 'package:app_todo/features/tasks/repository/user_repository.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';
import 'package:app_todo/features/tasks/view_model/profile_model.dart';
import 'package:app_todo/features/tasks/view_model/tasks_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider: servico puro (auth) sem estado de UI; fica global para reuso e facilita mock em testes.
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(FirebaseAuth.instance),
        ),
        // Provider: repositorio de usuario usa Firestore/Storage, mas nao emite mudanca direto na UI.
        // Exposto via interface para desacoplar Firebase e simplificar trocas futuras.
        Provider<UserRepository>(
          create: (_) => FirebaseUserRepository(
            FirebaseFirestore.instance,
            FirebaseStorage.instance,
          ),
        ),
        // Provider: repositorio de tarefas centraliza acesso a dados e regras; sem notifyListeners.
        // Mantem uma unica instancia compartilhada entre modelos.
        Provider<TaskRepository>(
          create: (_) => FirebaseTaskRepository(FirebaseFirestore.instance),
        ),
        // ChangeNotifierProvider: AuthModel muda com login/logout; precisa notificar a UI quando status muda.
        // Depende dos repositorios acima para executar operacoes sem acoplamento direto a Firebase.
        ChangeNotifierProvider<AuthModel>(
          create: (context) => AuthModel(
            authRepository: context.read<AuthRepository>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
        // ChangeNotifierProxyProvider2: ProfileModel depende de AuthModel + UserRepository; reata bind quando auth muda.
        // Mantemos a mesma instancia (update) para preservar listeners e estado local.
        ChangeNotifierProxyProvider2<AuthModel, UserRepository, ProfileModel>(
          create: (_) => ProfileModel(),
          update: (_, authModel, userRepository, profileModel) {
            final model = profileModel ?? ProfileModel();
            model.bind(authModel: authModel, userRepository: userRepository);
            return model;
          },
        ),
        // ChangeNotifierProxyProvider2: TasksModel usa usuario atual + TaskRepository para filtrar e carregar tarefas.
        // Proxy garante recarregar dados quando autenticação troca sem recriar toda a arvore.
        ChangeNotifierProxyProvider2<AuthModel, TaskRepository, TasksModel>(
          create: (_) => TasksModel(),
          update: (_, authModel, taskRepository, tasksModel) {
            final model = tasksModel ?? TasksModel();
            model.bind(authModel: authModel, taskRepository: taskRepository);
            return model;
          },
        ),
      ],
      child: const MainApp(),
    );
  }
}
