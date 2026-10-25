import 'package:flutter_test/flutter_test.dart';
import 'package:met_blind_fit/main.dart';

void main() {
  testWidgets('mostra os quatro modos da aplicação', (tester) async {
    await tester.pumpWidget(const MetBlindFitApp());
    expect(find.text('MET BLIND FIT'), findsOneWidget);
    expect(find.text('Corredor invisual / baixa visão'), findsOneWidget);
    expect(find.text('Guia de corrida'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);
    expect(find.text('Administrador (demo)'), findsOneWidget);
  });

  testWidgets('o fluxo de entrada permite cancelar a seleção', (tester) async {
    await tester.pumpWidget(const MetBlindFitApp());
    await tester.tap(find.text('Guia de corrida'));
    await tester.pumpAndSettle();
    expect(find.text('Entrar como guia?'), findsOneWidget);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Guia de corrida'), findsOneWidget);
  });
}
