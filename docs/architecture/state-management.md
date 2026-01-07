# State Management

## Introdução
Para manter consistência e previsibilidade entre times/agentes, adotamos o pacote [`provider`](https://pub.dev/packages/provider) como camada oficial de gerenciamento de estado. Ele combina `ChangeNotifier`, `ValueNotifier`, `Provider`/`ProxyProvider`, `Selector` e `Consumer` para oferecer DI explícita, rebuilds controlados e integração direta com a árvore de widgets. `setState` fica restrito a interações efêmeras locais, enquanto regras de negócio vivem em use cases/repos e são consumidas pelos notifiers.

## Decisão
O stack Provider foi escolhido após comparar alternativas (Bloc/Cubit, Riverpod, MobX, Streams manuais). Os critérios principais:
- alinhamento com os guardrails de DI via construtor + Provider já definidos no projeto;
- API simples para o time, com pouca curva de aprendizado e excelente suporte em Flutter;
- granularidade de rebuild com `Selector`/`context.select`, reduzindo repaints em listas e grandes árvores;
- facilidade de teste unitário e widget (instanciar o `ChangeNotifier`, injetar dependências fake e envolver o widget em um `ChangeNotifierProvider` mínimo);
- integração direta com `MultiProvider` no `main.dart` e com o roteamento atual (`go_router`).

## Padrão Principal

**Stack oficial**
- `ChangeNotifier` (ou `ChangeNotifier` + estado imutável interno) para view models que orquestram casos de uso.
- `ValueNotifier<T>` para estados simples ou campos derivados específicos.
- `Provider`, `ChangeNotifierProvider`, `ProxyProvider` e `Consumer` como forma de registrar/injetar dependências.
- `Selector`/`context.select` para granularidade de rebuild.

**Estrutura recomendada**
- `lib/application/<feature>/<feature>_notifier.dart`: classe `ChangeNotifier` (ou múltiplos notifiers especializados).
- `lib/application/<feature>/<feature>_state.dart`: modelo imutável com `copyWith`/`when`.
- `lib/application/<feature>/<feature>_provider.dart`: definição de `ChangeNotifierProvider`/`ProxyProvider`.
- Registro global em `main.dart` ou `app_router.dart` via `MultiProvider`.

**Fluxo básico**
1. Use cases/repos são injetados no construtor do notifier via `ProxyProvider`.
2. O notifier mantém `_state` imutável e expõe getters ou o próprio snapshot (por exemplo, `FeatureState get state => _state;`).
3. Métodos públicos atualizam `_state` e chamam `notifyListeners()` após trocar o snapshot.
4. Widgets consomem com `context.watch<Notifier>()`, `context.select` ou `Selector` apontando apenas para o campo necessário.

## Regras e Boas Práticas
- Um notifier por responsabilidade clara (ex.: `RecipeListNotifier`, `RecipeDetailNotifier`). Evite “God Notifiers”.
- Estado sempre imutável: use `freezed` ou DTO com `copyWith`, garantindo que cada mutação troque o objeto inteiro antes de notificar.
- Nunca chamar serviços diretamente do widget: todo IO passa pelo notifier/use case.
- Trate erros na camada do notifier e exponha mensagens amigáveis ou estados (`loading`, `error`, `idle`).
- Prefira `Selector`/`context.select` para listas extensas ou widgets que dependem de apenas um campo.
- Garanta `dispose()` no notifier para cancelar streams/timers. O `ChangeNotifierProvider` já cuida disso quando usado corretamente.
- Documente desvios ou necessidades especiais em ADRs e cite o motivo na PR.

## Exemplo Resumido

```dart
// lib/application/orders/orders_state.dart
class OrdersState {
  const OrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.error,
  });

  final bool isLoading;
  final List<Order> orders;
  final String? error;

  OrdersState copyWith({
    bool? isLoading,
    List<Order>? orders,
    String? error,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error,
    );
  }

  static const initial = OrdersState();
}

// lib/application/orders/orders_notifier.dart
class OrdersNotifier extends ChangeNotifier {
  OrdersNotifier(this._fetchOrders) : _state = OrdersState.initial;

  final FetchOrdersUseCase _fetchOrders;
  OrdersState _state;

  OrdersState get state => _state;

  Future<void> load() async {
    _setState(_state.copyWith(isLoading: true, error: null));
    final result = await _fetchOrders();
    result.fold(
      (failure) => _setState(_state.copyWith(isLoading: false, error: failure.message)),
      (orders) => _setState(_state.copyWith(isLoading: false, orders: orders)),
    );
  }

  void _setState(OrdersState newState) {
    if (newState == _state) return;
    _state = newState;
    notifyListeners();
  }
}

// lib/application/orders/orders_provider.dart
final ordersNotifierProvider = ChangeNotifierProvider<OrdersNotifier>(
  create: (context) => OrdersNotifier(context.read<FetchOrdersUseCase>()),
);

// lib/main.dart (trecho)
MultiProvider(
  providers: [
    Provider<FetchOrdersUseCase>(
      create: (_) => FetchOrdersUseCase(ordersRepository),
    ),
    ordersNotifierProvider,
  ],
  child: const App(),
);
```

```dart
// lib/presentation/orders/orders_page.dart
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersNotifier>(
      builder: (_, notifier, __) {
        final state = notifier.state;
        if (state.isLoading) return const CircularProgressIndicator();
        if (state.error != null) return ErrorView(message: state.error!);
        return OrdersListView(orders: state.orders);
      },
    );
  }
}
```

## Checklist
- [ ] `ChangeNotifier`/`ValueNotifier` criado em `lib/application/<feature>/`.
- [ ] Estado imutável com `copyWith`/`freezed` e `notifyListeners()` após trocar o snapshot.
- [ ] Dependências injetadas via `Provider`/`ProxyProvider`, nunca instanciadas direto no widget.
- [ ] Consumo via `Consumer`/`Selector`/`context.select` garantindo rebuild mínimo.
- [ ] Testes cobrindo fluxos de sucesso/erro do notifier em `test/application/<feature>/`.
- [ ] `flutter analyze`/`flutter test` executados e linkados no PR, conforme DoR/DoD.

## Referências
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management Comparison](https://docs.flutter.dev/development/data-and-backend/state