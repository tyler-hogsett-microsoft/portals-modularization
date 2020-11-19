param(
  [Parameter(Mandatory=$true)]
  [string]$SolutionFolderPath
)

$solutionFilePath = "$SolutionFolderPath\Other\solution.xml"

$solutionXml = New-Object xml
$solutionXml.PreserveWhitespace = $true
$solutionXml.Load($solutionFilePath)

$managedProperty = $solutionXml.SelectSingleNode("/ImportExportXml/SolutionManifest/Managed")
$managedProperty.InnerXML = "2"

$solutionXml.Save($solutionFilePath)