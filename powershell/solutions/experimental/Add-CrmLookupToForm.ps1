param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionFolderPath,
    [Parameter(Mandatory=$true)]
    [string]$EntityLogicalName,
    [Parameter(Mandatory=$true)]
    [string]$AttributeLogicalName,
    [Parameter(Mandatory=$true)]
    [string]$AttributeDisplayName,
    [Parameter(Mandatory=$true)]
    [string]$TabDisplayName,
    [Parameter(Mandatory=$true)]
    [string]$SectionDisplayName
)

$sectionLogicalName = ($SectionDisplayName.ToLower() -Replace " ", "_")

$xml = New-Object xml
$xml.PreserveWhitespace = $true

$formXmlFiles = (Get-Item "$SolutionFolderPath\Entities\$EntityLogicalName\FormXml\main\*.xml")
$formXmlFiles | ForEach-Object {
    $formXmlFilePath = $_.FullName
    $xml.Load($formXmlFilePath)

    $systemFormXmlNode = $xml.SelectSingleNode("/forms/systemform")
    $systemFormXmlNode.RemoveAttribute("unmodified")

    $tabsXmlNode = $xml.SelectSingleNode("/forms/systemform/form/tabs")
    $tabsXmlNode.ChildNodes | ForEach-Object {
      if($_ -ne $null) {
        $tabMatchesName = $_.SelectSingleNode("child::labels/label[@description='$TabDisplayName']") -ne $null
        if($tabMatchesName) {
          $tabXmlNode = $_
        }
      }
    }

    if($tabXmlNode -eq $null) {
      $tabUniqueName = "tab_$($TabDisplayName.ToLower() -Replace " ", "_")"
      $tabsXmlNode.InnerXML +=
     "  <tab expanded=`"true`" id=`"{$([Guid]::NewGuid())}`" IsUserDefined=`"0`" locklevel=`"0`" name=`"$tabUniqueName`" showlabel=`"true`">
          <labels>
            <label description=`"$TabDisplayName`" languagecode=`"1033`" />
          </labels>
          <columns>
            <column width=`"100%`">
              <sections></sections>
            </column>
          </columns>
        </tab>
      "
      $tabXmlNode = $tabsXmlNode.ChildNodes[$tabsXmlNode.ChildNodes.Count - 1]
    }
    $sectionsXmlNode = $tabXmlNode.SelectSingleNode("child::columns/column/sections")
    $sectionsXmlNode.InnerXML +=
        $(if($sectionsXmlNode.InnerXML.Length -eq 0) { "`r`n              " }) +
              "  <section celllabelalignment=`"Left`" celllabelposition=`"Left`" columns=`"1`" id=`"{$([Guid]::NewGuid())}`" IsUserDefined=`"0`" labelwidth=`"115`" layout=`"varwidth`" locklevel=`"0`" name=`"section_$sectionLogicalName`" showbar=`"false`" showlabel=`"false`">
                  <labels>
                    <label description=`"$SectionDisplayName`" languagecode=`"1033`" />
                  </labels>
                  <rows>
                    <row>
                      <cell id=`"{$([Guid]::NewGuid())}`" locklevel=`"0`">
                        <labels>
                          <label description=`"$AttributeDisplayName`" languagecode=`"1033`" />
                        </labels>
                        <control classid=`"{270BD3DB-D9AF-4782-9025-509E298DEC0A}`" datafieldname=`"$AttributeLogicalName`" disabled=`"false`" id=`"$AttributeLogicalName`" />
                      </cell>
                    </row>
                  </rows>
                </section>
              "

    $xml.Save($formXmlFilePath)
}