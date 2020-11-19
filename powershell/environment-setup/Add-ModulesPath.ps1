$modulesPath = Resolve-Path $PSScriptRoot\..\modules

if(-not $env:PSModulePath.Contains($modulesPath))
{
  $env:PSModulePath = "$env:PSModulePath;$modulesPath"
}
