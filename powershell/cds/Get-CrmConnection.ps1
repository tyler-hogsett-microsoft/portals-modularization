param(
  $Context
)
if($Context -eq $null)
{
  $Context = (. "$PSScriptRoot\..\environment-setup\Get-Context.ps1")
}

. $PSScriptRoot\..\environment-setup\Add-ModulesPath.ps1

function ConvertTo-UnsecureString {
  param(
    [Parameter(Mandatory=$true)]
    [SecureString]$secureString
  )
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
  $unsecureString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  $unsecureString
}

switch($Context.AuthenticationType)
{
  "Basic" {
    $connectionString = `
      "AuthType=Office365; " +
      "Url=$($Context.Url); " +
      "Username=$($Context.Username); " +
      "Password=$(ConvertTo-UnsecureString $Context.Password)"
  }
  "ClientSecret" {
    $connectionString = `
      "AuthType=ClientSecret; " +
      "Url=$($Context.Url); " +
      "ClientId=$($Context.ClientId); " +
      "ClientSecret=$(ConvertTo-UnsecureString $Context.ClientSecret)"
  }
  "ActiveDirectory" {
    $connectionString = `
      "AuthType=AD; " +
      "Url=$($Context.Url)"
    if($context.Username)
    {
      $connectionString += "; " +
        "Username=$($context.Username); " +
        "Password=$(ConvertTo-UnsecureString $context.Password); " +
        "Domain=$($context.Domain)"
    }
  }
}
$connection = Get-CrmConnection -ConnectionString $connectionString

$connection