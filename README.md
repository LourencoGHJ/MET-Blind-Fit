# MET Blind Fit — protótipo Android-first v0.3

Aplicação Flutter em português de Portugal para explorar corridas inclusivas com corredores cegos ou com baixa visão, guias, supervisores e grupos comunitários. O objetivo desta versão é validar o fluxo e a arquitetura antes de ligar serviços reais.

## O que existe

- Entrada por perfil: corredor, guia, supervisor e administrador demonstrativo.
- Descoberta de corridas com pesquisa e filtros.
- Detalhe de evento, capacidade, ponto de encontro, ritmo e supervisor previsto.
- Reservas e cancelamentos persistidos em SQLite.
- Comunidade, QR demonstrativo e amizades guardadas localmente.
- Painel de supervisão com checklist, estados simulados de sinal e incidentes demonstrativos.
- Ecrã de corrida ativa com mapa ilustrativo, pedido de ajuda simulado e exemplos de instruções.
- Preferências de acessibilidade persistidas localmente: texto ampliado e fundo de alto contraste aplicados globalmente; preferências de áudio e sinais táteis guardadas para implementação futura.
- Registo local de atividade.
- Backend de teste independente com armazenamento JSON e endpoints para corridas, supervisores, reservas, amizades, sessões e incidentes.
- Script PowerShell de compilação APK com validação de pré-requisitos, análise, testes e build.

## Acessibilidade

A aplicação procura usar controlos grandes, rótulos descritivos e estrutura semântica. A preferência de texto ampliado afeta a escala de texto global; o modo de alto contraste usa fundo branco. Estas opções não substituem as definições do sistema, VoiceOver ou TalkBack.

**Antes de qualquer piloto real:** validar com TalkBack e utilizadores cegos/baixa visão; testar tamanhos de letra extremos, foco, ordem de leitura, contraste, orientação e uso durante movimento. Não usar o telemóvel enquanto se corre de forma que comprometa a segurança.

## Persistência local

A base SQLite `met_blind_fit_local.db` é criada no armazenamento privado da aplicação Android. Guarda corridas de demonstração, reservas, amizades, registo de atividade e preferências. O esquema é migrável da versão anterior para a versão 2.

## Construir APK no Windows

Requisitos: Flutter SDK, Android SDK e uma instalação Java compatível com a versão Flutter/Gradle configurada.

1. Extrai a pasta do ZIP.
2. Abre PowerShell na pasta raiz, onde está `pubspec.yaml`.
3. Executa:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\build-apk.ps1
```

O script tenta preparar a plataforma Android, executar `flutter pub get`, `flutter analyze`, `flutter test` e compilar o APK de debug.

Saída esperada: `build\app\outputs\flutter-apk\app-debug.apk`.

Se precisares de gerar os diretórios Android manualmente:

```powershell
flutter create . --platforms=android
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Backend local de testes

O backend é independente da app Flutter. Para iniciar:

```powershell
python .\backend-test\server.py
```

Endpoints de teste:
- `GET /api/health`
- `GET /api/runs`
- `GET /api/supervisors`
- `GET /api/config`
- `GET /api/bookings`, `GET /api/friends`, `GET /api/incidents`, `GET /api/sessions`
- `POST /api/bookings` com `run_id` e `user_id`
- `POST /api/friends` com `name`
- `POST /api/incidents` com `kind` e descrição opcional
- `POST /api/sessions` com `run_id`
- `DELETE /api/{bookings|friends|incidents|sessions}/<id>`

Os registos são guardados em `backend-test/data/state.json`. Executa testes rápidos com:

```powershell
python -m unittest discover -s .\backend-test\tests
```

O backend liga exclusivamente a `127.0.0.1`, não tem autenticação, controlo de acesso, proteção CSRF, rate limiting nem validação de identidade. **É apenas para desenvolvimento local. Não o exponhas à Internet e não uses dados pessoais reais.** A app Flutter ainda não consome automaticamente esta API; a persistência de produção não está implementada.

## Funcionalidades ainda simuladas

Não há login real, sincronização entre dispositivos, verificação de identidade, GPS, localização em tempo real, Google Maps/OSM integrado, TTS real, microfone, chamadas, notificações push ou contacto com serviços de emergência. Os perfis, rotas, presenças e alertas são fictícios. Os estados de verificação são ilustrativos e não comprovam a identidade ou qualificação de ninguém.

## Próximas fases

1. Compilar e validar o APK no ambiente Android.
2. Testar os fluxos com TalkBack e pessoas cegas/baixa visão.
3. Ligar UI a repositórios locais bem definidos e adicionar testes de integração.
4. Criar autenticação, permissões, verificação de guias/supervisores e consentimento.
5. Implementar backend seguro, regras de autorização e sincronização.
6. Só depois adicionar localização partilhada, rotas, TTS, notificações e processos de emergência.


## Verificação do código

A versão corrigida reorganiza `lib/main.dart` em widgets e métodos separados para reduzir erros de sintaxe. Executa `flutter analyze` e `flutter test` no Windows antes de gerar o APK. A compilação ainda precisa de ser confirmada no teu ambiente com Android SDK instalado.
