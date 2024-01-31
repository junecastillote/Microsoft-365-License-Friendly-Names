<#PSScriptInfo

.VERSION 1.2.2

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

.RELEASENOTES 2021-07-07 | v1.2.1 | performance tweeks by Maximilian Otter

#>

<#
.DESCRIPTION
 Get license IDs and friendly names directly from MS article in GitHub
.SYNOPSIS
    Get the friendly names from the Microft Document "Product names and service plan identifiers for licensing"
.DESCRIPTION
    This script downloads and parses the licensing-service-plan-reference.md file from GitHub and converts to a PowerShell object.
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1 | Export-Csv -NoTypeInformation .\m365-License-Reference.csv
    Get the product names and service plan identifiers online and export to CSV
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1
    Get the product names and service plan identifiers online and display the result on the screen
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1 -TitleCase
    Get the product names and service plan identifiers online and display the result on the screen. The friendly names will be convered to title case.
#>

[CmdletBinding()]
param (
    ## This is URL path to the the licensing reference table document from GitHub.
    ## The current working URL is the default value.
    ## In case Microsoft moved the document, use this parameter to point to the new URL.
    [parameter()]
    [string]
    $URL = 'https://raw.githubusercontent.com/MicrosoftDocs/entra-docs/main/docs/identity/users/licensing-service-plan-reference.md',

    ## Convert license names to title case.
    [parameter()]
    [switch]
    $TitleCase
)

$ErrorActionPreference = 'STOP'

#https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference

## Parse the Markdown Table from the $URL
try {
    [System.Collections.ArrayList]$raw_Table = ([System.Net.WebClient]::new()).DownloadString($URL).split("`n")
}
catch {
    Write-Output "There was an error getting the licensing reference table at [$URL]. Please make sure that the URL is still valid."
    Write-Output $_.Exception.Message
    return $null
}

## Determine the starting row index of the table
$startLine = $raw_Table.IndexOf('| Product name | String ID | GUID | Service plans included | Service plans included (friendly names) |')

## Determine the ending index of the table
$endLine = ($raw_Table.IndexOf('## Service plans that cannot be assigned at the same time') - 1)

## Extract the string in between the lines $startLine and $endLine
$result = for ($i = $startLine; $i -lt $endLine; $i++) {
    if ($raw_Table[$i] -notlike "*---*") {
        $raw_Table[$i].Substring(1, $raw_Table[$i].Length - 1)
    }
}

## Perform a little clean-up
### replace "[space] | [space]" with "|"
### replace "[space]<br/>[space]" with ","
### replace "((" with "("
### replace "))" with ")"
### #replace ")[space](" with ")("

$result = $result `
    -replace '\s*\|\s*', '|' `
    -replace '\s*<br/>\s*', ',' `
    -replace '\(\(', '(' `
    -replace '\)\)', ')' `
    -replace '\)\s*\(', ')('

## Create the result object
$result = @($result | ConvertFrom-Csv -Delimiter "|" -Header 'SkuName', 'SkuPartNumber', 'SkuID', 'ChildServicePlan', 'ChildServicePlanName')

if ($TitleCase) {

    ## Convert product name to title case
    $TextInfo = (Get-Culture).TextInfo
    for ($i = 0; $i -lt $result.Count; $i++) {
        $result[$i].SkuName = $TextInfo.ToTitleCase(($result[$i].SkuName).ToLower())
        $result[$i].ChildServicePlanName = $TextInfo.ToTitleCase(($result[$i].ChildServicePlanName).ToLower())
    }

}


## return the result
return $result
