# Checkmarx SAST Scan Log Parser
Takes a SAST scan log file or a Checkmarx One Scan ID as an input and opens an Excel document with parsed details from the SAST log file.

When a Scan ID is used additional details will be sourced from Checkmarx One including preset, branch name, origin and other data

Has seperate tabs for 
 - General Details
 - Engine Configuration
 - Predefined File Exclusions
 - Phases
 - Files Processed
 - Results Summary
 - General Queries
 - Errors

## Notes: 
- The CXOneAPIModule folder needs to be placed into the same location as the script in order to use the Scan ID function
- Excel created is not saved and must be manually saved if required

## Versions:
- The ScanLogParser works on only on Windows machines with Excel installed. It contains full functionality
- The ScanLogParser-ImportExcel uses the Powershell ImportExcel Module and can run on any system with Powershell available
  - This version requires the ImportExcel Module to be installed before the first run
  - only has the option to parse log a file using the logPath parameter

## Usage - ScanLogParser
### Help
    .\ScanLogParser.ps1 -help [<CommonParameters>]
    
### Parse Log File
    .\ScanLogParser.ps1 [-logPath <string>] [<CommonParameters>]

### Parse Log from Checkmarx One Scan ID
    .\ScanLogParser.ps1 [-scanId <string>] [-silentLogin -apiKey <string] [<CommonParameters>]

## Usage - ScanLogParser-ImportExcel
### Help
    .\ScanLogParser.ps1 -help [<CommonParameters>]
    
### Parse Log File
    .\ScanLogParser.ps1 -logPath <string> [<CommonParameters>]

## Parameters
__PARAMETER help__  
Display help

__PARAMETER logPath__  
The file path for the Scan Log to be processed. Use when parsing a downloaded log file

__PARAMETER scanId__  
A Checkmarx One Scan ID which will be used to retrieve the SAST log

__PARAMETER silentLogin__  
Log into Checkmarx One using a provided API Key. Is optional and if not used a prompt will appear for the key

__PARAMETER apiKey__  
The API Key used to log into Checkamrx One. Is mandatory with silentLogin
