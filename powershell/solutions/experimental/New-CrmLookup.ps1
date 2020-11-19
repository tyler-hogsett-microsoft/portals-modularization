param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionFolderPath,
    [Parameter(Mandatory=$true)]
    [string]$EntityLogicalName,
    [Parameter(Mandatory=$true)]
    [string]$AttributeDisplayName,
    [Parameter(Mandatory=$true)]
    [string]$TargetEntityLogicalName,
    [switch]$SkipSort
)

$attributeLogicalName = "$($AttributeDisplayName.ToLower() -Replace " ", "_")_id"

$xml = New-Object xml
$xml.PreserveWhitespace = $true

$entityXmlFilePath = "$SolutionFolderPath\Entities\$EntityLogicalName\Entity.xml"
$xml.Load($entityXmlFilePath)
$entityNode = $xml.SelectSingleNode("/Entity/EntityInfo/entity")
$entityNode.RemoveAttribute("unmodified")
$entityNameNode = $xml.SelectSingleNode("/Entity/Name")
$entitySchemaName = $entityNameNode.InnerXML
$entityDisplayName = $entityNameNode.Attributes["LocalizedName"].Value
$relationshipSchemaLongName = "mdce_$($entitySchemaName)_$($attributeLogicalName)_$TargetEntityLogicalName"
$relationshipSchemaName = $relationshipSchemaLongName.Substring(0, [Math]::Min(46, $relationshipSchemaLongName.Length))
$attributesNode = $xml.SelectSingleNode("/Entity/EntityInfo/entity/attributes")
$attributesNode.InnerXML += 
    $(if($attributesNode.InnerXML.Length -eq 0) { "`r`n" }) +
"        <attribute PhysicalName=`"$attributeLogicalName`">
          <Type>lookup</Type>
          <Name>$attributeLogicalName</Name>
          <LogicalName>$attributeLogicalName</LogicalName>
          <RequiredLevel>none</RequiredLevel>
          <DisplayMask>ValidForAdvancedFind|ValidForForm|ValidForGrid</DisplayMask>
          <ValidForUpdateApi>1</ValidForUpdateApi>
          <ValidForReadApi>1</ValidForReadApi>
          <ValidForCreateApi>1</ValidForCreateApi>
          <IsCustomField>1</IsCustomField>
          <IsAuditEnabled>0</IsAuditEnabled>
          <IsSecured>0</IsSecured>
          <IntroducedVersion>1.0.0.0</IntroducedVersion>
          <IsCustomizable>1</IsCustomizable>
          <IsRenameable>1</IsRenameable>
          <CanModifySearchSettings>1</CanModifySearchSettings>
          <CanModifyRequirementLevelSettings>1</CanModifyRequirementLevelSettings>
          <CanModifyAdditionalSettings>1</CanModifyAdditionalSettings>
          <SourceType>0</SourceType>
          <IsGlobalFilterEnabled>0</IsGlobalFilterEnabled>
          <IsSortableEnabled>0</IsSortableEnabled>
          <CanModifyGlobalFilterSettings>1</CanModifyGlobalFilterSettings>
          <CanModifyIsSortableSettings>1</CanModifyIsSortableSettings>
          <IsDataSourceSecret>0</IsDataSourceSecret>
          <AutoNumberFormat></AutoNumberFormat>
          <IsSearchable>0</IsSearchable>
          <IsFilterable>0</IsFilterable>
          <IsRetrievable>0</IsRetrievable>
          <IsLocalizable>0</IsLocalizable>
          <LookupStyle>single</LookupStyle>
          <LookupTypes />
          <displaynames>
            <displayname description=`"$AttributeDisplayName`" languagecode=`"1033`" />
          </displaynames>
          <Descriptions>
            <Description description=`"`" languagecode=`"1033`" />
          </Descriptions>
        </attribute>
      "
$xml.Save($entityXmlFilePath)

$relationshipsXmlFilePath = "$SolutionFolderPath\Other\Relationships.xml"
$xml.Load($relationshipsXmlFilePath)
$entityRelationshipsNode = $xml.SelectSingleNode("/EntityRelationships")
$entityRelationshipsNode.InnerXML +=
    $(if($entityRelationshipsNode.InnerXML.Length -eq 0) { "`r`n" }) +
    "  <EntityRelationship Name=`"$relationshipSchemaName`" />
"
$xml.Save($relationshipsXmlFilePath)

