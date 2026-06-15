#--------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Help

<#
.Synopsis
Opens an Excel file with the Parsed results of a SAST Scan Log 

.Description
Takes a scan log file as an input and opens an excel with parsed details from the log file
Has tabs for General Details, Engine Configuration, Predefined File Exclusions, Phases, Files, Results Summary and General Queries

This script requires the ImportExcel module. You will need to install this before using the script using the following command
      Install-Module -Name ImportExcel -Scope CurrentUser

NOTE: Excel created is not saved and must be manually saved if required

Usage
Help
    .\ScanLogParserMac.ps1 -help [<CommonParameters>]
    
Parse Log File
    .\ScanLogParserMac.ps1 [-logPath <string>] [<CommonParameters>]

.Notes
Version:     1.0
Date:        15/06/2026
Written by:  Michael Fowler
Contact:     michael.fowler@checkmarx.com

Change Log
Version    Detail
-----------------
1.0        Original Version

  
.PARAMETER help
Display help

.PARAMETER logPath
The file path for the Scan Log to be processed. Use when providing a downloaded log file

#>

#endregion
#--------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Parameters

[CmdletBinding(DefaultParametersetName='File')] 
Param (

    [Parameter(ParameterSetName='Help',Mandatory=$true, HelpMessage="Display help")]
    [switch]$help,

    [Parameter(ParameterSetName='File',Mandatory=$true, HelpMessage="Enter Full path for scan log")]
    [string]$logPath
)

#endregion
#--------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Begin

