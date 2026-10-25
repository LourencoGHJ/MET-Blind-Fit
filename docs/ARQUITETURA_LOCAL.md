# Arquitetura local — MET Blind Fit v0.3

## Componentes

- `lib/main.dart`: interface Flutter, navegação e fluxos demonstrativos.
- `lib/data/local_database.dart`: SQLite, seed, reservas, amizades, log e preferências.
- `backend-test/server.py`: API mock independente, apenas loopback, estado JSON.
- `backend-test/data/seed.json`: dados públicos fictícios para corridas e supervisores.
- `backend-test/data/state.json`: estado mutável dos testes; pode ser apagado para repor o estado.
- `backend-test/tests/test_api.py`: smoke tests da API mock.
- `build-apk.ps1`: valida e tenta gerar APK debug.

## Fonte de verdade

Durante o protótipo, a app usa SQLite diretamente. O backend mock é um exercício separado de desenho de API e não está ligado à UI. Não existe sincronização entre SQLite e JSON.

## Regras de segurança do protótipo

- Dados fictícios; não guardar informação real de saúde ou contactos de emergência.
- Sem GPS real, tracking, chamadas, notificações ou SOS operacional.
- Estados de verificação são apenas demonstração.
- O backend não possui autenticação e só deve ser executado em `127.0.0.1`.

## Evolução prevista

Introduzir camada `repository` entre UI e armazenamento; definir contratos de domínio para `Run`, `Booking`, `Friendship`, `GuideAssignment`, `Incident` e `Session`; adicionar validação de capacidade e atribuições; depois substituir o mock por uma API autenticada com autorização por evento e registos de auditoria.
