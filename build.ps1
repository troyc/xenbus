#
# Main build script
#

param(
	[Parameter(Mandatory = $true)]
	[string]$Type,
	[switch]$Sdv
)

#
# Script Body
#

Function Build {
	param(
		[string]$Arch,
		[string]$Type
	)

	$visualstudioversion = $Env:VisualStudioVersion
	$solutiondir = @{ "14.0" = "vs2015"; "15.0" = "vs2017"; }
	$configurationbase = @{ "14.0" = "Windows 10"; "15.0" = "Windows 10"; }

	$params = @{
		SolutionDir = $solutiondir[$visualstudioversion];
		Arch = $Arch;
	}
	& ".\genfiles.ps1" @params

	$params = @{
		SolutionDir = $solutiondir[$visualstudioversion];
		ConfigurationBase = $configurationbase[$visualstudioversion];
		Arch = $Arch;
		Type = $Type
		}
	& ".\msbuild.ps1" @params

	$params = @{
		Arch = $Arch;
	}
	& ".\symstore.ps1" @params
}

Function SdvBuild {
	$visualstudioversion = $Env:VisualStudioVersion
	$solutiondir = @{ "14.0" = "vs2015"; "15.0" = "vs2017"; }
	$configurationbase = @{ "14.0" = "Windows 10"; "15.0" = "Windows 10"; }
	$arch = "x64"

	$params = @{
		SolutionDir = $solutiondir[$visualstudioversion];
		Arch = $arch;
	}
	& ".\genfiles.ps1" @params

	$params = @{
		SolutionDir = $solutiondir[$visualstudioversion];
		ConfigurationBase = $configurationbase[$visualstudioversion];
		Arch = $arch;
		Type = "sdv"
		}
	& ".\msbuild.ps1" @params
}

if ($Type -ne "free" -and $Type -ne "checked") {
	Write-Host "Invalid Type"
	Exit -1
}

Build "x86" $Type
Build "x64" $Type

if ($Sdv) {
	SdvBuild
}

if (Test-Path ".build_number") {
	$TheBuildNum = Get-Content -Path ".build_number"
	Set-Content -Path ".build_number" -Value ([int]$TheBuildNum + 1)
} else {
	Set-Content -Path ".build_number" -Value "1"
}