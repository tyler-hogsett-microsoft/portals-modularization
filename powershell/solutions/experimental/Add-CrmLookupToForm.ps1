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
    [string]$SectionDisplayName
)

$sectionLogicalName = ($SectionDisplayName.ToLower() -Replace " ", "_")

$xml = New-Object xml
$xml.PreserveWhitespace = $true

$formXmlFilePath = (Get-Item "$SolutionFolderPath\Entities\$EntityLogicalName\FormXml\main\*.xml")[0].FullName
$xml.Load($formXmlFilePath)

$sectionsXmlNode = $xml.SelectSingleNode("/forms/systemform/form/tabs/tab/columns/column/sections")
$sectionsXmlNode.InnerXML +=
    $(if($sectionsXmlNode.InnerXML.Length -eq 0) { "`r`n" }) +
"  <section celllabelalignment=`"Left`" celllabelposition=`"Left`" columns=`"1`" id=`"$([Guid]::NewGuid())`" IsUserDefined=`"0`" labelwidth=`"115`" layout=`"varwidth`" locklevel=`"0`" name=`"$sectionLogicalName`" showbar=`"false`" showlabel=`"false`">
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