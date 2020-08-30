<#
.SYNOPSIS
    Get the friendly names from the Microft Document "Product names and service plan identifiers for licensing"
.DESCRIPTION
    This script downloads and parses the licensing-service-plan-reference.md file from GitHub and convert to a PowerShell object.
.EXAMPLE
    PS C:\> .\Get-ms365ProductIDTable.ps1 | Export-Csv -NoTypeInformation .\O365-License-Reference.csv
    Get the product names and service plan identifiers online and export to CSV
.INPUTS

.OUTPUTS

.NOTES

#>
[CmdletBinding()]
    param (

    )

    ## This is the licensing reference table document from GitHub
    [string]$URL = 'https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/master/articles/active-directory/users-groups-roles/licensing-service-plan-reference.md'

    ## Download the string value of the MD file
    [System.Collections.ArrayList]$raw_Table = ((New-Object System.Net.WebClient).DownloadString($URL) -split "`n")

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
    $result = ($result | ConvertFrom-Csv -Delimiter "|" -Header 'LicenseName','LicenseString','LicenseGUID','ServicePlans','ServicePlansFriendlyNames')

    return $result