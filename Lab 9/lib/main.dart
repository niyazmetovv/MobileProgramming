import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bloc/cart_page_bloc.dart';
import 'cubit/cart_page_cubit.dart';
import 'riverpod/cart_page_riverpod.dart';
import 'setstate/cart_page_setstate.dart';

class CartObserver extends BlocObserver {
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    final eventName = transition.event.runtimeType;
    debugPrint('${bloc.runtimeType} transition, event $eventName');
    debugPrint('  from ${transition.currentState}');
    debugPrint('  to ${transition.nextState}');
  }
}

void main() {
  Bloc.observer = CartObserver();
  runApp(const ProviderScope(child: CartApp()));
}

class CartApp extends StatelessWidget {
  const CartApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cart Four Ways',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cart Four Ways')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => _open(context, const SetStateCartPage()),
                child: const Text('setState'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _open(context, const RiverpodCartPage()),
                child: const Text('Riverpod'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _open(context, const CubitCartPage()),
                child: const Text('Cubit'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _open(context, const BlocCartPage()),
                child: const Text('Bloc'),
              ),
            ],
          ),
        ),
      );
}

// Checkpoint questions
// 1. setState keeps the state in the State object of the page and it dies when the page is popped, Riverpod keeps it in the ProviderContainer and it lives until the app closes (or until nobody watches it with autoDispose), Cubit and Bloc keep it in the object created by BlocProvider and it dies when BlocProvider is removed from the tree
// 2. Notifier has its own methods that set state, Cubit has methods that call emit, Bloc has only add(event), setState has no public API because the state is private in the State class
// 3. ref.watch is BlocBuilder, ref.read is context.read, ref.listen is BlocListener, and setState does not subscribe to anything it just runs build again for the whole page
// 4. if the new state equals the old one there is nothing new to draw so rebuilding is a waste, for this to work CartState has to be immutable and has to have == and hashCode (I used Equatable)
// 5. setState needs mounted because the State can be gone after the await, Riverpod needs nothing for the widget since the notifier does not use the page (I have ref.mounted only because of autoDispose), Cubit needs isClosed because emit after close throws, Bloc needs emit.isDone because the handler is cancelled when the bloc closes
