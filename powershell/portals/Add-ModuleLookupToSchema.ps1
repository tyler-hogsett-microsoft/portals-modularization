param(
    $Connection,
    [Parameter(Mandatory=$true)]
    [string]$SchemaFilePath
)

$xml = New-Object xml
$xml.Load($SchemaFilePath)

$entityNodes = $xml.SelectNodes("entities/entity")
$entityNodes | ForEach-Object {
    $entityNode = $_
    $fieldsNode = $entityNode.SelectSingleNode("descendant::fields")

    $existingModuleLookupNode = $fieldsNode.SelectSingleNode("descendant::field[@name='mdce_module_id']")
    if($existingModuleLookupNode -eq $null) {
        $entityLogicalName = $entityNode.name

        $attributeMetadata = Get-CrmEntityAttributeMetadata `
            -conn $Connection `
            -EntityLogicalName $entityLogicalName `
            -FieldLogicalName mdce_module_id `
            -ErrorAction SilentlyContinue
        if($attributeMetadata -ne $null) {
            $fieldsNode.InnerXml += "
      <field displayname=`"Module`" name=`"mdce_module_id`" type=`"entityreference`" lookupType=`"mdce_portal_module`" customfield=`"true`" />
    "
        }
    }
}

$xml.Save($SchemaFilePath)