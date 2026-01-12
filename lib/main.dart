import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/app/app.dart';
import 'package:app_todo/features/tasks/repository/auth_repository.dart';
import 'package:app_todo/features/tasks/repository/local_auth_repository.dart';
import 'package:app_todo/features/tasks/repository/local_task_repository.dart';
import 'package:app_todo/features/tasks/repository/local_user_repository.dart';
import 'package:app_todo/features/tasks/repository/task_repository.dart';
import 'package:app_todo/features/tasks/repository/user_repository.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';
import 'package:app_todo/features/tasks/view_model/profile_model.dart';
import 'package:app_todo/features/tasks/view_model/tasks_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final appDir = await getApplicationDocumentsDirectory();
  final authBox = await Hive.openBox('local_auth');
  final profilesBox = await Hive.openBox('local_profiles');
  final tasksBox = await Hive.openBox('local_tasks');
  runApp(
    AppBootstrap(
      authBox: authBox,
      profilesBox: profilesBox,
      tasksBox: tasksBox,
      appDocumentsPath: appDir.path,
    ),
  );
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({
    super.key,
    required this.authBox,
    required this.profilesBox,
    required this.tasksBox,
    required this.appDocumentsPath,
  });

  final Box<dynamic> authBox;
  final Box<dynamic> profilesBox;
  final Box<dynamic> tasksBox;
  final String appDocumentsPath;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider: auth local em memoria para manter login e isolar a UI do armazenamento.
        Provider<AuthRepository>(
          create: (_) => LocalAuthRepository(authBox),
        ),
        // Provider: repositorio de perfis local, usado pelos models sem dependencias externas.
        Provider<UserRepository>(
          create: (_) => LocalUserRepository(profilesBox, appDocumentsPath),
        ),
        // Provider: repositorio de tarefas em memoria; centraliza acesso e mantem estado por usuario.
        Provider<TaskRepository>(
          create: (_) => LocalTaskRepository(tasksBox),
        ),
        // ChangeNotifierProvider: AuthModel muda com login/logout; precisa notificar a UI quando status muda.
        // Depende dos repositorios acima para executar operacoes sem acoplamento direto ao armazenamento.
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
