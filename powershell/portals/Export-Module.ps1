param(
    $Connection = (& $PSScriptRoot\..\cds\Get-CrmConnection.ps1),
    [Parameter(Mandatory=$true)]
    [string]$ModuleFolderPath
)

$dataXml = New-Object xml
$dataXml.Load("$ModuleFolderPath\data.xml")

$moduleId = $dataXml.SelectSingleNode("entities/entity[@name='mdce_portal_module']/records/record").GetAttribute("id")
$module = Get-CrmRecord `
    -conn $Connection `
    -EntityLogicalName mdce_portal_module `
    -Id $moduleId `
    -Fields @( "mdce_version" )

$version = $module.mdce_version
$versionParts = $version.Split(".")
$revisionNumber = [int]::Parse($versionParts[$versionParts.Length - 1]) + 1
$versionParts[$versionParts.Length - 1] = $revisionNumber
$newVersion = [string]::Join(".", $versionParts)

Update-CrmRecord `
    -conn $Connection `
    -EntityLogicalName mdce_portal_module `
    -Id $moduleId `
    -Fields @{
        mdce_version = $newVersion
    }

& $PSScriptRoot\Export-Portal.ps1 `
    -Connection $Connection `
    -SchemaFilePath "$ModuleFolderPath\data_schema.xml" `
    -TargetFolderPath $ModuleFolderPath