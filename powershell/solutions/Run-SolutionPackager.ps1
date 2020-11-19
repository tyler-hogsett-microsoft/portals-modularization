param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    [Parameter(Mandatory=$true)]
    [string]$ZipFile,
    [Parameter(Mandatory=$true)]
    [string]$PackageType,
    [Parameter(Mandatory=$true)]
    [string]$Folder
)

Set-Alias SolutionPackager $PSScriptRoot\..\nuget-tools\CoreTools\SolutionPackager.exe

SolutionPackager `
    /action:$Action `
    /zipfile:$ZipFile `
    /packagetype:$PackageType `
    /folder:$Folder `
    /useUnmanagedFileForMissingManaged