Begin {

    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Global Variables

    $summary = [System.Collections.Generic.List[ResultsSummary]]::New()
    $general = [System.Collections.Generic.List[GeneralQuery]]::New()
    $files = [System.Collections.Generic.List[File]]::New()
    $predefinedExclusions = [System.Collections.Generic.List[Exclusion]]::New()
    $excludeFiles = [System.Collections.Generic.List[String]]::New()
    $phases = [System.Collections.Generic.List[Phase]]::New()
    $details = [LogDetails]::new()
    $errors = [System.Collections.Generic.List[Error]]::New()
    $config = @{}
    $excelPath = "$env:TEMP\ScanLogAnalysis_$(Get-Date -Format 'yyyyMMdd_HHmmss').xlsx"

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Results Summary Class

    class ResultsSummary {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

        [String]$Query
        [String]$Severity
        [String]$Status
        [Int]$Results
        [Nullable[TimeSpan]]$Duration
        [String]$Cwe

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors
        
        ResultsSummary ([String] $line) {

            $line -match "(.*)\s{2,}Severity:\s(.*)\s{2,}(\D+)Results:\s(.*)\s{1,}Duration\s=\s(\d\d:\d\d:\d\d\.\d\d\d)\s{2,}(.*)\s{2,}CxDescrip.ion.*"
            $this.Query = $Matches[1]
            $this.Severity = $Matches[2]
            $this.Status = $Matches[3]
            $this.Results = $Matches[4]
            try { $this.Duration = [TimeSpan]::ParseExact($Matches[5], "hh\:mm\:ss\.fff", $null) }
            catch {}
            $this.Cwe = $Matches[6]
        }
        
        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------
    }
    
    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Error Class
    
    class Error {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

        [Int]$Line
        [Nullable[DateTime]]$DateTime
        [String]$Location
        [String]$Message

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors
        
        Error ([String]$line, [int]$lineNum) {

            $this.Line = $lineNum + 1
            $line -match "(\d\d/\d\d/\d\d\d\d\s\d\d:\d\d:\d\d,\d\d\d\s)(\[.*\])\sERROR(.*)"
            $this.DateTime = [DateTime]::ParseExact($Matches[1].Trim(), "dd/MM/yyyy HH\:mm\:ss,fff", $null)
            $this.Location = $Matches[2]
            $this.Message = $Matches[3].Trim()

        }
        
        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------
    }
    
    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region General Query Class

    class GeneralQuery {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

        [String]$Query
        [String]$Status
        [Int]$Results
        [Nullable[TimeSpan]]$Duration

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors

        GeneralQuery ([String] $line) {
            $out = $line -split "\s{2,}"
            $this.Query = $out[0].Trim()
            $this.Status = $out[1].Trim()
            $this.Results = $out[2].Trim()
            try { $this.Duration = [TimeSpan]::ParseExact($out[3].Trim(), "hh\:mm\:ss\.fff", $null) }
            Catch {}
        }

        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------
    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Log Details Class

    class LogDetails {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

            [Nullable[datetime]]$Start
            [Nullable[datetime]]$End
            [Nullable[TimeSpan]]$Runtime
            [String]$Version
            [Int]$ProcessorCount
            [String]$AvailableMemory
            [String]$ProjectName
            [String]$ProjectId
            [bool]$IncrementalScan = $false
            [Int]$IncrementalFilesChanged
            [Int]$IncrementalFilesClosure
            [String]$IdentifiedFiles
            [String]$ScannedLanguages
            [String]$NotScannedLanguages
            [String]$MultiLanguageMode
            [String]$RelativePath
            [Int]$ExcludeFiles
            [Int]$PredefinedExclusions 
            [Int]$TotalFiles
            [Int]$GoodFiles
            [Int]$PartiallyGoodFiles
            [Int]$BadFiles
            [Int]$ParsedLOC
            [Int]$GoodLOC
            [Int]$BadLOC
            [String]$ScanCoverage
            [String]$ScanCoverageLOC

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors

            LogDetails() { }

        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------
    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region File Class

    class File {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

        [Nullable[datetime]]$Start
        [Nullable[datetime]]$End
        [Nullable[TimeSpan]]$Runtime
        [String]$FileName

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors

        File([String] $startLine, [String]$finishLine, [String]$fileName) {      
            $this.FileName = $fileName
            $this.Start = [datetime]::parseexact($startLine.substring(0,23), 'dd/MM/yyyy HH:mm:ss,FFF', $null)
            if (-NOT [String]::IsNullOrEmpty($finishLine)) {
                $this.End = [datetime]::parseexact($finishLine.substring(0,23), 'dd/MM/yyyy HH:mm:ss,FFF', $null)
                $this.Runtime = New-TimeSpan -Start $this.Start -End $this.End
            }
        }

        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------
    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Phase Class

    class Phase {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

        [Nullable[datetime]]$Start
        [Nullable[datetime]]$End
        [Nullable[TimeSpan]]$Runtime
        [String]$PhaseName

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors

        Phase([String] $startLine, [String]$finishLine, [String]$phaseName) {      
            $this.PhaseName = $phaseName
            $this.Start = [datetime]::parseexact($startLine.substring(0,23), 'dd/MM/yyyy HH:mm:ss,FFF', $null)
            if (-NOT [String]::IsNullOrEmpty($finishLine)) {
                $this.End = [datetime]::parseexact($finishLine.substring(0,23), 'dd/MM/yyyy HH:mm:ss,FFF', $null)
                $this.Runtime = New-TimeSpan -Start $this.Start -End $this.End
            }
        }

        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------
    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Exclusion Class

    class Exclusion {
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Variables

        [String]$Reason
        [String]$File

        #endregion    
        #------------------------------------------------------------------------------------------------------------------------------------------------------
        #region Constructors

        Exclusion([String]$reason, [String]$file) {
            $this.Reason = $reason
            $this.File = $file
        }

        #endregion
        #------------------------------------------------------------------------------------------------------------------------------------------------------

    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Common Functions

    Function Parse-LogFile {
        Param (
            [Array]$lines
        )  

        Write-Verbose "Parsing log file" 
      
        for ($i = 0; $i -lt $lines.Count; $i++) {
   
            #Start time
            if ($i -eq 0) { $details.Start = [datetime]::parseexact($lines[$i].substring(0,23), 'dd/MM/yyyy HH:mm:ss,FFF', $null) }

            #Version
            if ($i -eq 1 -and $lines[$i].Length -gt 17) { $details.Version = $lines[$i].substring(17,7) }

            #Available Memory
            if ($lines[$i] -match "^Used memory: (.*)") { $details.AvailableMemory = $Matches[1] }

            #Processor Count
            if ($lines[$i] -match "^Processor Count: (.*)") { $details.ProcessorCount = $Matches[1] }

            if ($lines[$i] -cmatch "\d\d/\d\d/\d\d\d\d\s\d\d:\d\d:\d\d,\d\d\d\s\[.*\]\sERROR.*") { $errors.Add([Error]::new($lines[$i], $i)) }
            
            #Current Engine Configuration
            if ($lines[$i] -match "Current Engine Configuration from Application") {
                $i += 2
                while (-NOT [String]::IsNullOrEmpty($lines[$i].Trim())) {
                    $values = $lines[$i] -split "="
                    if ($values -eq 2) { $config[$values[0]] = $null }
                    else { $config[$values[0]] = $values[1] }
                    $i++
                }
            }
        
            #Incremental Scan, Files changed, Closure Files
            if ($lines[$i]-match "(Incremental Scan: number of files changed: )(\d+)(.*)") { 
                $details.IncrementalScan = $true
                $details.IncrementalFilesChanged = $Matches[2]
                while ($lines[++$i] -notmatch "Incremental Scan") {}
                $lines[$i]-match "(Incremental Scan: number of files in closure: )(\d+)(.*)"
                $details.IncrementalFilesClosure = $Matches[2]
            }
            
            #Solution Relative Path
            if ($lines[$i]-match "(Solution relative path is: ')(.*)(')") { $details.RelativePath = $Matches[2] }

            #Excluded files count
            if ($lines[$i] -match "Number of exclude files =([0-9]+)") { 
                $details.ExcludeFiles = $Matches[1]
                if ($details.ExcludeFiles -gt 0) {
                    $i++
                    while (-NOT ([String]::IsNullOrEmpty($lines[++$i].Trim()))) {
                        $excludeFiles.Add($lines[$i].Replace($details.RelativePath,""))
                    }
                }
            }

            if ($lines[$i] -match "Begin Predefined File Exclusions") { 
                while ($lines[++$i] -notmatch "Number of excluded files") {
                    $lines[$i] -match "\[Resolving\] - (.*):(.*)" | Out-Null
                    $predefinedExclusions.Add([Exclusion]::new($Matches[1],$Matches[2]))
                }
                $lines[$i] -match "Number of excluded files: ([0-9]+)" | Out-Null
                $details.PredefinedExclusions = $Matches[1]
            }

            #Identified Files
            if ($lines[$i] -match "The following source files were identified: (.*)") { $details.IdentifiedFiles = $Matches[1] }
            
            #Scanned Languages
            if ($lines[$i] -match "Languages that will be scanned: (.*)") { $details.ScannedLanguages = $Matches[1] }

            #Languages Identified but not scanned
            if ($lines[$i] -match "All languages identified but not scanned: (.*)") { $details.NotScannedLanguages = $Matches[1] }

            #Multi-Language Mode
            if ($lines[$i] -match "MULTI_LANGUAGE_MODE is set") { $details.MultiLanguageMode = $lines[$i] }

            #Project Name and ID
            if ($lines[$i] -match "(Scan Details: ProjectId=')(.*)(',ProjectName=')(.*)(')") { 
                $details.ProjectId = $Matches[2]
                $details.ProjectName = $Matches[4] 
            }

            #Parsed Files
            if ($lines[$i] -match "Started processing file: (.*)") {
                $j = $i + 1
                $add = $true
                $fileName = $Matches[1].Replace($details.RelativePath,"")
                $fileMatch = $Matches[1].Replace("\", "\\")
                # Loop to find completion of file processing. Exit if end of file
                while (-NOT ($lines[$j] -match $fileMatch)) { 
                    if (++$j -eq ($lines.Count - 1)) { 
                        $files.add([File]::new($lines[$i], $null, $fileName))
                        $add = $false
                        break
                    }
                }
                if ($add) { $files.add([File]::new($lines[$i], $lines[$j], $fileName)) }
            }

            #Processing Phases
            if ($lines[$i] -match "Engine Phase \(Start\): (.*)") {
                $j = $i + 1
                $add = $true
                $phaseName = $Matches[1]
                # Loop to find completion of phase processing. Exit if end of file
                while (-NOT ($lines[$j] -match "Engine Phase \( End \): $phaseName")) { 
                    if (++$j -eq ($lines.Count - 1)) { 
                        $phases.add([Phase]::new($lines[$i], $null, $phaseName)) 
                        $add = $false
                        break
                    }
                }
                if ($add) { $phases.add([Phase]::new($lines[$i], $lines[$j], $phaseName)) }
            }

            #Parsing Summary
            if($lines[$i] -match "^---------------------------$") {
                while (-NOT ([String]::IsNullOrEmpty($lines[++$i].Trim()))) {
                    if ($lines[$i] -match "^Total files(.*)") { $details.TotalFiles = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Good files:(.*)") { $details.GoodFiles = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Partially good files:(.*)") { $details.PartiallyGoodFiles = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Bad files:(.*)") { $details.BadFiles = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Parsed LOC:(.*)") { $details.ParsedLOC = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Good LOC:(.*)") { $details.GoodLOC = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Bad LOC:(.*)") { $details.BadLOC = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Scan coverage:(.*)") { $details.ScanCoverage = $Matches[1].Trim() }
                    if ($lines[$i] -match "^Scan coverage LOC:(.*)") { $details.ScanCoverageLOC = $Matches[1].Trim() }
                }
            }

            #Results summary
            if ($lines[$i] -match "Results Summary") {           
                while (-NOT ([String]::IsNullOrEmpty($lines[++$i].Trim()))) { 
                    $summary.Add([ResultsSummary]::new($lines[$i].Substring(8)))
                }
            }                  
   
            #General Queries
            if ($lines[$i] -match "^(-){27}General Queries Summary") { 
                while (-NOT ([String]::IsNullOrEmpty($lines[++$i].Trim()))) { $general.Add([GeneralQuery]::new($lines[$i])) } 
            }

            # End Time and runtime
            if ($lines[$i] -match "Exit Main") {
                $details.End = [datetime]::parseexact($lines[$i].substring(0,23), 'dd/MM/yyyy HH:mm:ss,FFF', $null)
                $lines[$i] -match "Elapsed Time: (\d\d:\d\d:\d\d\.\d{7}).*" | Out-Null
                $details.Runtime =  [TimeSpan]::ParseExact($Matches[1], "hh\:mm\:ss\.fffffff", $null)
            }
        }
    }

    Function Valid-LogFile {
        if (Test-Path -Path $logPath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($logPath)
            if ($ext -in '.txt', '.log') {
                return $true
            }
        }
        return $false
    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
    #region Excel Functions

    Function Write-DetailsToExcel {

        Write-Verbose "Creating details worksheet" 
        
        # Create details section
        Add-Details  

        # Create parsing summary section in same worksheet
        Add-Parsing

        #Excluded Files
        if ($details.ExcludeFiles -gt 0) { Add-Excluded }

        #Formatting
        Format-DetailsTab
        
        Write-Verbose 'Completed writing data to worksheet "Details"'
    }

    Function Add-Details{
        $detailsDataHash = @(
            @{ Name = "Start Time"; Value = $details.Start }
            @{ Name = "End Time"; Value = $details.End }
            @{ Name = "Total Run Time"; Value = if ([string]::IsNullOrEmpty($details.Runtime)) { "" } else { $details.Runtime.ToString("hh\:mm\:ss\:fff") } }
            @{ Name = "Version"; Value = $details.Version }
            @{ Name = "Processor Count"; Value = $details.ProcessorCount }
            @{ Name = "Available Memory"; Value = $details.AvailableMemory }
            @{ Name = "Project Name"; Value = $details.ProjectName }
            @{ Name = "Project ID"; Value = $details.ProjectId }
            @{ Name = "Identified Source Files"; Value = $details.IdentifiedFiles }
            @{ Name = "Scanned Languages"; Value = $details.ScannedLanguages }
            @{ Name = "Not Scanned Languages"; Value = $details.NotScannedLanguages }
            @{ Name = "Multi-Language Mode"; Value = $details.MultiLanguageMode }
            @{ Name = "Predefined File Exclusions"; Value = $details.PredefinedExclusions }
            @{ Name = "Excluded Files Count"; Value = $details.ExcludeFiles }
            @{ Name = "Incremental Scan"; Value = $details.IncrementalScan }
        )

        if ($details.IncrementalScan) {
            $detailsDataHash += @{ Name = "Files Changed"; Value = $details.IncrementalFilesChanged }
            $detailsDataHash += @{ Name = "Closure Files"; Value = $details.$details.IncrementalFilesClosure }
        }

        # Convert horizontal data to vertical
        $detailsData = $detailsDataHash | ForEach-Object {
            [PSCustomObject]@{ Property = $_.Name; Value = $_.Value } 
        }

        $detailsData | Export-Excel -Path $excelPath `
                                    -WorksheetName "Details" `
                                    -AutoSize `
                                    -BoldTopRow `
                                    -CellStyleSB { param($worksheet) $worksheet.Cells["A:B"].Style.HorizontalAlignment="Left" }
    
    }

    Function Add-Parsing {
        $parsingSummaryDataHash = @(
            @{ Name = "Total Files"; Value = $details.TotalFiles }
            @{ Name = "Partially Good Files"; Value = $details.PartiallyGoodFiles }
            @{ Name = "Bad Files"; Value = $details.BadFiles }
            @{ Name = "Parsed LOC"; Value = $details.ParsedLOC }
            @{ Name = "Good LOC"; Value = $details.GoodLOC }
            @{ Name = "Bad LOC"; Value = $details.BadLOC }
            @{ Name = "Scan Coverage"; Value = $details.ScanCoverage }
            @{ Name = "Scan Coverage LOC"; Value = $details.ScanCoverageLOC }
        )

        # Convert horizontal data to vertical
        $parsingSummaryData = $parsingSummaryDataHash | ForEach-Object {
            [PSCustomObject]@{ Property = $_.Name; Value = $_.Value } 
        }

        $parsingSummaryData | Export-Excel -Path $excelPath `
                                           -WorksheetName "Details" `
                                           -AutoSize `
                                           -BoldTopRow `
                                           -StartRow 1 `
                                           -StartColumn 4 `
                                           -CellStyleSB { param($worksheet) $worksheet.Cells["D:E"].Style.HorizontalAlignment="Left" } 
    }

    Function Add-Excluded {
        $filesData = $excludeFiles | ForEach-Object { [PSCustomObject] @{ 'Excluded Files' = $_ } }
        $filesData | Export-Excel -Path $excelPath `
                                  -WorksheetName "Details" `
                                  -TableName "Excluded_Files" `
                                  -TableStyle "Light8" `
                                  -AutoSize `
                                  -BoldTopRow `
                                  -StartRow 1 `
                                  -StartColumn 7 `
                                  -CellStyleSB { param($worksheet) $worksheet.Cells["D:E"].Style.HorizontalAlignment="Left" }  
    }
    
    Function Format-DetailsTab {
        $excel = Open-ExcelPackage -Path $excelPath
        $sheet = $excel.Workbook.Worksheets['Details']
        
        $sheet.Cells["A1:B1"].merge = $true
        $sheet.Cells["A1"].Value = "Details"
        $sheet.Cells["A1"].Style.HorizontalAlignment = "Center"
        $sheet.Cells["A1"].Style.Font.Bold = $true          
        if ($details.IncrementalScan) { $range = $sheet.Cells["A1:B18"] }
        else { $address = $range = $sheet.Cells["A1:B16"] }
        $range.Style.Border.Top.Style    = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        $range.Style.Border.Bottom.Style = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        $range.Style.Border.Left.Style   = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        $range.Style.Border.Right.Style  = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin

        
        $sheet.Cells["D1:E1"].merge = $true
        $sheet.Cells["D1"].Value = "Parsing Summary"
        $sheet.Cells["D1"].Style.HorizontalAlignment = "Center"
        $sheet.Cells["D1"].Style.Font.Bold = $true
        $range = $sheet.Cells["D1:E9"]
        $range.Style.Border.Top.Style    = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        $range.Style.Border.Bottom.Style = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        $range.Style.Border.Left.Style   = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        $range.Style.Border.Right.Style  = [OfficeOpenXml.Style.ExcelBorderStyle]::Thin
        
        Close-ExcelPackage $excel  
    }

    Function Write-PhasesToExcel {

        Write-Verbose "Creating phases worksheet"
        
        $phasesData = $phases | ForEach-Object {
            [PSCustomObject]@{
                'Phase' = $_.PhaseName
                'Start Time' = $_.Start
                'End Time' = $_.End
                'Run Time' = if ([String]::IsNullOrEmpty($_.Runtime)) { "" } else { $_.Runtime.ToString("hh\:mm\:ss\:fff") }
            }
        }

        $phasesData | Export-Excel -Path $excelPath `
                                   -WorksheetName "Phases" `
                                   -TableName "Phases" `
                                   -TableStyle "Light8" `
                                   -AutoSize `
                                   -BoldTopRow `
                                   -Append

        Write-Verbose 'Completed writing data to worksheet "Phases"'
    }

    Function Write-FilesToExcel {

        Write-Verbose "Creating Files worksheet"
        
        $filesData = $files | ForEach-Object {
            [PSCustomObject]@{
                'File' = $_.FileName
                'Start Time' = $_.Start
                'End Time' = $_.End
                'Run Time' = if ([String]::IsNullOrEmpty($_.Runtime)) { "" } else { $_.Runtime.ToString("hh\:mm\:ss\:fff") }
            }
        }

        $filesData | Export-Excel -Path $excelPath `
                                  -WorksheetName "Files Processed" `
                                  -TableName "FilesProcessed" `
                                  -TableStyle "Light8" `
                                  -AutoSize `
                                  -BoldTopRow `
                                  -Append

        Write-Verbose 'Completed writing data to worksheet "Files Processed"'
    }

    Function Write-SummaryToExcel {
       
        Write-Verbose "Creating Results Summary worksheet"
        
        $summaryData = $summary | ForEach-Object {
            [PSCustomObject]@{
                'Query' = $_.Query
                'Severity' = $_.Severity
                'Status' = $_.Status
                'Results' = $_.Results.ToString("N0")
                'Duration' = $_.Duration.ToString("hh\:mm\:ss\:fff")
                'CWE' = $_.Cwe
            }
        }

        $summaryData | Export-Excel -Path $excelPath `
                                    -WorksheetName "Results Summary" `
                                    -TableName "ResultsSummary" `
                                    -TableStyle "Light8" `
                                    -AutoSize `
                                    -BoldTopRow `
                                    -Append

        Write-Verbose 'Completed writing data to worksheet "Results Summary"'
    }

    Function Write-GeneralToExcel {
            
        Write-Verbose "Creating General Queries worksheet"
        
        $generalData = $general | ForEach-Object {
            [PSCustomObject]@{
                'Query' = $_.Query
                'Status' = $_.Status
                'Results' = $_.Results.ToString("N0")
                'Duration' = $_.Duration.ToString("hh\:mm\:ss\:fff")
            }
        }

        $generalData | Export-Excel -Path $excelPath `
                                    -WorksheetName "General Queries" `
                                    -TableName "GeneralQueries" `
                                    -TableStyle "Light8" `
                                    -AutoSize `
                                    -BoldTopRow `
                                    -Append

        Write-Verbose 'Completed writing data to worksheet "General Queries"'
    }

    Function Write-ErrorsToExcel {
        
        Write-Verbose "Creating Errors worksheet"
        
        $errorsData = $errors | ForEach-Object {
            [PSCustomObject]@{
                'Line Number' = $_.Line
                'DateTime' = $_.DateTime.ToString("dd/MM/yyyy HH\:mm\:ss,fff")
                'Location' = $_.Location
                'Message' = $_.Message
            }
        }

        $errorsData | Export-Excel -Path $excelPath `
                                   -WorksheetName "Errors" `
                                   -TableName "Errors" `
                                   -TableStyle "Light8" `
                                   -AutoSize `
                                   -BoldTopRow `
                                   -Append

        Write-Verbose 'Completed writing data to worksheet "Errors"'
    }

    Function Write-PFExclusionsToExcel {
    
        Write-Verbose "Creating Predefined File Exclusions worksheet"
        
        $pfeData = $predefinedExclusions | ForEach-Object {
            [PSCustomObject]@{
                'Reason' = $_.Reason
                'File' = $_.File
            }
        }

        $pfeData | Export-Excel -Path $excelPath `
                                -WorksheetName "Predefined File Exclusions" `
                                -TableName "PredefinedFileExclusions" `
                                -TableStyle "Light8" `
                                -AutoSize `
                                -BoldTopRow `
                                -Append

        Write-Verbose 'Completed writing data to worksheet "Predefined File Exclusions"'
    }

    Function Write-EngineConfigToExcel {
    
        Write-Verbose "Creating Engine Configuration worksheet"
        
        $configData = $config.GetEnumerator() | ForEach-Object {
            [PSCustomObject]@{
                'Name' = $_.Name
                'Value' = $_.Value
            }
        }

        $configData | Export-Excel -Path $excelPath `
                                   -WorksheetName "Engine Configuration" `
                                   -TableName "EngineConfiguration" `
                                   -TableStyle "Light8" `
                                   -AutoSize `
                                   -BoldTopRow `
                                   -Append `
                                   -CellStyleSB { param($worksheet) $worksheet.Cells["A:B"].Style.HorizontalAlignment="Left" }

        Write-Verbose 'Completed writing data to worksheet "Engine Configuration"'
    }

    #endregion
    #----------------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#--------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Process

Process {

    #Display help if called
    if ($help) {
        Get-Help $MyInvocation.InvocationName -Full | Out-String
        exit
    }

    Write-Host "=========="
    $start = Get-Date
    Write-Host "Processing Started at $(Get-Date -Format "HH:mm:ss")"

    Write-Host "Loading log file"   
    if (Valid-LogFile) { $lines = Get-Content -path $logPath }
    else { 
        Write-Host "Invalid log file provided. Exiting" -f red
        return
    }
    Write-Host "Log file $logPath loaded"

    Write-Host "Parsing log file"
    Parse-LogFile $lines
    Write-Host "Completed parsing"

    Write-Host "Creating Excel"
    
    # Check if ImportExcel is installed
    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        Write-Error "ImportExcel module is not installed. Please run: Install-Module -Name ImportExcel -Scope CurrentUser"
        exit
    }

    Import-Module ImportExcel

    Write-DetailsToExcel
    Write-EngineConfigToExcel
    if ($details.PredefinedExclusions -gt 0) { Write-PFExclusionsToExcel }
    Write-FilesToExcel
    Write-PhasesToExcel
    Write-SummaryToExcel
    Write-GeneralToExcel
    Write-ErrorsToExcel

    Write-Host "Excel created at: $excelPath"
    
    # Open Excel file with default application
    & $excelPath

    $end = Get-Date
    $runtime = (New-TimeSpan –Start $start –End $end).ToString("hh\:mm\:ss")
    Write-Host "Processing Completed at $(Get-Date -Format "HH:mm:ss") with a runtime of $runtime"
    Write-Host "=========="
}

#endregion
#--------------------------------------------------------------------------------------------------------------------------------------------------------------
