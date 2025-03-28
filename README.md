# Microsoft 365 License Friendly Names

Get license IDs and friendly names directly from MS article source in GitHub that Microsoft maintains.

## How to Get

**Option 1** - [Download](https://github.com/junecastillote/Microsoft-365-License-Friendly-Names/archive/refs/heads/master.zip) or [Clone](https://github.com/junecastillote/Microsoft-365-License-Friendly-Names.git) the script from this repository.

**Option 2** - Install from [PowerShell Gallery](https://www.powershellgallery.com/packages/Get-m365ProductIDTable).

```PowerShell
Install-Script -Name Get-m365ProductIDTable
```

## Example 1: Get the Product Names and Service Plan Identifiers Online

```PowerShell
.\Get-m365ProductIDTable.ps1
```

![Example 1](img/Example1.png)

## Example 2: Get the Product Names and Service Plan Identifiers Online and Convert Names to Title Case

```PowerShell
.\Get-m365ProductIDTable.ps1 -TitleCase
```

![Example 2](img/Example2.png)

## Example 3: Get the Product Names and Service Plan Identifiers Online, Convert Names to Title Case, and Export to CSV

```PowerShell
.\Get-m365ProductIDTable.ps1 -TitleCase | Export-Csv -NoTypeInformation -Path .\m365ProductIDTable.csv
```

![Example 1](img/Example3.png)
