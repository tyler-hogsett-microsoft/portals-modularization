param(
    $Connection = (& $PSScriptRoot\..\cds\Get-CrmConnection.ps1),
    [Parameter(Mandatory=$true)]
    [string]$PortalFolderPath,
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

$module = (
    Get-CrmRecords `
        -conn $Connection `
        -EntityLogicalName mdce_portal_module `
        -FilterAttribute mdce_name `
        -FilterOperator eq `
        -FilterValue $ModuleName `
        -Fields @( "mdce_portal_moduleid" )
).CrmRecords[0]
$moduleId = $module.mdce_portal_moduleid.Guid

$schemaXml = New-Object xml
$schemaXml.Load("$PortalFolderPath\data_schema.xml")

$dataXml = New-Object xml
$dataXmlFilePath = "$PortalFolderPath\data.xml"
$dataXml.Load($dataXmlFilePath)
$entityNodes = $dataXml.SelectNodes("entities/entity")
$entityNodes | ForEach-Object {
    $entityNode = $_
    $entityLogicalName = $entityNode.name
    $schemaModuleLookupNode = $schemaXml.SelectSingleNode(
        "entities/entity[@name='$entityLogicalName']/fields/field[@name='mdce_module_id']")
    if($schemaModuleLookupNode -ne $null) {
        $recordsNode = $entityNode.SelectSingleNode("descendant::records")
        $recordsNode.ChildNodes | ForEach-Object {
            $recordNode = $_
            $moduleLookupNode = $recordNode.SelectSingleNode("descendant::field[@name='mdce_module_id']")
            if($moduleLookupNode -eq $null) {
                $recordNode.InnerXml += "
        <field name=`"mdce_module_id`" value=`"$moduleId`" lookupentity=`"mdce_portal_module`" lookupentityname=`"$ModuleName`" />
"
            } else {
                $moduleLookupNode.SetAttribute("value", $moduleId)
            }
        }
    }
}

$dataXml.Save($dataXmlFilePath)