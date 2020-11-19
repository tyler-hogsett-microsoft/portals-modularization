[CmdletBinding(DefaultParameterSetName="ClientSecretAuthentication")]

param(
  [Parameter(Mandatory=$true)]
  [string]$Url,
  
  [Parameter(
    Mandatory=$true,
    ParameterSetName="ClientSecretAuthentication")]
  [string]$ClientId,
  [Parameter(
    Mandatory=$true,
    ParameterSetName="ClientSecretAuthentication")]
  [SecureString]$ClientSecret,

  [Parameter(
    Mandatory=$true,
    ParameterSetName="UsernamePasswordAuthentication")]
  [switch]$UseBasicAuthentication,

  [Parameter(
    Mandatory=$true,
    ParameterSetName="ActiveDirectoryAuthentication"
  )]
  [switch]$UseActiveDirectoryAuthentication,

  [Parameter(
    Mandatory=$true,
    ParameterSetName="UsernamePasswordAuthentication")]
  [Parameter(ParameterSetName="ActiveDirectoryAuthentication")]
  [string]$Username,
  [Parameter(
    Mandatory=$true,
    ParameterSetName="UsernamePasswordAuthentication")]
  [Parameter(ParameterSetName="ActiveDirectoryAuthentication")]
  [SecureString]$Password,
  [Parameter(ParameterSetName="ActiveDirectoryAuthentication")]
  [string]$Domain
)

$localConfigPath = "$PSScriptRoot\..\local.config.json"

$context = @{
  Url = $Url
}
if($UseBasicAuthentication)
{
  $context.AuthenticationType = "Basic"
  $context.Username = $Username
  $context.Password = (ConvertFrom-SecureString $Password)
} elseif($UseActiveDirectoryAuthentication) {
  $context.AuthenticationType = "ActiveDirectory"
  if($Username) {
    $context.Username = $Username
    $context.Password = (ConvertFrom-SecureString $Password)
    $context.Domain = $Domain
  }
} else {
  $context.AuthenticationType = "ClientSecret"
  $context.ClientId = $ClientId
  $context.ClientSecret = (ConvertFrom-SecureString $ClientSecret)
}

$context | ConvertTo-Json `
| Out-File $localConfigPath