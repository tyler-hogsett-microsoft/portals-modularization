param(
    [Parameter(Mandatory=$true)]
    [string]$SchemaFilePath
)

$xml = New-Object xml
$xml.Load($SchemaFilePath)

$entitiesNode = $xml.FirstChild

$moduleNode = $entitiesNode.SelectSingleNode("descendant::entity[@name='mdce_portal_module']")
if($moduleNode -eq $null) {
    $entitiesNode.InnerXml += "
  <entity name=`"mdce_portal_module`" displayname=`"Module`" primaryidfield=`"mdce_portal_moduleid`" primarynamefield=`"mdce_name`" disableplugins=`"true`">
    <fields>
      <field updateCompare=`"true`" displayname=`"Module`" name=`"mdce_portal_moduleid`" type=`"guid`" primaryKey=`"true`" />
      <field displayname=`"Name`" name=`"mdce_name`" type=`"string`" />
      <field displayname=`"Version`" name=`"mdce_version`" type=`"string`" />
    </fields>
    <relationships />
  </entity>
"
}

$xml.Save($SchemaFilePath)