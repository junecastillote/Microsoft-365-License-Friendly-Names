# Microsoft 365 License Friendly Names

Get license IDs and friendly names directly from MS article source in GitHub that Microsoft maintains.

## How to Get

**Option 1** - [Download](https://github.com/junecastillote/Microsoft-365-License-Friendly-Names/archive/refs/heads/master.zip) or [Clone](https://github.com/junecastillote/Microsoft-365-License-Friendly-Names.git) the script from this repository.

**Option 2** - Install from [PowerShell Gallery](https://www.powershellgallery.com/packages/Get-m365ProductIDTable).

```PowerShell
Install-Script -Name Get-m365ProductIDTable
```

## Example 1: Get the Product Names and Service Plan Identifiers Online

> Note: The first run will store the Product Names and Service Plan Identifiers in memory, so subsequent calls will be done offline.

```PowerShell
.\Get-m365ProductIDTable.ps1
```

```PlainText
SkuName                                                    SkuPartNumber                                      SkuId
-------                                                    -------------                                      -----
10-Year Audit Log Retention Add On                         10_ALR_ADDON                                       c2e41e49-e2a2-4c55-832a-cf13ffba1d6a
Advanced Communications                                    ADV_COMMS                                          e4654015-5daf-4a48-9b37-4f309dddd88b
AI Builder Capacity Add-On                                 CDSAICAPACITY                                      d2dea78b-507c-4e56-b400-39447f4738f8
App Connect IW                                             SPZA_IW                                            8f0c5670-4e56-4892-b06d-91c085d7004f
App Governance Add-On To Microsoft Defender For Cloud Apps Microsoft_Cloud_App_Security_App_Governance_Add_On 9706eed9-966f-4f1b-94f6-bb2b4af99a5b
Microsoft 365 Audio Conferencing                           MCOMEETADV                                         0c266dff-15dd-4b49-8397-2bb16070ed52
Microsoft 365 Audio Conferencing For Faculty               MCOMEETADV_FACULTY                                 c2cda955-3359-44e5-989f-852ca0cfa02f
Microsoft Entra Basic                                      AAD_BASIC                                          2b9c8e7c-319c-43a2-a2a0-48c5c6161de7
Microsoft Entra ID P1                                      AAD_PREMIUM                                        078d2b04-f1bd-4111-bbd4-b4b1b354cef4
Microsoft Entra ID P1 For Faculty                          AAD_PREMIUM_FACULTY                                30fc3c36-5a95-4956-ba57-c09c2a600bb9
```

## Example 2: Get the Product Names and Service Plan Identifiers Online and Force a Fresh Online Lookup

```PowerShell
.\Get-m365ProductIDTable.ps1 -ForceOnline
```

## Example 3: Get the Product Names and Service Plan Identifiers Online and Export to CSV

```PowerShell
.\Get-m365ProductIDTable.ps1 | Export-Csv -NoTypeInformation -Path .\m365ProductIDTable.csv
```

![Example 1](img/Example3.png)
