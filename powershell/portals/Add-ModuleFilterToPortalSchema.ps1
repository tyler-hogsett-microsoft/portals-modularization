param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

$schemaXml = New-Object xml
$schemaXml.Load($Path)

$entityNodes = $schemaXml.SelectNodes("entities/entity")
$entityNodes | ForEach-Object {
    $entityNode = $_
    $moduleLookupNode = $entityNode.SelectSingleNode("descendant::fields/field[@name='mdce_module_id']")
    if($moduleLookupNode) {
        $filterNode = $entityNode.SelectSingleNode("descendant::filter")
        if(-not $filterNode) {
            $filterNode = $schemaXml.CreateElement("filter")
            $entityNode.AppendChild($filterNode) | Out-Null
        }
        $fetchXmlQuery = `
            "<fetch>" +
                "<entity name=`"$($entityNode.name)`">" +
                    "<attribute name=`"$($entityNode.primaryidfield)`" />" +
                    "<link-entity name=`"mdce_portal_module`" from=`"mdce_portal_moduleid`" to=`"mdce_module_id`">" +
                        "<filter>" +
                            "<condition attribute=`"mdce_name`" operator=`"eq`" value=`"$ModuleName`" />" +
                        "</filter>" +
                    "</link-entity>" +
                "</entity>" +
            "</fetch>"
        $filterNode.InnerText = $fetchXmlQuery
    }
}

$annotationEntityNode = $schemaXml.SelectSingleNode("entities/entity[@name='annotation']")
$filterNode = $annotationEntityNode.SelectSingleNode("descendant::filter")
if(-not $filterNode) {
    $filterNode = $schemaXml.CreateElement("filter")
    $annotationEntityNode.AppendChild($filterNode) | Out-Null
}
$fetchXmlQuery = `
    "<fetch>" +
        "<entity name=`"annotation`">" +
            "<attribute name=`"annotationid`" />" +
            "<link-entity name=`"adx_webfile`" from=`"adx_webfileid`" to=`"objectid`">" +
                "<link-entity name=`"mdce_portal_module`" from=`"mdce_portal_moduleid`" to=`"mdce_module_id`">" +
                    "<filter>" +
                        "<condition attribute=`"mdce_name`" operator=`"eq`" value=`"$ModuleName`" />" +
                    "</filter>" +
                "</link-entity>" +
            "</link-entity>" +
        "</entity>" +
    "</fetch>"
$filterNode.InnerText = $fetchXmlQuery

$moduleEntityNode = $schemaXml.SelectSingleNode("entities/entity[@name='mdce_portal_module']")
$filterNode = $moduleEntityNode.SelectSingleNode("descendant::filter")
if(-not $filterNode) {
    $filterNode = $schemaXml.CreateElement("filter")
    $moduleEntityNode.AppendChild($filterNode) | Out-Null
}
$fetchXmlQuery = `
    "<fetch>" +
        "<entity name=`"mdce_portal_module`">" +
            "<attribute name=`"mdce_portal_moduleid`" />" +
            "<filter>" +
                "<condition attribute=`"mdce_name`" operator=`"eq`" value=`"$ModuleName`" />" +
            "</filter>" +
        "</entity>" +
    "</fetch>"
$filterNode.InnerText = $fetchXmlQuery



$schemaXml.Save($Path)