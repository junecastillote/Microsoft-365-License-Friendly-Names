# Release Notes

## v1.4 (2025-08-28)

- Added the `-SkuPartNumber` parameter.
  - Return only the matching SkuPartNumber
- Added a DefaultDisplayPropertySet to show only 'SkuName', 'SkuPartNumber', 'SkuId' by default.
- Forced `-TitleCase` value to `$true` if not specified.
- Replace `System.Net.WebClient` with `Invoke-RestMethod` native cmdlet.
- Added `-ListDelimiterCharacter` parameter to customize how the `ChildServicePlan` and `ChildServicePlan` list is delimited.
  - If not specified, the default delimiter is comma `,`

## v1.3 (2025-03-29)

- Added the `-SkuId [GUID]` parameter.
  - Return only the matching SkuId
- Added the `-ForceOnline` switch.
  - Forces the script to download the table from the online source.
- The SKU table is downloaded once in the session, unless the `-ForceOnline` switch is used.

## v1.2.1 (2021-07-07)

- Performance tweeks by Maximilian Otter.
