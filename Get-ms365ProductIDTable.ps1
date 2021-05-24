<#PSScriptInfo

.VERSION 1.1

.GUID 79801e88-d136-4955-8730-07ae1dd65cb1

.AUTHOR June Castillote

.COMPANYNAME june.castillote@gmail.com

.COPYRIGHT june.castillote@gmail.com

.TAGS Office365 License Friendly

.LICENSEURI https://github.com/junecastillote/Microsoft-365-License-Friendly-Names/blob/master/LICENSE

.PROJECTURI https://github.com/junecastillote/Microsoft-365-License-Friendly-Names

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

<#
.DESCRIPTION
 Get license IDs and friendly names directly from MS article in GitHub
.SYNOPSIS
    Get the friendly names from the Microft Document "Product names and service plan identifiers for licensing"
.DESCRIPTION
    This script downloads and parses the licensing-service-plan-reference.md file from GitHub and converts to a PowerShell object.
.EXAMPLE
    PS C:\> .\Get-ms365ProductIDTable.ps1 | Export-Csv -NoTypeInformation .\O365-License-Reference.csv
    Get the product names and service plan identifiers online and export to CSV
.EXAMPLE
    PS C:\> .\Get-ms365ProductIDTable.ps1
    Get the product names and service plan identifiers online and display the result on the screen
#>

[CmdletBinding()]
param (

)

$ErrorActionPreference = 'STOP'

## This is URL path to the the licensing reference table document from GitHub
[string]$URL = 'https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/master/articles/active-directory/enterprise-users/licensing-service-plan-reference.md'

#https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference

## Download the string value of the MD file
try {
    [System.Collections.ArrayList]$raw_Table = ((New-Object System.Net.WebClient).DownloadString($URL) -split "`n")
}
catch {
    Write-Output "There was an error getting the licensing reference table online.`n$($_.Exception.Message)"
    break;
}

## Determine the starting row index of the table
$startLine = $raw_Table.IndexOf('| Product name | String ID | GUID | Service plans included | Service plans included (friendly names) |')

## Determine the ending index of the table
$endLine = ($raw_Table.IndexOf('## Service plans that cannot be assigned at the same time') - 1)

## Extract the string in between the lines $startLine and $endLine
$result = @()
for ($i = $startLine; $i -lt $endLine; $i++) {
    if ($raw_Table[$i] -notlike "*---*") {
        $result += ($raw_Table[$i].Substring(1, $raw_Table[$i].Length - 1))
    }
}

## Perform a little clean-up
$result = $result `
    -replace '\s*\|\s*', '|' `
    -replace '\s*<br/>\s*', ';' `
    -replace '\(\(', '(' `
    -replace '\)\)', ')' `
    -replace '\)\s*\(', ')('

## Create the result object
$result = @($result | ConvertFrom-Csv -Delimiter "|" -Header 'LicenseName', 'LicenseString', 'LicenseGUID', 'ServicePlans', 'ServicePlansFriendlyNames')

## Convert product name to title case
$TextInfo = (Get-Culture).TextInfo
$i=0
$result | ForEach-Object {
    $result[$i].LicenseName = $TextInfo.ToTitleCase(($PSItem.LicenseName).ToLower())
    $i++
}

## return the result
return $result