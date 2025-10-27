# Script pour ajouter les catégories via gcloud et API REST Firestore
# Exécutez ce script dans un terminal PowerShell EXTERNE (pas VS Code)

$projectId = "flutter-recette-october-2025-1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ajout des catégories dans Firestore" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que gcloud est disponible
try {
    $gcloudVersion = gcloud --version 2>&1 | Select-String "Google Cloud SDK"
    Write-Host "✅ gcloud trouvé: $gcloudVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ gcloud n'est pas installé ou pas dans le PATH" -ForegroundColor Red
    Write-Host "Installez-le avec: winget install Google.CloudSDK" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔐 Authentification..." -ForegroundColor Yellow

# Obtenir le token d'accès
try {
    $token = gcloud auth print-access-token 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur d'authentification" -ForegroundColor Red
        Write-Host "Exécutez d'abord: gcloud auth login" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Token obtenu" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'obtention du token" -ForegroundColor Red
    Write-Host "Exécutez d'abord: gcloud auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📝 Ajout des 12 catégories..." -ForegroundColor Yellow
Write-Host ""

# Définir les catégories
$categories = @(
    @{name="Breakfast"; icon="🍳"; color="FFE8B4"},
    @{name="Lunch"; icon="🍱"; color="FFC4E1"},
    @{name="Dinner"; icon="🍽️"; color="C4E1FF"},
    @{name="Desserts"; icon="🍰"; color="FFD4D4"},
    @{name="Appetizers"; icon="🥗"; color="D4FFD4"},
    @{name="Soups"; icon="🍲"; color="FFE4C4"},
    @{name="Beverages"; icon="🥤"; color="E4C4FF"},
    @{name="Snacks"; icon="🍿"; color="FFFACD"},
    @{name="Vegetarian"; icon="🥬"; color="C8E6C9"},
    @{name="Seafood"; icon="🦐"; color="B3E5FC"},
    @{name="Pasta"; icon="🍝"; color="FFCCBC"},
    @{name="Pizza"; icon="🍕"; color="FFE0B2"}
)

$url = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/categories"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$count = 0
foreach ($category in $categories) {
    $count++
    
    $body = @{
        fields = @{
            name = @{stringValue = $category.name}
            icon = @{stringValue = $category.icon}
            color = @{stringValue = $category.color}
        }
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop
        Write-Host "   $count. ✅ $($category.name) ajouté" -ForegroundColor Green
    } catch {
        Write-Host "   $count. ❌ Erreur pour $($category.name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ TERMINÉ!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vérifiez dans Firebase Console:" -ForegroundColor Yellow
Write-Host "https://console.firebase.google.com/project/$projectId/firestore" -ForegroundColor Cyan
Write-Host ""

