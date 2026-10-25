$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Write-Host "`n=== MET Blind Fit - compilação APK ===" -ForegroundColor Green

$Flutter = (Get-Command flutter -ErrorAction SilentlyContinue).Source
if (-not $Flutter -and (Test-Path "C:\src\flutter\bin\flutter.bat")) {
    $Flutter = "C:\src\flutter\bin\flutter.bat"
}
if (-not $Flutter) {
    throw "Flutter não encontrado. Instala o Flutter e configura o PATH."
}
if (-not (Test-Path ".\pubspec.yaml")) {
    throw "Executa este script na pasta raiz do projeto, onde está pubspec.yaml."
}

$doctor = & $Flutter doctor -v 2>&1
$doctor | ForEach-Object { Write-Host $_ }
if (($doctor -join "`n") -match "Unable to locate Android SDK") {
    throw "Android SDK não encontrado. Instala o Android Studio, abre-o uma vez e instala o Android SDK e Platform-Tools. Depois volta a executar este script."
}

if (-not (Test-Path ".\android\settings.gradle") -and
    -not (Test-Path ".\android\settings.gradle.kts")) {
    Write-Host "A preparar a plataforma Android..." -ForegroundColor Cyan
    & $Flutter create . --platforms=android
    if ($LASTEXITCODE -ne 0) { throw "Falhou a criação da plataforma Android." }
}

& $Flutter pub get
if ($LASTEXITCODE -ne 0) { throw "Falhou flutter pub get." }

& $Flutter analyze
if ($LASTEXITCODE -ne 0) { throw "A análise do código encontrou erros; o APK não foi compilado." }

& $Flutter test
if ($LASTEXITCODE -ne 0) { throw "Os testes Flutter falharam; revê os erros antes de compilar." }

& $Flutter build apk --debug
if ($LASTEXITCODE -ne 0) { throw "A compilação do APK falhou." }

$apk = ".\build\app\outputs\flutter-apk\app-debug.apk"
if (Test-Path $apk) {
    Write-Host "`nAPK criado: $((Resolve-Path $apk).Path)" -ForegroundColor Green
} else {
    throw "O comando terminou mas não encontrei o APK no caminho esperado."
}
