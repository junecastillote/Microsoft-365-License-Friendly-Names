<#PSScriptInfo

.VERSION 1.4

.GUID 79801e88-d136-4955-8730-07ae1dd65cb1

.AUTHOR June Castillote

.COMPANYNAME june.castillote@gmail.com

.COPYRIGHT june.castillote@gmail.com

.TAGS Office 365 License, License Name, Friendly Name, Microsoft 365 License Name

.LICENSEURI https://github.com/junecastillote/Microsoft-365-License-Friendly-Names/blob/master/LICENSE

.PROJECTURI https://github.com/junecastillote/Microsoft-365-License-Friendly-Names

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES https://github.com/junecastillote/Microsoft-365-License-Friendly-Names/blob/master/release_notes.md

#>

<#
.DESCRIPTION
 Get license IDs and friendly names directly from MS article in GitHub
.SYNOPSIS
    Get the friendly names from the Microsoft Document "Product names and service plan identifiers for licensing"
.DESCRIPTION
    This script downloads and parses the licensing-service-plan-reference.md file from GitHub and converts to a PowerShell object.
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1
    Get the product names and service plan identifiers online and display the result on the screen
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1 | Export-Csv -NoTypeInformation .\m365-License-Reference.csv
    Get the product names and service plan identifiers and export to CSV.
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1 -SkuId 245e6bf9-411e-481e-8611-5c08595e2988
    Get the product names and service plan identifiers that matches the specified SkuId
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1 -SkuPartNumber SPE_E5
    Get the product names and service plan identifiers that matches the specified SkuPartNumber
.EXAMPLE
    PS C:\> .\Get-m365ProductIDTable.ps1 -ForceOnline
    Force to download the SKU table from the online source and ignoring the locally available table version.
#>

[CmdletBinding(DefaultParameterSetName = 'Default')]
param (
    ## This is URL path to the the licensing reference table document from GitHub.
    ## The current working URL is the default value.
    ## In case Microsoft moved the document, use this parameter to point to the new URL.
    [parameter()]
    [string]
    $URL = 'https://raw.githubusercontent.com/MicrosoftDocs/entra-docs/main/docs/identity/users/licensing-service-plan-reference.md',

    # Return only the matching SkuId
    [Parameter(ParameterSetName = 'SkuId', Mandatory)]
    [ValidateNotNullOrEmpty()]
    [guid]
    $SkuId,

    # Return only the matching SkuPartNumber
    [Parameter(ParameterSetName = 'SkuPartNumber', Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $SkuPartNumber,

    ## Force convert license names to title case.
    [parameter()]
    [switch]
    $TitleCase,

    ## Force to download the online version instead of checking table in the current session
    [parameter()]
    [switch]
    $ForceOnline,

    ## Specifiy the list delimiter for ChildServicePlan and ChildServicePlanName.
    ## Default character delimited is comma ","
    [parameter()]
    [string]
    $ListDelimiterCharacter
)

function ShowResult {
    $visible_properties = [string[]]@('SkuName', 'SkuPartNumber', 'SkuId')
    [Management.Automation.PSMemberInfo[]]$default_properties = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', $visible_properties )
    $Global:SkuTable | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $default_properties -Force

    switch ($PSCmdlet.ParameterSetName) {
        SkuId {
            Write-Verbose "Filtering by SkuId"
            $Global:SkuTable | Where-Object { $_.SkuId -eq $SkuId }
        }
        SkuPartNumber {
            Write-Verbose "Filtering by SkuPartNumber"
            $Global:SkuTable | Where-Object { $_.SkuPartNumber -eq $SkuPartNumber }
        }
        default {
            Write-Verbose "No filtering. Showing all results."
            $Global:SkuTable
        }
    }
}

$ErrorActionPreference = 'STOP'

if ($ForceOnline) { $Global:SkuTable = @() }

#https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference

# Check first if the SKU table is already available in the session. This ensures that the script only downloads the online table once per session, unless the -ForceOnline switch is used.
if ($Global:SkuTable) {
    Write-Verbose "SKU table exists in session."
    return ShowResult
}
else {
    Write-Verbose "Downloading SKU table online..."

    ## Parse the Markdown Table from the $URL
    try {
        $raw_Table = Invoke-RestMethod -Uri $URL -ErrorAction Stop
        $raw_Table = $raw_Table -split "`n"
    }
    catch {
        Write-Output "There was an error getting the licensing reference table at [$URL]. Please make sure that the URL is still valid."
        Write-Output $_.Exception.Message
        return $null
    }

    ## Determine the starting row index of the table
    $startLine = ($raw_Table.IndexOf('| Product name | String ID | GUID | Service plans included | Service plans included (friendly names) |') + 1)

    ## Determine the ending index of the table
    $endLine = ($raw_Table.IndexOf('## Service plans that cannot be assigned at the same time') - 1)

    ## Extract the string in between the lines $startLine and $endLine
    $result = for ($i = $startLine; $i -lt $endLine; $i++) {
        if ($raw_Table[$i] -notlike "*---*") {
            $raw_Table[$i].Substring(1, $raw_Table[$i].Length - 1)
        }
    }

    ## Perform a little clean-up
    ## replace "[space] | [space]" with "|"
    ## replace "[space]<br/>[space]" with ","
    ## replace "((" with "("
    ## replace "))" with ")"
    ## #replace ")[space](" with ")("

    $result = $result `
        -replace '\s*\|\s*', '|' `
        -replace '\s*<br/>\s*', ',' `
        -replace '\(\(', '(' `
        -replace '\)\)', ')' `
        -replace '\)\s*\(', ')('

    # Force title case conversion if -TitleCase is not used.
    if (-not $PSBoundParameters.ContainsKey('TitleCase')) {
        $TitleCase = $true
        Write-Verbose "TitleCase name conversion enabled"
    }

    ## Create the result object
    $TextInfo = (Get-Culture).TextInfo

    # Set "," (comma) as the default delimiter character for ChildServicePlan and ChildServicePlanName
    if (-not $ListDelimiterCharacter) { $ListDelimiterCharacter = "," }
    $Global:SkuTable = @($result | ConvertFrom-Csv -Delimiter "|" -Header 'SkuName', 'SkuPartNumber', 'SkuID', 'ChildServicePlan', 'ChildServicePlanName' | ForEach-Object {


            if ($ListDelimiterCharacter -ne ",") {
                $childServicePlan = (([string]$_.ChildServicePlan).Split(",") | Sort-Object) -join $ListDelimiterCharacter
                $childServicePlanName = (([string]$_.ChildServicePlanName).Split(",") | Sort-Object) -join $ListDelimiterCharacter
            }
            else {
                $childServicePlan = $_.ChildServicePlan
                $childServicePlanName = $_.ChildServicePlanName
            }

            [pscustomobject]@{
                SkuName              = if ($TitleCase) { $TextInfo.ToTitleCase($_.SkuName) } else { $_.SkuName }
                SkuPartNumber        = $_.SkuPartNumber
                SkuId                = [guid]$_.SkuId
                ChildServicePlan     = $childServicePlan
                ChildServicePlanName = if ($TitleCase) { $TextInfo.ToTitleCase($childServicePlanName) } else { $childServicePlanName }
            }
        })

    ## return the result
    return ShowResult
}