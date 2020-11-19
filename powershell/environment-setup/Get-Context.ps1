$localConfigPath = "$PSScriptRoot\..\local.config.json"

if(-Not (Test-Path $localConfigPath))
{
  if(-not [Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
    . "$PSScriptRoot\Initialize-Context.ps1"
  }
}

if(Test-Path $localConfigPath) {
  $context = Get-Content $localConfigPath `
  | ConvertFrom-Json

  if($context.Password) {
    $context.Password = (ConvertTo-SecureString $context.Password)
  }
  if($context.ClientSecret) {
    $context.ClientSecret = (ConvertTo-SecureString $context.ClientSecret)
  }

  $context
}
