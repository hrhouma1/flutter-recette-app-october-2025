# Script pour supprimer le champ "icon" des catégories existantes dans Firestore

$projectId = "flutter-recette-october-2025-1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Suppression des icônes des catégories" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Obtenir le token d'accès
try {
    $token = gcloud auth print-access-token 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur d'authentification" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Token obtenu" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'obtention du token" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 Récupération des catégories..." -ForegroundColor Yellow

$listUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/categories"
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $response = Invoke-RestMethod -Method Get -Uri $listUrl -Headers $headers
    $documents = $response.documents
    
    Write-Host "✅ $($documents.Count) catégories trouvées" -ForegroundColor Green
    Write-Host ""
    Write-Host "🗑️  Suppression des icônes..." -ForegroundColor Yellow
    Write-Host ""
    
    $count = 0
    foreach ($doc in $documents) {
        $count++
        $docName = $doc.name
        $categoryName = $doc.fields.name.stringValue
        
        # Créer le body sans le champ icon
        $updateBody = @{
            fields = @{
                name = @{stringValue = $doc.fields.name.stringValue}
                color = @{stringValue = $doc.fields.color.stringValue}
            }
        } | ConvertTo-Json -Depth 10
        
        $updateHeaders = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        try {
            Invoke-RestMethod -Method Patch -Uri "https://firestore.googleapis.com/v1/$docName" -Headers $updateHeaders -Body $updateBody | Out-Null
            Write-Host "   $count. ✅ $categoryName - icône supprimée" -ForegroundColor Green
        } catch {
            Write-Host "   $count. ❌ Erreur pour $categoryName" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✅ TERMINÉ!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

