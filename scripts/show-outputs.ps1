#!/usr/bin/env pwsh
# Script to display key deployment output values

Write-Host "Key Deployment Outputs:" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

# Get environment values
$envValues = azd env get-values | ConvertFrom-StringData

Write-Host "KEYVAULT_URI: " -NoNewline -ForegroundColor Cyan
Write-Host $envValues["KEYVAULT_URI"] -ForegroundColor White

Write-Host "KEYVAULT_OPENAI_ENDPOINT: " -NoNewline -ForegroundColor Cyan
Write-Host $envValues["KEYVAULT_OPENAI_ENDPOINT"] -ForegroundColor White

Write-Host "KEYVAULT_OPENAI_API_KEY: " -NoNewline -ForegroundColor Cyan
Write-Host $envValues["KEYVAULT_OPENAI_API_KEY"] -ForegroundColor White

Write-Host "OPENAI_GPT_MODEL: " -NoNewline -ForegroundColor Cyan
Write-Host $envValues["OPENAI_GPT_MODEL"] -ForegroundColor White

Write-Host "OPENAI_EMBEDDING_MODEL: " -NoNewline -ForegroundColor Cyan
Write-Host $envValues["OPENAI_EMBEDDING_MODEL"] -ForegroundColor White