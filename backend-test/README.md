# Backend de testes local

Mock API HTTP com Python standard library. Não é um backend de produção e não tem autenticação. A aplicação Flutter atual não consome esta API; usa SQLite no dispositivo. Esta separação permite testar os contratos HTTP antes de implementar o backend real.

Executar a partir da raiz do projeto:

```powershell
python .\backend-test\server.py
```

Endpoints de leitura: `/api/health`, `/api/runs`, `/api/supervisors`, `/api/config`.

O servidor só escuta `127.0.0.1`. Não o exponhas a redes públicas.