$entityRelationshipsXmlFilePath = "$SolutionFolderPath\Other\Relationships\$TargetEntityLogicalName.xml"
$xml.Load($entityRelationshipsXmlFilePath)
$entityRelationshipsNode = $xml.SelectSingleNode("/EntityRelationships")
$entityRelationshipsNode.InnerXML += 
    $(if($entityRelationshipsNode.InnerXML.Length -eq 0) { "`r`n" }) +
"  <EntityRelationship Name=`"$relationshipSchemaName`">
    <EntityRelationshipType>OneToMany</EntityRelationshipType>
    <IsCustomizable>1</IsCustomizable>
    <IntroducedVersion>1.0.0.0</IntroducedVersion>
    <IsHierarchical>0</IsHierarchical>
    <ReferencingEntityName>$EntityLogicalName</ReferencingEntityName>
    <ReferencedEntityName>$TargetEntityLogicalName</ReferencedEntityName>
    <CascadeAssign>NoCascade</CascadeAssign>
    <CascadeDelete>RemoveLink</CascadeDelete>
    <CascadeReparent>NoCascade</CascadeReparent>
    <CascadeShare>NoCascade</CascadeShare>
    <CascadeUnshare>NoCascade</CascadeUnshare>
    <CascadeRollupView>NoCascade</CascadeRollupView>
    <IsValidForAdvancedFind>1</IsValidForAdvancedFind>
    <ReferencingAttributeName>$attributeLogicalName</ReferencingAttributeName>
    <RelationshipDescription>
      <Descriptions>
        <Description description=`"`" languagecode=`"1033`" />
      </Descriptions>
    </RelationshipDescription>
    <EntityRelationshipRoles>
      <EntityRelationshipRole>
        <NavPaneDisplayOption>UseCollectionName</NavPaneDisplayOption>
        <NavPaneArea>Details</NavPaneArea>
        <NavPaneOrder>10000</NavPaneOrder>
        <NavigationPropertyName>$attributeLogicalName</NavigationPropertyName>
        <RelationshipRoleType>1</RelationshipRoleType>
      </EntityRelationshipRole>
      <EntityRelationshipRole>
        <NavigationPropertyName>$relationshipSchemaName</NavigationPropertyName>
        <RelationshipRoleType>0</RelationshipRoleType>
      </EntityRelationshipRole>
    </EntityRelationshipRoles>
  </EntityRelationship>
"
$xml.Save($entityRelationshipsXmlFilePath)

$targetEntityXmlPath = "$SolutionFolderPath\Entities\$TargetEntityLogicalName\Entity.xml"
$xml.Load($targetEntityXmlPath)
$targetEntityNameNode = $xml.SelectSingleNode("/Entity/Name")
$targetEntityDisplayName = $targetEntityNameNode.Attributes["LocalizedName"].Value

$solutionXmlFilePath = "$SolutionFolderPath\Other\Solution.xml"
$xml.Load($solutionXmlFilePath)
$missingDependenciesNode = $xml.SelectSingleNode("/ImportExportXml/SolutionManifest/MissingDependencies")
$missingDependenciesNode.InnerXML += 
    $(if($missingDependenciesNode.InnerXML.Length -eq 0) { "`r`n" }) +
"      <MissingDependency>
        <Required displayName=`"$entityDisplayName`" schemaName=`"$EntityLogicalName`" solution=`"MicrosoftPortalBase (9.2.2006.10)`" type=`"1`" />
        <Dependent displayName=`"$relationshipSchemaName`" parentDisplayName=`"$targetEntityDisplayName`" parentSchemaName=`"mdce_portal_module`" schemaName=`"$relationshipSchemaName`" type=`"10`" />
      </MissingDependency>
      <MissingDependency>
        <Required displayName=`"$entityDisplayName`" schemaName=`"$EntityLogicalName`" solution=`"MicrosoftPortalBase (9.2.2006.10)`" type=`"1`" />
        <Dependent displayName=`"$AttributeDisplayName`" parentDisplayName=`"$entityDisplayName`" parentSchemaName=`"$EntityLogicalName`" schemaName=`"$attributeLogicalName`" type=`"2`" />
      </MissingDependency>
      <MissingDependency>
        <Required displayName=`"$entityDisplayName`" schemaName=`"$EntityLogicalName`" solution=`"MicrosoftPortalBase (9.2.2006.10)`" type=`"1`" />
        <Dependent parentDisplayName=`"$entityDisplayName`" parentSchemaName=`"$EntityLogicalName`" schemaName=`"$($attributeLogicalName)name`" type=`"2`" />
      </MissingDependency>
    "
$xml.Save($solutionXmlFilePath)

if(-not $SkipSort)
{
    & $PSScriptRoot\..\doctoring\Sort-SolutionXmlFolder.ps1 $SolutionFolderPath
}
