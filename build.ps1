param (
    [ValidateSet("Release", "Debug")]
	[string]$Configuration = "Release",
	[string]$VisualStudioVersion = '14.0',
    [ValidateSet("Quiet", "Minimal", "Normal", "Verbose", "Diagnostic")]
	[string]$Verbosity = 'normal'
)

$ToolsDir = Join-Path $PSScriptRoot "tools"
$NuGet = Join-Path $ToolsDir "nuget.exe"
$SrcDir = Join-Path $PSScriptRoot "src"
$SolutionPath = Join-Path $SrcDir "PLSQL.Parser.sln"
 
#download NuGet.exe if necessary
If (-not (Test-Path $NuGet)) {
	If (-not (Test-Path 'tools')) {
		mkdir 'tools'
	}

	$nugetSource = 'http://nuget.org/nuget.exe'
	Invoke-WebRequest $nugetSource -OutFile $NuGet
	If (-not $?) {
		$host.ui.WriteErrorLine('Unable to download NuGet executable, aborting!')
		exit $LASTEXITCODE
	}
}   

Push-Location
Set-Location $ToolsDir
Invoke-Expression "$NuGet install -ExcludeVersion"
Pop-Location
if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

# build the main project
$msbuild = "${env:ProgramFiles(x86)}\MSBuild\$VisualStudioVersion\Bin\MSBuild.exe"

# Attempt to restore packages up to 3 times, to improve resiliency to connection timeouts and access denied errors.
$maxAttempts = 3
For ($attempt = 0; $attempt -lt $maxAttempts; $attempt++) {
	&$NuGet 'restore' $SolutionPath
	If ($?) {
		Break
	} ElseIf (($attempt + 1) -eq $maxAttempts) {
		$host.ui.WriteErrorLine('Failed to restore required NuGet packages, aborting!')
		exit $LASTEXITCODE
	}
}

&$msbuild '/nologo' '/m' '/nr:false' '/t:rebuild' "/verbosity:$Verbosity" "/p:Configuration=$Configuration" "/p:VisualStudioVersion=$VisualStudioVersion" $SolutionPath
If (-not $?) {
	$host.ui.WriteErrorLine('Build failed, aborting!')
	exit $LASTEXITCODE
}