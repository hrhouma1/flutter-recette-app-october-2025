# Script PowerShell pour importer les catégories dans Firestore
# Utilise Firebase Emulator pour les données

Write-Host "🔧 Import des catégories dans Firestore" -ForegroundColor Green
Write-Host ""

$projectId = "flutter-recette-october-2025"
$collection = "categories"

# Lire le fichier JSON
$jsonData = Get-Content "scripts\categories_import.json" -Raw | ConvertFrom-Json

Write-Host "📝 Données chargées depuis categories_import.json" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Firebase CLI est disponible
try {
    $firebaseVersion = firebase --version
    Write-Host "✅ Firebase CLI trouvé: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI n'est pas installé" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⚠️  IMPORTANT: Cette méthode nécessite l'import via l'émulateur" -ForegroundColor Yellow
Write-Host ""
Write-Host "Solutions alternatives:" -ForegroundColor Cyan
Write-Host "1. Utiliser l'application Flutter (Settings > Administration > Initialiser)" -ForegroundColor White
Write-Host "2. Créer manuellement 1 catégorie pour débloquer Firestore" -ForegroundColor White
Write-Host "3. Installer Google Cloud SDK avec: winget install Google.CloudSDK" -ForegroundColor White
Write-Host ""
Write-Host "Recommandation: Utilisez l'application Flutter - c'est la solution la plus simple!" -ForegroundColor Yellow

