#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Help

<#
.Synopsis
    This module has been created to simplify common tasks when scritpting for Checkmarx One

.Notes   
    Version:     8.0
    Date:        14/05/2026
    Written by:  Michael Fowler
    Contact:     michael.fowler@checkmarx.com
    
    Change Log
    Version    Detail
    -----------------
    1.0        Original version
    1.1        Added LOC to Scan object
    2.0        Added Severity Counters
    3.0        Updated to return Hash Tables rather than Lists to facilitate lookups
    3.1        Updated vulerability counts to return as hash tables
    3.2        Update results to return a List of results objects
    3.3        Update Connection class to return header that support SCA endpoints
    3.4        Minor bug fix
    4.0        Added function to return scans by Scan IDs
    4.1        Minor bug fix
    4.2        Modified page sizes to improve performance
    4.3        Minor bug fix
    4.4        Removed comments from results object as this field currently does not return results
    5.0        Added functionality to return hash of Applications
    5.1        Added Applications Id String to project object
    5.2        Added Projects IDs string to applications
    5.3        Bug Fix
    5.4        Made IAM Url string available in the CxConnection Object
    5.5        Made Tenant string available in the CxConnection Object
    5.6        Bug fix in Applications classes
    6.0        Expaned results classes to allow for different engine types
    6.1        Bug Fix
    7.0        Added Status details to the Scans classes
    7.1        Bug Fix
    7.2        Bug Fix
    7.3        Modified last scan to return Project ID as key and include null values for projects with no scans
    7.4        Added function to return scan between two dates filter by status + changed scan function names
    7.5        Add function to get scans filtered by hash of projects as returned by Get-Projects methods
    7.6        Add option to retrieve Application risk
    7.7        Updated SSCS results to identify Secrets vs Scorecard and change counters from Secrets to SSCS
    7.8        Added -UseBasicParsing switch to all Invoke-WebRequest and Invoke-RestMethod calls
    7.9        Added ReCalc Status field to scan object
    8.0        Updated serializer to allow for larger data sets
    8.1        Bug fix
    
.Description
    The following functions are available for this module
    
    ApiCall
        Details
            Function to take an Invoke-WebRequest or Invoke-RestMethod script block
            Will recreate authorisation token if due to expire
            Performs error handling
        Parameters
            ScriptBlock - Script block to run. Must be Invoke-WebRequest or Invoke-RestMethod
            CxOneConnObj - a Checkmarx One connection object
            noerror - switch to ignore error hanlder and rethrow the error
        Examplle 
            $response = ApiCall { Invoke-WebRequest $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
    
    New-Connection
        Details
            Function to create a Checkmarx Connection object with a prompt for the API Key
            Connection object is needed for additional calls in module
            Connection object contains the BaseURI and Authorisdation Headers
        Parameters
            No Parameters required
        Example 
            $conn = New-Connection
    
    New-SilentConnection
        Details
            Function to create a Checkmarx Connection object with a provided API Key
            Connection object is needed for additional calls in modeule
            Connection object contains the BaseURI and Authorisdation Headers
        Parameters
            apikey - Checkmarx One API key
        Example
            $conn = New-SilentConnection "<API_KEY>"
        
    Get-AllProjects
        Details
            Function to return a Hash of all projects with Key = Project ID and Value = Project Object 
            Returns a Hash of project objects
        Parameters
            CxOneConnObj - Checkmarx One connection object
            getBranches - Optional switch to determine if project branches should be returned for the projects
        Example
            $projects = Get-AllProjects $conn
    
    Get-ProjectsByNames
        Details 
            Function to get a hash of projects filtered by CSV string of project names
            Key = Project ID and Value = Project Object 
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectNames - CSV string of project names to filter results returned
            getBranches - Optional switch to determine if project branches should be returned for the projects
        Example
            $projects = Get-AllProjects $conn "project1,project2,project3"
                  
    Get-ProjectsByIds
        Details
            Function to get a hash of projects filtered by CVS string of project ids
            Key = Project ID and Value = Project Object 
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectIds - CSV string of project Ids to filter results returned
            getBranches - Optional switch to determine if project branches should be returned for the projects
        Example
            $projects = Get-AllProjects $conn "<project_id_1>,<project_id_2>,<project_id_3>"

    Get-Applications
        Details
            Function to get a hash of all applications
            Key = Application ID and Value = Application Object 
        Parameters
            CxOneConnObj - Checkmarx One connection object
            getRisk - Optional switch to retrieve application risk fields
        Example
            $applications = Get-Applications $conn -getRisk
        
    Get-AllScans
        Details
            Function to get a hash of scans filtered by statuses provided as a CSV string
            Key = Scan ID and Value = Scan Object 
            Statuses = CSV of Scan statuses to filter results
               Valid Statuses are Queued, Running, Completed, Failed, Partial, Canceled
               If all Statuses are required use "All"
        Parameters
            CxOneConnObj - Checkmarx One connection object
            statuses - CSV string of scan statuses to filter results
        Example
            $scans = Get-AllScans $conn "Completed","Partial"
            
    Get-ScansByDays
        Details
            Function to get a hash of all scans filtered by statuses provided as a CSV string and number of days.
            Key = Scan ID and Value = Scan Object
            Statuses = CSV of Scan statuses to filter results
               Valid Statuses are Queued, Running, Completed, Failed, Partial, Canceled
               If all Statuses are required use "All"
            ScanDays = Number of days to return scan for
               Must be a integer greater or equal to 0 
               0 will return all days
        Parameters
            CxOneConnObj - Checkmarx One connection object
            Statuses - CSV string of scan statuses
            scanDays - Integer value between 0 and 366
        Example
            $scans = Get-ScansByDays $conn "All","Partial" 90

    Get-ScansByDates
        Details
            Function to get a hash of all scans between two dates(inclusive), filtered by statuses.
            Key = Scan ID and Value = Scan Object
            Statuses = CSV of Scan statuses to filter results
               Valid Statuses are Queued, Running, Completed, Failed, Partial, Canceled
               If all Statuses are required use "All"
            fromDate = The starting date to return values for
            toDate = The last date to return values for

        Parameters
            CxOneConnObj - Checkmarx One connection object
            Statuses - CSV string of scan statuses
            fromDate - Date string in the format yyyy-MM-dd
            toDate - Date string in the format yyyy-MM-dd
        Example
            $scans = Get-ScansByDates $conn "Completed","Partial" "2025-01-01" "2025-06-30"
   
    Get-ScansByProjects
        Details
            Function to get a hash scans for a provided hash of project objects
            Key = Scan ID and Value = Scan Object
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectsHash - Hash of projects to return last of. Must be a hash as provided by call above
        Example
            $scans = Get-ScansByIds $conn $projects

    Get-ScansByIds
        Details
            Function to get a hash scans for a provided as a CSV string of Scan IDs
            Key = Scan ID and Value = Scan Object
        Parameters
            CxOneConnObj - Checkmarx One connection object
            ScanIds - CSV string of scan IDs
        Example
            $scans = Get-ScansByIds $conn "4bf2d7fc-8a7c-420d-ac1a-7c62cebb7bbb,141cf46f-1781-45ab-8cee-0f5856337b2f"
        
    Get-LastScans
        Details
            Get a hash of the the last scans for the projects provided in the projects hash.
            Key = Project ID and Value = Scan Object
            Optional switch to return last scan for Main Branch (if set)
            Will return null object for projects with no scans
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectsHash - Hash of projects to return last of. Must be a hash as provided by call above
            useMainBranch - optional switch to specify only return last scan on Main branch (if set)
        Example
            $scans = Get-LastScans $conn $projects
            
    Get-LastScansForGivenBranches
        Details
            Get a hash of the last scan for the projects provided in the projects hash.
            Key = Project ID and Value = Scan Object
            Returns last scan for the branch provided in the CSV file
            Will return null object for projects with no scans
            branchesCSV must be a file path to a CSV with the header Projects,Branches and one project,branch per line
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectsHash - Hash of projects to return last of. Must be a hash as provided by call above
            branchesCSV - file path to CSV file containing the mapping of projects to primary branch
        Example
            $scans = Get-LastScansForGivenBranches $conn $projects "C:\files\branches.csv"
            
    Get-ScanResults
        Details
            Get the results for a given scan ID
            Returns a List of result objects
        Parameters
            CxOneConnObj - Checkmarx One connection object
            scanId - The ID of the scan results to return
        Example
            $results = Get-ScanResults $conn "<scan_id>"

    Get-SeverityCounters
        Details
            Get a hash with the severity counters for a given hash of Scans
            Returns a hash with Key = Scan ID and Value = Severity Counter Object
        Parameters
            CxOneConnObj - Checkmarx One connection object
            scansHash - Hash of Scans to return counters for. Must be a hash as provided by call above
        Example
            $results = Get-SeverityCounters $conn $scanHash
#>

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Functions

# Function to take an Invoke-WebRequest or Invoke-RestMethod script block and reconnect if the token is due to expire
Function ApiCall() {
    Param(
        [Parameter(Mandatory=$true)][scriptblock]$scriptBlock,
        [Parameter(Mandatory=$true)][CxOneConnection]$CxOneConnObj,
        [Parameter(Mandatory=$false)][switch]$noerror
    )

    $CxOneConnObj.ValidateToken() | Out-Null

    try {
        $response = Invoke-Command -Command $scriptBlock
        return $response
    } 
    catch [Exception] {
       if ($noerror) { throw }
       $s = $_ | Format-List * -Force | Out-String
       Write-host $s -f red
       exit
    }
}

#Function to return a CxOneConnection Object with prompt to provide API Key
Function New-Connection {
    return [CxOneConnection]::new()
}

#Function to return a CxOneConnection Object silently using provided API Key
Function New-SilentConnection {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$apikey
    )    

    return [CxOneConnection]::new($apiKey)
}

#Function to return a Hash of Project Objects
Function Get-AllProjects {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$false)]
        [Switch]$getBranches
    )

    return ([Projects]::new($CxOneConnObj, $getBranches)).ProjectsHash
}

#Function to return a filtered Hash of Projects using comma seperated string of names.
Function Get-ProjectsByNames {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [String]$projectNames,

        [Parameter(Mandatory=$false)]
        [Switch]$getBranches
    )

    return ([Projects]::new($CxOneConnObj, $null, $projectNames, $getBranches)).ProjectsHash
}

#Function to return a filtered Hash of Projects using comma seperated string of IDs.
Function Get-ProjectsByIds {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [String]$projectIds,

        [Parameter(Mandatory=$false)]
        [Switch]$getBranches
    )

    return ([Projects]::new($CxOneConnObj, $projectIds, $null, $getBranches)).ProjectsHash
}

#Function to return a Hash of Application Objects
Function Get-Applications {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,
        
        [Parameter(Mandatory=$false)]
        [Switch]$getRisk
    )

    return ([Applications]::new($CxOneConnObj, $getRisk)).ApplicationsHash
}

#Get all scans filtered by CSV string of statuses. If all statuses are required use "All" only for status
Function Get-AllScans {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Queued", "Running", "Completed", "Failed", "Partial", "Canceled", "All", IgnoreCase = $false)]
        [String[]]$statuses
    )

    return ([Scans]::new($CxOneConnObj, $statuses -join ",")).ScansHash
}

#Get all scans filtered by CSV string of statuses and number of days to return. If all statuses are required "All" only for status
Function Get-ScansByDays {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Queued", "Running", "Completed", "Failed", "Partial", "Canceled", "All", IgnoreCase = $false)]
        [String[]]$statuses,

        [Parameter(Mandatory=$true)]
        [ValidateRange(1,366)]
        [Int]$scanDays
    )
    
    return ([Scans]::new($CxOneConnObj, $statuses -join ",", $scanDays)).ScansHash
}

#Get all scans between two dates (inclusive) filtered by CSV string of statuses. If all statuses are required use "All" for status
Function Get-ScansByDates {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Queued", "Running", "Completed", "Failed", "Partial", "Canceled", "All", IgnoreCase = $false)]
        [String[]]$statuses,

        [Parameter(Mandatory=$true)]
        [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
        [String]$fromDate,

        [Parameter(Mandatory=$true)]
        [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
        [String]$toDate
    )
      
    return [Scans]::new(
        $CxOneConnObj, 
        $statuses -join ",", 
        [uri]::EscapeDataString(([datetime]$fromDate).ToString("yyyy-MM-ddThh:mm:ss.fffffffZ")), 
        [uri]::EscapeDataString(([datetime]$toDate).AddDays(1).AddSeconds(-1).ToString("yyyy-MM-ddThh:mm:ss.fffffffZ"))
    ).ScansHash
}

#Get scans filtered by status and projects hash
Function Get-ScansByProjects {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[String, Project]]$projectsHash
    )
    
    return ([Scans]::new($CxOneConnObj, "All", $projectsHash)).ScansHash
}

#Get scans filtered by status and scan Ids.
Function Get-ScansByIds {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [String]$scanIds
    )
    
    return ([Scans]::new($CxOneConnObj, "All", $scanIds)).ScansHash
}

#Get the last scan for the projects provided in the projects hash. 
Function Get-LastScans {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[String, Project]]$projectsHash,

        [Parameter(Mandatory=$false)]
        [Switch]$useMainBranch
    )

    return ([Scans]::new($CxOneConnObj, $projectsHash, $useMainBranch, $null)).ScansHash
}

#Get the last scan for the projects provided in the projects hash. Takes a filepath to a CSV containing the mapping of projects to branch 
Function Get-LastScansForGivenBranches {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.List[Project]]$projectsList,

        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [String]$branchesCSV
    )

    return ([Scans]::new($CxOneConnObj, $projectsList, $false, $branchesCSV)).ScansHash
}

#Get the results for a given scan ID
Function Get-ScanResults {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [String]$scanId
    )

    return ([Results]::new($CxOneConnObj, $scanId)).ResultsList
}

#Get the Severity Counters for the given list of scans. Returns a dictionary with key = ScanId and value = Severity Counter Object
Function Get-SeverityCounters {
    Param(
        [Parameter(Mandatory=$true)]
        [CxOneConnection]$CxOneConnObj,

        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[String, Scan]]$ScansHash
    )

    return ([SeverityCounters]::new($CxOneConnObj, $ScansHash)).SeverityCountersHash
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Checkmarx One Connection Class
class CxOneConnection {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    #Connection Variables
    [string]$BaseURI
    [string] $IamUri
    [string]$Tenant
    [HashTable]$Headers

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Variables

    #Form Variables
    Hidden [System.Windows.Forms.Form]$mainForm
    Hidden [System.Windows.Forms.Textbox]$txtBaseUri
    Hidden [System.Windows.Forms.Textbox]$txtIamUri
    Hidden [System.Windows.Forms.Textbox]$txtTenant
    Hidden [System.Windows.Forms.Textbox]$txtAPIKey
    Hidden [System.Windows.Forms.Button]$btnOK
    
    #Connection Detail for retry
    Hidden [string] $ApiKey
    Hidden [datetime]$TokenExpiry

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructor

    CxOneConnection() { $this.ManualLogin() }   
    
    CxOneConnection([string] $apikey) { $this.AutoLogin($apikey) }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Class Methods
    
    #Log in and set varibles using WinForm
    Hidden ManualLogin() {
        
        Write-Verbose "Getting connection details"
        
        $this.CreateForm()
            
        $result = $this.mainForm.ShowDialog()
    
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        
            if (-Not (($this.txtAPIKey.Text -eq "") -or ($this.txtBaseUri.Text -eq ""))) {  Write-Verbose "Connection details retrieved" }
            else { 
                Write-Host "Invalid details entered. PLease check details and try again"
                exit
            }
        }
        else { 
            Write-Host "Connection details retrieval cancelled by user. Exiting"
            exit
        } 
    }

    #Log in and set varibles using provided API Key
    Hidden AutoLogin([string]$apikey) {
        
        Write-Verbose "Getting connection details"
        
        $this.ApiKey = $apikey.Trim()
            
        # Parse the API Token provided and extract IAM URI and Tenant names
        try { $apiToken = $this.ParseJWTtoken($apikey) }
        catch { 
            Write-Host "API Key Provided is invalid" -f Red
            Write-Host "PLease check the API Key and try again" -f Red
            throw "Invalid API Key Provided"
        }
        $uri = [System.Uri]$apiToken.aud
        $this.IamUri = "https://" + $uri.Host
        $this.Tenant = ($uri.AbsolutePath -split "/")[3]
        
        #Get Access Token, parse the token and set Base URL if successfull
        if (-not ($accessToken = $this.SetHeaders($this.IamUri, $this.Tenant, $this.ApiKey, $true))) { 
            Write-Host "Unable to log on using API Key provided" -f Red
            Write-Host "PLease check the API Key and try again" -f Red
            throw "Invalid API Key Provided"
        }
        $keyToken = $this.ParseJWTtoken($accessToken)
        $this.BaseURI = $keyToken."ast-base-url"
    }

    #Form to get Key, Tenant and URLs from the user
    Hidden CreateForm() {
        
        # Main Form
        $this.mainForm = [System.Windows.Forms.Form]::New()
        $this.mainForm.Text = "Checkmarx One Credentials"
        $this.mainForm.Size = [System.Drawing.Size]::New(710,500)
        $this.mainForm.MaximumSize = $this.mainForm.Size
        $this.mainForm.MinimumSize = $this.mainForm.Size
        $this.mainForm.StartPosition = "CenterScreen" 
        $this.mainForm.Font = [System.Drawing.Font]::New("Segoe UI",11,[System.Drawing.FontStyle]::Regular)
    
        #region Checkmarx Icon
        $iconBase64 = "AAABAAMAEBAAAAEAIABoBAAANgAAACAgAAABACAAKBEAAJ4EAAAwMAAAAQAgAGgmAADGFQAAKAAAABAAAAAgAAAAAQAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/NWow/TRql/00a9n9M2v5/TNr+f00a9n9NWuW+jVqMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP85cQn8M2ya/TRq/v00a//9NGv//TRr//00a//9NGv//TRr//00av79NGuZ4zlVCQAAAAAAAAAAAAAAAP85cQn8NGvB/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//40asDjOVUJAAAAAAAAAAD9M2ya/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRrmQAAAAD/NGgx/TRq/v00a//9NGv//Ut8//7T3//9X4r//TRr//00a//9Wof//tPf//1QgP/9NGv//TRr//00av76NWow/TRqmP00a//9NGv//TRr//1Fd///5Ov//+3y//1Ofv/9Snv//+nv///n7v/9SXr//TRr//00a//9NGv//TVrlv0zatr9NGv//TRr//00a//9NGv//UV3//7S3v/+3+j//tvk//7W4f/9SHr//TRr//00a//9NGv//TRr//00a9n9NGv6/TRr//00a//9NGv//TRr//00a//9S3z///j6///7/P/9T3///TRr//00a//9NGv//TRr//00a//9M2v5/TRr+v00a//9NGv//TRr//00a//9U4L//+Pr//7P3P/+x9b//uLq//1Nff/9NGv//TRr//00a//9NGv//TNr+f0zatr9NGv//TRr//00a//9THz///H1//7h6f/9Q3b//Txx//7R3f//6e///VaE//00a//9NGv//TRr//00a9n9NGqY/TRr//00a//9NGv//UV3//64y//9UID//TRr//00a//9QnX//tvl///w9P/9YIv//TRr//00a//9NGqX/zRtMf00av79NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//1Iev//5Ov///D0//00a//9NGr+/zVqMAAAAAD9M2ub/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Ux8//1vlv/9NGv//DNsmgAAAAAAAAAA/zlxCfw1asL9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//DRrwf85cQkAAAAAAAAAAAAAAAD/OXEJ/TNrm/00av79NGv//TRr//00a//9NGv//TRr//00a//9NGr+/TNsmv85cQkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/NG0x/TRqmP0zatr9NGv6/TRr+v0zatr9NGqY/zRoMQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKAAAACAAAABAAAAAAQAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/N20O/DRqWf0zbJr+NGvL/TNr6v00a/v9NGv7/TNr6vw0a8v8M2qa/DRrWP83bQ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD4MGcl/DRrnf00a/b9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr9f01a5v/MmokAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/OXEJ+zNrjP00a/r9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/r9NGuK/0BgCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/zJqJP40bNP9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//+NGvS+DNmIwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP81ajD9NGvq/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9M2vq/zJpLgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD4MGcl/TRr6v00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9M2vq+DNmIwAAAAAAAAAAAAAAAAAAAAAAAAAA/zlxCf00a9T9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//+NGvS/0BgCAAAAAAAAAAAAAAAAAAAAAD9M2uN/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGuKAAAAAAAAAAAAAAAA/y9rJv00a/v9NGv//TRr//00a//9NGv//TRr//00a//9O3D//qS9//6swv/9QnX//TRr//00a//9NGv//TRr//00a//9NGv//T1x//6mvv/+qsH//UBz//00a//9NGv//TRr//00a//9NGv//TRr//00a/r/MmokAAAAAAAAAAD9NGue/TRr//00a//9NGv//TRr//00a//9NGv//TRr//6Lqv////////////7O2//9OW///TRr//00a//9NGv//TRr//02bf/+wtP////////////+mbX//TRr//00a//9NGv//TRr//00a//9NGv//TRr//01a5sAAAAA/zNmD/40a/b9NGv//TRr//00a//9NGv//TRr//00a//9NGv//nic//////////////////63y//9NWv//TRr//00a//9NGv//qnA//////////////////6Hp//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr9f83bQ78Mmpb/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//pOw///+/v////////////6ct//9NGv//TRr//6NrP/////////////////+obr//TVs//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//DRrWP00apz9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Xic///4+v////////////2Ao//9c5n///39/////////Pz//YWm//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//8M2qa/jRrzf00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//WKM///u8/////////7+///8/f////////P2//1slP/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//w0a8v9NGvs/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//U9////r8f/////////////09//9WIX//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TNr6v00a/79NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9d5v///n6//////////////z9//19oP/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv7/TRr/v00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//pKv///+/v///////+3x///n7v////////7+//2Lq//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/v9NGvs/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Tdt//6uxP/////////////1+P/9W4f//U19///p7/////////////6atf/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TNr6v00as79NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//08cf/+x9b//////////////P3//W+W//00a//9NGv//VaE///w9P////////////6pwf/9NWz//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//+NGvL/DRrnf00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//oyr//////////////////2Jqf/9NGv//TRr//00a//9NGv//WCL///2+P////////////64y//9OG7//TRr//00a//9NGv//TRr//00a//9NGv//TRr//0zbJr8NWlc/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//+d5z////////////+pL3//TRr//00a//9NGv//TRr//00a//9NGv//WuT///6+/////////////7F1f/9PHH//TRr//00a//9NGv//TRr//00a//9NGv//DRqWe8wYBD9NGr3/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9bJT//XWa//01a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Xec///9/f////////////7Q3f/9QXT//TRr//00a//9NGv//TRr//00a/b/N20OAAAAAP0za5/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//YSm///+/v////////////7N2v/9NGv//TRr//00a//9NGv//DRrnQAAAAAAAAAA/zRpJ/00a/v9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//pSx//////////////X4//00a//9NGv//TRr//00a/r4MGclAAAAAAAAAAAAAAAA/TRqjv00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//pOw//7V4f/9fqH//TRr//00a//9NGv/+zNrjAAAAAAAAAAAAAAAAAAAAAD/M2YK/TNr1f00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//40bNP/OXEJAAAAAAAAAAAAAAAAAAAAAAAAAAD/Nmsm/TRq6/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGvq/zJqJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD6Nmc0/TRq6/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr6v81ajAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/Nmsm/TNr1f00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a9T4MGclAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/M2YK/TRqjv00a/v9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/v9M2uN/zlxCQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/zRpJ/0za5/9NGr3/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//40a/b9NGue/y9rJgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAO8wYBD8NWlc/DRrnf00as79NGvs/TRr/v00a/79NGvs/jRrzf00apz8Mmpb/zNmDwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKAAAADAAAABgAAAAAQAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AgALwLWkR/zRpIvs1akj9NGqE/DRstP0zatb+NGzt/TRr+/00a/v9NGzt/jNr1fw0arT7M2uD+zJsR/80aSL/MHAQ/wCAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/QIAE/zRtMf00a3X8NGux/TRr5f00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//41a+T8NGuw/TVsdP81ajD/QEAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPYzbh78NGqd/TRr4/00a/r9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr+v00a+L9M2ya/zdtHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAAHzMW0V/TRscf0zavP9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr8f0yaXD/M2YU/wAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP81az78NGu3/TRr+v00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/r+NGu1/zNqPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAB/DRsY/00a+j9NGv+/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv+/jRr5/wza1//AAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8kbQf6M2pv/TRr8/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//0za/P9M2lt/yqABgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAAAf0zam/9NGvs/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGrr/TNpbf8AAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/DNrZP40a/P9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TNr8/wza18AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAAH7NWk//TRr6P00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//40a+f/M2o8/wAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8xbRX8M2u4/TRr/v00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/7+NGu1/zNmFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP0zanP9NGv6/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv6/TJpcAAAAAAAAAAAAAAAAAAAAAAAAAAA9zFrH/0za/P9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Thu//1fi//9jKv//WmS//08cf/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Tlu//1ijP/9jaz//WeQ//07cP/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr8f83bRwAAAAAAAAAAAAAAAD/QIAE/DNrn/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//X6h///1+P////////r8//6guf/9PXL//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9OW///pCu///2+P////////n7//6Rr//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//0zbJr/QEAEAAAAAAAAAAD6Mmkz/jRr4/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//9Le///////////////////2+f/+jKv//Tdt//00a//9NGv//TRr//00a//9NGv//TRr//01bP/9fqH///L1///////////////////d5v/9PnL//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a+L/NWowAAAAAP8AgAL/NGx2/TRr+v00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//73P////////////////////////8PT//WyU//00a//9NGv//TRr//00a//9NGv//TRr//1hi///5u3////////////////////////R3f/9OW7//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/r9NWx0/wCAAv8taRH8M2uz/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//VqH///V4f///////////////////////+fu//1okP/9NGv//TRr//00a//9NGv//VqH///c5v///////////////////////+Hp//1okf/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//8NGuw/zBwEP8zbSP9NGvn/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//1Sgf/+yNf///7////////////////////e5//9W4f//TRr//00a//9T3///9Xg////////////////////////1eD//VqH//01a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//+NWvk/zRpIv8zaUv9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9SXr//sPT///7/P/////////////////+xdT//Ul6//1Ddv/+t8v///7+//////////////3+//7P3P/9U4H//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv/+zJsR/0zbIf9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//UF1//6jvP//8/f//////////////f3//rvN//6vxf//+vv/////////////+Pr//rDF//1Jev/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv/+zNrg/41arf9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//08cf/+jq3///b4//////////////7+///+/v/////////////5+v/+nbf//UB0//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//DRqtP4zatr9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//oCi///09/////////////////////////n6//6TsP/9N23//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//jNr1f0za/P9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//UF0///U3////////////////////////+fu//1Ief/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRs7f00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9SHr//sHS///8/P////////////////////////3+//7I1//9Snv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr+/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//1Sgf/+x9b///7///////////////X3///y9f/////////////+///+xdT//U9+//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr+/0za/P9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NWz//WqS///V4P//////////////////8PT//oio//56nv//5ez//////////////v7//s3a//1bh//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//jRs7f0za9v9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//02bP/9eZ7//+ju///////////////////6+//+mbX//Tpv//03bf/+faH///P2///////////////////d5v/9Y43//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TNq1v41a7j9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//Tlu//1/ov//8vX///////////////////7+//66zP/9PHH//TRr//00a//9NGv//pGv///2+f//////////////////3+j//WGM//01bP/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//DRstPsza4j9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//YGj///4+v///////////////////v7//r7Q//1Ddv/9NGv//TRr//00a//9NGv//TVs//6Rrv//8/b//////////////////+Tr//13nP/9Nm3//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRqhP8ya0z9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//9Tf///////////////////////+zNr//U19//00a//9NGv//TRr//00a//9NGv//TRr//07cP/+nLf///r7///////////////////t8v/9gKL//Tdt//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv/+zVqSP8zbSP9NGvo/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//77Q///////////////////j6v/9Yoz//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9PHH//rLH///8/f//////////////////8vX//Xuf//04bv/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGvl/zRpIvE5YxL8NGq0/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//VmG//7F1f/+6O7//tDd//1ulf/9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//UBz//6vxf//+/z///////////////////b5//6Sr//9P3P//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//8NGux8C1pEf8AgAL9M2t3/TRr+/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//1Cdv/9Tn7//UZ4//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//1Ed//+ucz///7+///////////////////3+f/+nbj//Ttw//00a//9NGv//TRr//00a//9NGv//TRr//00a/r9NGt1/wCAAgAAAAD/Mmkz/TNr5P00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9S3z//s/c/////////////////////////f3//Y+t//00a//9NGv//TRr//00a//9NGv//TRr//00a+P/NG0xAAAAAAAAAAD/QIAE/TRqof00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//VB///7N2v///////////////////////+zx//00a//9NGv//TRr//00a//9NGv//TRr//w0ap3/QIAEAAAAAAAAAAAAAAAA/zhwIP00a/T9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//1Tgv//0t///////////////////ubt//00a//9NGv//TRr//00a//9NGv//TNq8/Yzbh4AAAAAAAAAAAAAAAAAAAAAAAAAAP80a3X9NGv7/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9Y43//9nj///x9f//6e7//Xqe//00a//9NGv//TRr//00a//9NGv6/TRscQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP86aBb8NGu6/TRr/v00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//U9+//1xmP/9W4f//Tdt//00a//9NGv//TRr//00a/78NGu38zFtFQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAAH/NGxA/TNr6f00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a+j/NWs+/wAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/zNsaP00a/T9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr8/w0bGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wCAAvszaXL9NGvv/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGvs+jNqb/8AAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP9AYAj7M2ly/TRr9P00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//40a/P9M2pv/yRtBwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AIAC/zNsaP0za+n9NGv+/TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv+/TRr6Pwza2T/AAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP80bED8NGu6/TRr+/00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a/r8M2u4+zVpPwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAAH/OmgW/zRrdf00a/T9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TNr8/0zanP/MW0V/wAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP84cCD9NGqh/TNr5P00a/v9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr+v40a+P8M2uf9zFrHwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/QIAE/zJpM/0za3f8NGq0/TRr6P00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a//9NGv//TRr//00a+f8M2uz/zRsdvoyaTP/QIAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AgALxOWMS/zNtI/8ya0z7M2uI/jVruP0za9v9M2vz/TRr//00a//9M2vz/jNq2v41arf9M2yH/zNpS/8zbSP/LWkR/wCAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
        #endregion
        $iconBytes = [Convert]::FromBase64String($iconBase64)
        $stream = [IO.MemoryStream]::New($iconBytes, 0, $iconBytes.Length)
        $this.mainForm.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::New($stream)).GetHIcon())
        $stream.Dispose()
    
        # Base texbox Label
        $lblBaseUri = [System.Windows.Forms.Label]::New()
        $lblBaseUri.Text = "Base URL"
        $lblBaseUri.Location = [System.Drawing.Point]::New(15,20)
        $this.mainForm.Controls.Add($lblBaseUri)
        
        # Base URL Textbox
        $this.txtBaseUri = [System.Windows.Forms.Textbox]::New()
        $this.txtBaseUri.Location = [System.Drawing.Point]::New(120,20)
        $this.txtBaseUri.Size = [System.Drawing.Size]::New(312,30)
        $this.txtBaseUri.Enabled = $false
        $this.mainForm.Controls.Add($this.txtBaseUri)
    
        # IAM URL texbox Label
        $lblIamUri = [System.Windows.Forms.Label]::New()
        $lblIamUri.Text = "IAM URL"
        $lblIamUri.Location = [System.Drawing.Point]::New(15,63)
        $this.mainForm.Controls.Add($lblIamUri)
    
        # IAM URL Textbox
        $this.txtIamUri = [System.Windows.Forms.Textbox]::New()
        $this.txtIamUri.Location = [System.Drawing.Point]::New(120,63)
        $this.txtIamUri.Size = [System.Drawing.Size]::New(312,30)
        $this.txtIamUri.Enabled = $false
        $this.mainForm.Controls.Add($this.txtIamUri)
    
        # Tenant texbox Label
        $lblTenant = [System.Windows.Forms.Label]::New()
        $lblTenant.Text = "Tenant"
        $lblTenant.Location = [System.Drawing.Point]::New(15,106)
        $this.mainForm.Controls.Add($lblTenant)
    
        # Tenant Textbox
        $this.txtTenant = [System.Windows.Forms.Textbox]::New()
        $this.txtTenant.Location = [System.Drawing.Point]::New(120,106)
        $this.txtTenant.Size = [System.Drawing.Size]::New(312,30)
        $this.txtTenant.Enabled = $false
        $this.mainForm.Controls.Add($this.txtTenant)
    
        # API Key label 
        $lblAPIKey = [System.Windows.Forms.Label]::New()
        $lblAPIKey.Text = "API Key"
        $lblAPIKey.Location = [System.Drawing.Point]::New(15,149)
        $this.mainForm.Controls.Add($lblAPIKey)

        # API Key Changed
        $txtAPIKey_TextChanged =  {
            [CxOneConnection]$cd = Get-Variable -ValueOnly -Scope 1 this
            if ($cd.txtAPIKey.Text -eq "") {
                $cd.ClearForm()
                return
            }      
            
            #Try parsing the API Key and set IAM and Tenant text boxes
            if (-not ($apiToken = $cd.TryParseToken($cd.txtAPIKey.Text.Trim()))) { return }
            $uri = [System.Uri]$apiToken.aud
            $cd.txtIamUri.Text = "https://" + $uri.Host
            $cd.txtTenant.Text = ($uri.AbsolutePath -split "/")[3]

            #Get Access Token, parse the token and set Base URL Text box if successfull
            if (-not ($accessToken = $cd.SetHeaders($cd.txtIamUri.Text, $cd.txtTenant.Text, $cd.txtAPIKey.Text.Trim(), $false))) { 
                $cd.ClearForm()
                return 
            }
            $keyToken = $cd.TryParseToken($accessToken)
            $cd.txtBaseUri.Text = $keyToken."ast-base-url"
            
            #Set Class Variables
            $cd.BaseUri = $keyToken."ast-base-url"
            $cd.ApiKey = $cd.txtAPIKey.Text.Trim()
            $cd.IamUri = $cd.txtIamUri.Text
            $cd.Tenant = $cd.txtTenant.Text
            $cd.TokenExpiry = ([DateTime]('1970,1,1')).AddSeconds($keyToken."exp")
            
            $cd.btnOK.Enabled = $true
        }

        # API Key Textbox
        $this.txtAPIKey = [System.Windows.Forms.Textbox]::New()
        $this.txtAPIKey.Location = [System.Drawing.Point]::New(120,149)
        $this.txtAPIKey.Size = [System.Drawing.Size]::New(552,229)
        $this.txtAPIKey.Multiline = $true
        $this.txtAPIKey.Add_TextChanged($txtAPIKey_TextChanged)
        $this.mainForm.Controls.Add($this.txtAPIKey)
    
        # OK Button
        $this.btnOK = [System.Windows.Forms.Button]::New()
        $this.btnOK.Text = "OK"
        $this.btnOK.Location = [System.Drawing.Point]::New(467,417)
        $this.btnOK.Size = [System.Drawing.Size]::New(96,34)
        $this.btnOK.Enabled = $false
        $this.btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $this.mainForm.Controls.Add($this.btnOK)
    
        # Cancel Button
        $btnCancel = [System.Windows.Forms.Button]::New()
        $btnCancel.Text = "Cancel"
        $btnCancel.Location = [System.Drawing.Point]::New(576,417)
        $btnCancel.Size = [System.Drawing.Size]::New(96,34)
        $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $this.mainForm.Controls.Add($btnCancel)
    }

    #Method to parse the API Key
    Hidden [PSObject]ParseJWTtoken([string]$token) {
        #https://www.michev.info/blog/post/2140/decode-jwt-access-and-id-tokens-via-powershell
     
        Write-Verbose "Decoding token"
    
        #Validate as per https://tools.ietf.org/html/rfc7519
        #Access and ID tokens are fine, Refresh tokens will not work
        if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Throw "Invalid Token" }
     
        #Header
        $tokenheader = $token.Split(".")[0].Replace('-', '+').Replace('_', '/')
        #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
        while ($tokenheader.Length % 4) { Write-Verbose "Invalid length for a Base-64 char array or string, adding ="; $tokenheader += "=" }
    
        #Convert from Base64 encoded string to PSObject all at once
        #[System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json | fl | Out-Default
     
        #Payload
        $tokenPayload = $token.Split(".")[1].Replace('-', '+').Replace('_', '/')
        #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
        while ($tokenPayload.Length % 4) { Write-Verbose "Invalid length for a Base-64 char array or string, adding ="; $tokenPayload += "=" }
    
        #Convert to Byte array
        $tokenByteArray = [System.Convert]::FromBase64String($tokenPayload)
        #Convert to string array
        $tokenArray = [System.Text.Encoding]::ASCII.GetString($tokenByteArray)
    
        #Convert from JSON to PSObject
        $tokobj = $tokenArray | ConvertFrom-Json
        
        Write-Verbose "Token decoded"
    
        return $tokobj
    }

    #Try parsing the provided token. Clear form and return null on fail
    Hidden [PSObject]TryParseToken([string]$token) {
        try {
            return $this.ParseJWTtoken($token)
        }
        catch {
            $this.ClearForm()
            return $null
        }
    }

    #Clear the form when invalid details
    Hidden ClearForm() {
        $this.txtIamUri.Text = ""
        $this.txtBaseUri.Text = ""
        $this.txtTenant.Text = ""
        $this.btnOK.Enabled = $false
    }

    #Create the Hash for use as the Header. Returns the Access Token on success and null on fail
    Hidden [string]SetHeaders([string]$iamurl, [string]$tenant, [string]$apikey, [bool]$setExpiry) {

        Write-Verbose "Starting Authentication"       
        
        #Get Access token
        $uri = "$iamurl/auth/realms/$tenant/protocol/openid-connect/token"
        $body = @{
            grant_type = "refresh_token"
            client_id = "ast-app"  
            refresh_token = $apikey
        }
        try {
            $accessToken = (Invoke-RestMethod -Uri $uri -Method POST -Body $body -UseBasicParsing).access_token
        }
        catch {
            Write-Verbose "Error authenticating."
            return $null
        }
    
        Write-Verbose "Authentication Completed"
        
        $this.Headers = @{
            accept = "application/json; version=1.0"
            Authorization = "Bearer $accessToken"
            "Cx-Authentication-Type" = "service"
            "Content-Type"  = "application/json"
        }

        if ($setExpiry) {
            $keyToken = $this.ParseJWTtoken($accessToken)
            $this.TokenExpiry = ([DateTime]('1970,1,1')).AddSeconds($keyToken."exp")
        }

        return $accessToken
    }
    
    Hidden Reconnect() {

        if ($null -eq $this.ApiKey -or $null -eq $this.IamUri) {
            Write-Host "API Key or IAM URI not set. Exiting"
            exit
        }
 
        Write-Verbose "Token Has expired, regenerating token"
        $this.SetHeaders($this.IamUri, $this.Tenant, $this.ApiKey, $true)
        Write-Verbose "Token regenerated"
    }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Public Class Methods
   
    # Function to test if token due to expire and reconnect if needed
    ValidateToken() {

        #Reconnect if token due to expire in the next 5 minutes
        if ([DateTime]::UtcNow -ge $this.TokenExpiry.AddMinutes(-5)) { $this.Reconnect() }
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Projects Classes

class Project {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [String]$ProjectID
    [String]$ProjectName
    [String]$TenantId
    [Nullable[datetime]]$CreatedAt
    [Nullable[datetime]]$UpdatedAt
    [Array]$Groups
    [string]$GroupsString
    [String]$RepoURL
    [String]$MainBranch
    [String]$Origin
    [string]$ScmRepoId
    [string]$RepoId
    [System.Collections.IDictionary]$Tags
    [string]$TagsString
    [Int]$Criticality
    [Bool]$PrivatePackage
    [String]$ImportedProjName
    [Array]$Branches
    [string]$BranchesString
    [Array]$ApplicationIds
    [String]$ApplicationIdsString
 
    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    Project ([System.Collections.IDictionary]$project) { $this.SetVariables($project) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([System.Collections.IDictionary]$project) {
           
        $this.ProjectId = $project.id        
        $this.ProjectName = $project.name
        $this.TenantId = $project.tenantId
        
        try { $this.CreatedAt = [DateTime]$project.createdAt }
        catch { $this.CreatedAt = $null }
    
        try { $this.UpdatedAt = [DateTime]$project.updatedAt }
        catch { $this.UpdatedAt = $null }
            
        try { $this.Groups = ($project.groups) -join ";" }
        catch { $this.Groups = $null }
            
        $this.RepoURL = $project.repoURL
        $this.MainBranch = $project.mainBranch
        $this.Origin = $project.origin
        $this.ScmRepoId = $project.scmRepoId
        $this.RepoId = $project.repoId
        $this.Tags = $project.tags
  
        try { 
            $this.TagsString = $null
            foreach ($tag in $project.tags.GetEnumerator()) { 
                if (-NOT ([string]::IsNullOrEmpty($this.TagsString))) { $this.TagsString += ";" }
                if ($tag.Value -eq "") { $this.TagsString += $tag.Key }
                else { $this.TagsString += $tag.Key + ":" + $tag.Value }     
            }
        }
        catch {}

        $this.Criticality = $project.criticality
        $this.PrivatePackage = [bool]$project.privatePackage
        $this.ImportedProjName = $project.imported_proj_name
        $this.ApplicationIds = $project.applicationIds

        try { $this.ApplicationIdsString = ($project.applicationIds) -join ";" }
        catch { $this.ApplicationIdsString = $null }
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Public Methods
    
    [void]AddBranches([Array]$branches) {
        $this.Branches += $branches
        foreach ($branch in $branches) { 
            if ($null -ne $this.BranchesString) { $this.BranchesString += ";" }
            $this.BranchesString += $branch
        }
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class Projects {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [System.Collections.Generic.Dictionary[String, Project]]$ProjectsHash

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Variables

    Hidden [Int]$Offset
    Hidden [Int]$Limit = 2000
    Hidden [Int]$FilteredTotalCount
    Hidden [Int]$TotalCount

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    #Get All Projects
    Projects([CxOneConnection]$conn, [switch]$getBranches) { $this.GetProjectsHash($conn, $null, $null, $getBranches) }
    
    #Get filtered List of projects - Using both Name and ID will not return any values
    Projects([CxOneConnection]$conn, [String]$projectIds, [String]$projectNames, [switch]$getBranches) { 
        $this.GetProjectsHash($conn, $projectIds, $projectNames, $getBranches)
    }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods

    [void] Hidden GetProjectsHash([CxOneConnection]$conn, [String]$projectIds, [String]$projectNames, [switch]$getBranches) {
        
        Write-Verbose "Retrieving projects"

        $this.Offset = 0
        $this.projectsHash= [System.Collections.Generic.Dictionary[String, Project]]::New()

        do {
    
            Write-Verbose "Retrieving projects Offset=$($this.Offset)"
        
            $uri = "$($conn.baseUri)/api/projects/?offset=$($this.Offset)&limit=$($this.Limit)"
        
            if ($projectNames) {
                $projectNames -split "," | ForEach-Object { $uri += "&names=$([uri]::EscapeUriString($_))" }
            }

            if ($projectIds) {
                $projectIds -split "," | ForEach-Object { $uri += "&ids=$([uri]::EscapeUriString($_))" }
            }
            
            $response = ApiCall { Invoke-WebRequest $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
            $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::New()
            $serializer.MaxJsonLength = [int]::MaxValue
            $json = $serializer.DeserializeObject($response)

        
            if ($this.Offset -eq 0) { 
                $this.FilteredTotalCount = $json.filteredTotalCount
                $this.TotalCount = $json.totalCount   
            }

            foreach ($p in $json.projects) { $this.ProjectsHash.Add($p.id, [Project]::new($p)) }

            Write-Verbose "$($this.Limit) Projects Retrieved with Offset: $($this.Offset)"
            $this.Offset += $this.Limit
            
        } while ($this.Offset -lt $this.filteredTotalCount)

        if ($getBranches) { $this.GetBranches($conn) }
    }

    [void] Hidden GetBranches([CxOneConnection]$conn) {
        
        foreach ($p in $this.ProjectsHash.keys) {
            
            $this.Offset = 0
            $continue = $false
            
            do {
                $uri = "$($conn.baseUri)/api/projects/branches?offset=$($this.Offset)&limit=$($this.Limit)&project-id=$p"
                $response = ApiCall { Invoke-RestMethod $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn

                if ($response -ne "null") {
                    $this.ProjectsHash[$p].AddBranches($response)
                    $this.Offset += $this.Limit
                    $continue = $true
                }
                else { $continue = $false }
            
            } while ($continue)
        }
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Application Classes

class Application {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables    
        
    [String]$ApplicationID
    [String]$ApplicationName
    [String]$Description
    [Nullable[datetime]]$CreatedAt
    [Nullable[datetime]]$UpdatedAt
    [Int]$Criticality
    [System.Collections.IDictionary]$Tags
    [string]$TagsString
    [Array]$ProjectIds
    [Array]$ProjectIdsString
    [String]$ProjectNames
    [String]$RiskScore
    [String]$RiskSeverity

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    Application ([PSCustomObject]$application, [System.Collections.Generic.Dictionary[String, Project]]$projects) { 
        $this.SetVariables($application, $projects) 
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([PSCustomObject]$application, [System.Collections.Generic.Dictionary[String, Project]]$projects) {
           
        $this.ApplicationID = $application.id        
        $this.ApplicationName = $application.name
        $this.Description = $application.description
        
        try { $this.CreatedAt = [DateTime]$application.createdAt }
        catch { $this.CreatedAt = $null }
    
        try { $this.UpdatedAt = [DateTime]$application.updatedAt }
        catch { $this.UpdatedAt = $null }
                       
        $this.Criticality = $application.criticality
        $this.Tags = $application.tags
  
        try { 
            $this.TagsString = $null
            foreach ($tag in $application.tags.GetEnumerator()) { 
                if (-NOT ([string]::IsNullOrEmpty($this.TagsString))) { $this.TagsString += ";" }
                if ($tag.Value -eq "") { $this.TagsString += $tag.Key }
                else { $this.TagsString += $tag.Key + ":" + $tag.Value }     
            }
        }
        catch {}

        $this.ProjectIds = $application.projectIds
        try { $this.ProjectIdsString = ($application.projectIds) -join ";" }
        catch { $this.ProjectIdsString = $null }

        foreach ($pid in $application.projectIds) {
            if (-NOT [String]::IsNullOrEmpty($this.ProjectNames)) { $this.ProjectNames += ";" }
            $this.ProjectNames += $projects[$pid].ProjectName
        }
    }

    [void] Hidden AddRisk([PSCustomObject]$obj) {   
        $this.RiskScore = $obj.riskScore
        $this.RiskSeverity = $obj.riskSeverity
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class Applications {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [System.Collections.Generic.Dictionary[String, Application]]$ApplicationsHash

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Variables

    Hidden [Int]$Offset
    Hidden [Int]$Limit = 2000
    Hidden [Int]$FilteredTotalCount
    Hidden [Int]$TotalCount

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    #Get All Applications
    Applications([CxOneConnection]$conn, [Switch]$getRisk ) { $this.GetApplicationsHash($conn, [Switch]$getRisk ) }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods

    [void] Hidden GetApplicationsHash([CxOneConnection]$conn, [Switch]$getRisk ) {
        
        Write-Verbose "Retrieving Applications"

        $projects = Get-AllProjects $conn

        $this.Offset = 0
        $this.ApplicationsHash = [System.Collections.Generic.Dictionary[String, Application]]::New()

        do {
    
            Write-Verbose "Retrieving applications Offset=$($this.Offset)"
        
            $uri = "$($conn.baseUri)/api/applications/?offset=$($this.Offset)&limit=$($this.Limit)"
        
            
            $response = ApiCall { Invoke-WebRequest $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
            $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::New()
            $serializer.MaxJsonLength = [int]::MaxValue
            $json = $serializer.DeserializeObject($response) 
        
            if ($this.Offset -eq 0) { 
                $this.FilteredTotalCount = $json.filteredTotalCount
                $this.TotalCount = $json.totalCount   
            }

            foreach ($app in $json.applications) { $this.ApplicationsHash.Add($app.id, [Application]::new($app, $projects)) }

            Write-Verbose "$($this.Limit) Applications Retrieved with Offset: $($this.Offset)"
            $this.Offset += $this.Limit
            
        } while ($this.Offset -lt $this.filteredTotalCount)
        
        if ($getRisk) { $this.GetRisks($conn) }
    }
    
    [void] Hidden GetRisks([CxOneConnection]$conn) {
        
        Write-Verbose "Retrieving applications risks"
        
        $uri = "$($conn.baseUri)/api/risk-management/summary"
        $response = ApiCall { Invoke-RestMethod $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
        foreach ($app in $response.summary) { $this.ApplicationsHash[$app.id].AddRisk($app) }
        
        Write-Verbose "Applications risks retrived"
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Scans

Class Status {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [String]$EngineName
    [String]$Status
    [String]$Details
    [Nullable[Datetime]]$StartDate
    [Nullable[Datetime]]$EndDate
    [Nullable[Timespan]]$Runtime

    #endregion    
    #--------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    Status() {}

    Status ([System.Collections.IDictionary]$status) { $this.SetVariables($status) }

    #endregion
    #--------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods

    [void] Hidden SetVariables([System.Collections.IDictionary]$status) {
        
        $this.EngineName = $status.name
        $this.Status = $status.status
        $this.Details = $status.details
        
        try { $this.StartDate = [DateTime]$status.startDate }
        catch {}

        try { $this.EndDate = [DateTime]$status.endDate }
        catch {}

        try { $this.Runtime = New-TimeSpan –Start $this.StartDate –End $this.EndDate }
        catch {}
    }
    
    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

Class Scan {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [String]$ScanID
    [String]$ProjectId
    [String]$ProjectName
    [String]$Status
    [String]$Branch
    [String]$Loc
    [System.Collections.Generic.List[Status]]$Statuses
    [Nullable[Datetime]]$CreatedAt
    [Nullable[Datetime]]$UpdatedAt
    [Nullable[Datetime]]$StartDate
    [Nullable[Datetime]]$EndDate
    [Nullable[Timespan]]$Runtime
    [Array]$Engines 
    [String]$EnginesString
    [String]$UserAgent
    [String]$Initiator
    [System.Collections.IDictionary]$Tags
    [String]$TagsString
    [String]$SourceType
    [String]$SourceOrigin
    [String]$RecalcStatus

    #endregion    
    #--------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    Scan() {}

    Scan ([System.Collections.IDictionary]$scan) { $this.SetVariables($scan) }

    #endregion
    #--------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods

    [void] Hidden SetVariables([System.Collections.IDictionary]$scan) {
           
        $this.ScanID = $scan.id
        $this.ProjectId = $scan.projectId
        $this.ProjectName = $scan.projectName
        $this.Status = $scan.status
        $this.Branch = $scan.branch
        
        $this.Statuses = [System.Collections.Generic.List[Status]]::New()
        Foreach ($status in $scan.statusDetails) { 
            if ($status.name -eq "sast") { $this.Loc = $status.loc }
            if ($status.name -eq "general") {
                try { $this.StartDate = [DateTime]$status.startDate }
                catch {}

                try { $this.EndDate = [DateTime]$status.endDate }
                catch {}

                try { $this.Runtime = New-TimeSpan –Start $this.StartDate –End $this.EndDate }
                catch {}
            }
            if ($status.name -ne "general") { $this.Statuses.Add([Status]::new($status)) 
            }
        }

        try { $this.CreatedAt = [DateTime]$scan.createdAt }
        catch {}

        try { $this.UpdatedAt = [DateTime]$scan.updatedAt }
        catch {}

        $this.Engines = $scan.engines
        try { 
            $this.EnginesString = (($scan.engines) -join ",")
        }
        catch {}

        $this.UserAgent = $scan.userAgent
        $this.Initiator = $scan.initiator
        $this.Tags = $scan.tags

        try {         
            $this.TagsString = $null
            foreach ($tag in $scan.tags.GetEnumerator()) { 
                if ($null -ne $this.TagsString) { $this.TagsString += ";" }
                if ($tag.Value -eq "") { $this.TagsString += $tag.Key }
                else { $this.TagsString += $tag.Key + ":" + $tag.Value }     
            }
        }
        catch {}

        $this.SourceType = $scan.sourceType
        $this.SourceOrigin = $scan.sourceOrigin
        $this.RecalcStatus = $scan.recalcStatus
    }
    
    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class Scans {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [System.Collections.Generic.Dictionary[String, Scan]]$ScansHash

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Variables

    Hidden [Int]$Offset = 0
    Hidden [Int]$Limit = 2000
    Hidden [Int]$FilteredTotalCount
    Hidden [Int]$TotalCount

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    #Get All Scans
    Scans() {}
    
    #Get scnas with no filters
    Scans([CxOneConnection]$conn) { $this.GetScansHash($conn, $null, $null, $null, $null) }

    #Get Last scans for given hash of projects with option to filter by main branch
    Scans([CxOneConnection]$conn, [System.Collections.Generic.Dictionary[String, Project]]$projectsHash, 
          [Switch]$useMainBranch, [String]$branchesCSV) { 
        $this.GetLastScansHash($conn , $projectsHash, $useMainBranch, $branchesCSV)
    }
       
    #Get List of scans filtered by status
    Scans([CxOneConnection]$conn, [String]$statuses) { $this.GetScansHash($conn, $statuses, $null, $null, $null, $null) }
    
    #Get List of scans filtered by statuses and Scan Ids
    Scans([CxOneConnection]$conn, [String]$statuses, [String]$scanIds) { $this.GetScansHash($conn, $statuses, $null, $null, $scanIds, $null) }
    
    #Get List of scans filtered by statuses and Projects Hash
    Scans([CxOneConnection]$conn, [String]$statuses, [System.Collections.Generic.Dictionary[String, Project]]$projectsHash) { 
        $this.GetScansHash($conn, $statuses, $null, $null, $null, $projectsHash) 
    }

    #Get List of scans filitered by statuses and number of days
    Scans([CxOneConnection]$conn, [String]$statuses, [Int]$scanDays) { $this.GetScansHashByDays($conn, $statuses, $scanDays, $null) }

    #Get List of scans filitered by statuses between two dates
    Scans([CxOneConnection]$conn, [String]$statuses, [string]$fromDate, [string]$toDate) { 
        $this.GetScansHash($conn, $statuses, $fromDate, $toDate, $null, $null) 
    }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden GetScansHashByDays([CxOneConnection]$conn, [String]$statuses, [Int]$scanDays, [String]$scanIds) {
        $fromDate = [uri]::EscapeDataString(([datetime]::Today).AddDays(-$scanDays).ToString("yyyy-MM-ddThh:mm:ss.fffffffZ"))
        $this.GetScansHash($conn, $statuses, $fromDate, $null, $null, $null)
    } 
    
    [void] Hidden GetScansHash([CxOneConnection]$conn, [String]$statuses, [string]$fromDate, [string]$toDate, 
                               [String]$scanIds, [System.Collections.Generic.Dictionary[String, Project]]$projectsHash) {
        
        Write-Verbose "Retrieving scans"

        $this.Offset = 0
        $this.ScansHash = [System.Collections.Generic.Dictionary[String, Scan]]::New()
        
        do {
    
            Write-Verbose "Retrieving scans Offset=$($this.Offset)"
        
            $uri = "$($conn.baseUri)/api/scans/?offset=$($this.Offset)&limit=$($this.Limit)"
            if ($fromDate) { $uri += "&from-date=$fromDate" }
            if ($toDate) { $uri += "&to-date=$toDate" }        
            if ($statuses -ne "All") { $uri += "&statuses=$statuses" }
            if ($scanIds) { $uri += "&scan-ids=$scanIds" }
            if ($projectsHash) { $uri += "&project-ids=$($projectsHash.keys -join ",")" }
           
            $response = ApiCall { Invoke-WebRequest $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
            $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::New()
            $serializer.MaxJsonLength = [int]::MaxValue
            $json = $serializer.DeserializeObject($response)
        
            if ($this.Offset -eq 0) { 
                $this.FilteredTotalCount = $json.filteredTotalCount
                $this.TotalCount = $json.totalCount   
            }

            foreach ($scan in $json.scans) { $this.ScansHash.Add($scan.id, [Scan]::new($scan)) }

            Write-Verbose "$($this.Limit) Scans Retrieved with Offset: $($this.Offset)"
            $this.Offset += $this.Limit
            
        } while ($this.Offset -lt $this.filteredTotalCount)
    }

    [void] Hidden GetLastScansHash([CxOneConnection]$conn, [System.Collections.Generic.Dictionary[String, Project]]$projectsHash,
                                   [switch] $useMainBranch, [string]$branchesCSV) {
        
        $this.Offset = 0
        $this.ScansHash= [System.Collections.Generic.DIctionary[String, Scan]]::New()
        $branches = @()

        #Load branaches filter from csv if present
        if (-NOT $useMainBranch -AND -NOT [string]::IsNullOrEmpty($branchesCSV)) {
            Write-Verbose "Retrieving branches listing from branches CSV"
            try { $branches = Import-Csv -Path $branchesCSV }
            catch {
                $s = $_ | Format-List * -Force | Out-String
                Write-host $s -f red
                exit
            }
            Write-Verbose "branches listing loaded"
        }

        foreach ($p in $projectsHash.values) {

            $uri = "$($conn.BaseURI)/api/projects/last-scan?project-ids=$($p.ProjectID)" +
                   "&scan-status=Completed&use-main-branch=$($useMainBranch.toString())"

    
            if ($branches) {
                $branchName = ($branches | Where-Object { $_.Projects -eq $p.ProjectName }).Branches
                if ($branchName -Is [Array]) {
                    Write-host "The file $branchesCSV can only contain one entry per project. PLease correct and retry" -f red
                    exit
                }
                if (-NOT [string]::IsNullOrEmpty($branchName)) { $uri += "&branch=$branchName" }
            }

            $response = ApiCall { Invoke-WebRequest $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
            $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::New()
            $serializer.MaxJsonLength = [int]::MaxValue
            $json = $serializer.DeserializeObject($response)
            
            $scan = $json[$p.projectId]
            if ($null -eq $scan) { $this.ScansHash.Add($p.projectId, $null) }
            else { 
                $scan.Add("projectId", $p.projectId)
                $scan.Add("projectName", $p.ProjectName)

                $this.ScansHash.Add($p.projectId, [Scan]::new($scan))
            } 
        }
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region Results Classes

class Result {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [string]$Type
    [string]$Id
	[string]$SimilarityId
    [string]$AlternateId
	[string]$Status
	[string]$State
	[string]$Severity
	[Nullable[datetime]]$Created
	[Nullable[datetime]]$FirstFoundAt
	[DateTime]$FoundAt
	[string]$FirstScanID
    [string]$Description

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    Result() {}

    Result ([PSCustomObject]$result) { $this.SetCommonVariables($result) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetCommonVariables([PSCustomObject]$result) {
           
        $this.Type = $result.type
        $this.Id = $result.id
        $this.SimilarityId = $result.similarityId
        $this.Status = $result.status
        $this.State = $result.state
        $this.Severity = $result.severity
        
        try { $this.Created = [DateTime]$result.created }
        catch {}

        try { $this.FirstFoundAt = [DateTime]$result.firstFoundAt }
        catch {}

        try { $this.FoundAt = [DateTime]$result.foundAt }
        catch {}

        $this.FirstScanID = $result.firstScanId
        $this.Description = $result.description
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class SastResult : Result {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [string]$QueryName
    [string]$QueryGroup
    [string]$LanguageName
    [string]$CweId
    [string]$Compliances
  
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors
    
    SastResult() {}

    SastResult ([PSCustomObject]$result): base($result) { $this.SetVariables($result) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([PSCustomObject]$result) {
        $this.QueryName = $result.data.queryName
        $this.QueryGroup = $result.data.group
        $this.LanguageName = $result.data.languageName
        $this.CweId = $result.vulnerabilityDetails.cweId
        $this.Compliances = $result.vulnerabilityDetails.compliances -join ";"
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class KicsResult : Result {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [string]$QueryName
    [string]$QueryGroup
    [string]$QueryUrl
    [string]$FileName
    [string]$Line
    [string]$Platform
    [string]$IssueType
    [string]$ExpectedValue
    [string]$Value
  
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors
    
    KicsResult() {}

    KicsResult ([PSCustomObject]$result): base($result) { $this.SetVariables($result) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([PSCustomObject]$result) {
        $this.QueryName = $result.data.queryName
        $this.QueryGroup = $result.data.group
        $this.QueryUrl = $result.data.queryUrl
        $this.FileName = $result.data.fileName
        $this.Line = $result.data.line
        $this.QueryUrl = $result.data.platform
        $this.IssueType = $result.data.issueType
        $this.ExpectedValue = $result.data.expectedValue
        $this.Value = $result.data.value        
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class ContainerResult : Result {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [string]$PackageName
    [string]$PackageVersion
    [string]$ImageName
    [string]$ImageTag
    [string]$ImageFilePath
    [string]$ImageOrigin
    [string]$Score
    [string]$CveName
    [string]$CweId
    [string]$CvssScope
    [string]$CvssScore
    [string]$CvssSeverity
    [string]$CvssAttackVector
    [string]$CvssIntegrityImpact
    [string]$CvssUserInteraction
    [string]$CvssAttackComplexity
    [string]$CvssAvailabilityImpact  
    [string]$CvssPrivilegesRequired
    [string]$CvssConfidentialityImpact     
  
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors
    
    ContainerResult() {}

    ContainerResult ([PSCustomObject]$result): base($result) { $this.SetVariables($result) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([PSCustomObject]$result) {
        $this.PackageName = $result.data.packageName
        $this.PackageVersion = $result.data.packageVersion
        $this.ImageName = $result.data.imageName
        $this.ImageTag = $result.data.imageTag
        $this.ImageFilePath = $result.data.imageFilePath
        $this.ImageOrigin = $result.data.imageOrigin
        
        $this.CvssScore = $result.vulnerabilityDetails.cvssScore
        $this.CveName = $result.vulnerabilityDetails.cveName
        $this.CweId = $result.vulnerabilityDetails.cweId
        
        $this.CvssScope = $result.vulnerabilityDetails.cvss.scope
        $this.CvssScore = $result.vulnerabilityDetails.cvss.score      
        $this.CvssSeverity = $result.vulnerabilityDetails.cvss.severity
        $this.CvssAttackVector = $result.vulnerabilityDetails.cvss.attack_vector
        $this.CvssIntegrityImpact = $result.vulnerabilityDetails.cvss.integrity_impact
        $this.CvssUserInteraction = $result.vulnerabilityDetails.cvss.user_interaction
        $this.CvssAttackComplexity = $result.vulnerabilityDetails.cvss.attack_complexity
        $this.CvssAvailabilityImpact = $result.vulnerabilityDetails.cvss.availability_impact
        $this.CvssPrivilegesRequired = $result.vulnerabilityDetails.cvss.privileges_required
        $this.CvssConfidentialityImpact = $result.vulnerabilityDetails.cvss.confidentiality_impact
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class ScaResult : Result {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [string]$PackageIdentifier
    [string]$PublishedAt
    [string]$Recommendations
    [string]$RecommendedVersion
    [string]$ExploitableMethods

    [string]$Score
    [string]$CveName
    [string]$CweId
    [string]$CvssScope
    [string]$CvssScore
    [string]$CvssVersion
    [string]$CvssSeverity
    [string]$CvssIntegrity
    [string]$CvssAttackVector
    [string]$CvssAvailability
    [string]$CvssConfidentiality
    [string]$CvssUserInteraction
    [string]$CvssAttackComplexity
    [string]$CvssPrivilegesRequired
    
  
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors
    
    ScaResult() {}

    ScaResult ([PSCustomObject]$result): base($result) { $this.SetVariables($result) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([PSCustomObject]$result) {
        $this.PackageIdentifier = $result.data.packageIdentifier
        
        try { $this.PublishedAt = [DateTime]$result.data.publishedAt }
        catch {}
        
        $this.Recommendations = $result.data.recommendations
        $this.RecommendedVersion = $result.data.recommendedVersion
        
        if ($null -eq $result.data.exploitableMethods) { $this.ExploitableMethods = "false" }
        else { $this.ExploitableMethods = "true" }
        
        $this.Score = $result.vulnerabilityDetails.cvssScore
        $this.CveName = $result.vulnerabilityDetails.cveName
        $this.CweId = $result.vulnerabilityDetails.cweId
        
        $this.CvssScope = $result.vulnerabilityDetails.cvss.scope
        $this.CvssScore = $result.vulnerabilityDetails.Cvss.score
        $this.CvssVersion = $result.vulnerabilityDetails.Cvss.version
        $this.CvssSeverity = $result.vulnerabilityDetails.cvss.severity
        $this.CvssIntegrity = $result.vulnerabilityDetails.cvss.integrity
        $this.CvssAttackVector = $result.vulnerabilityDetails.cvss.attackVector
        $this.CvssAvailability = $result.vulnerabilityDetails.cvss.availability
        $this.CvssConfidentiality = $result.vulnerabilityDetails.cvss.confidentiality 
        $this.CvssUserInteraction = $result.vulnerabilityDetails.cvss.userInteraction
        $this.CvssAttackComplexity = $result.vulnerabilityDetails.cvss.attackComplexity
        $this.CvssPrivilegesRequired = $result.vulnerabilityDetails.cvss.privilegesRequired
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class SscsResult : Result {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [string]$Type
    [string]$RuleId
    [string]$RuleName
    [string]$FileName
    [string]$Line
    [string]$Snippet
    [string]$SlsaStep
    [string]$RuleDescription
    [string]$Remediation
    [string]$RemediationLink
    [string]$RemediationAdditional
    [string]$Validity
  
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors
    
    SscsResult() {}

    SscsResult ([String]$type, [PSCustomObject]$result): base($result) { $this.SetVariables($type, $result) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([String]$type,[PSCustomObject]$result) {
        $this.Type = $type
        $this.RuleId = $result.data.ruleId
        $this.RuleName = $result.data.ruleName
        $this.FileName = $result.data.fileName
        $this.Line = $result.data.line
        $this.Snippet = $result.data.snippet
        $this.SlsaStep = $result.data.slsaStep
        $this.RuleDescription = $result.data.ruleDescription
        $this.Remediation = $result.data.remediation
        $this.RemediationLink = $result.data.remediationLink
        $this.RemediationAdditional = $result.data.remediationAdditional
        $this.Validity = $result.data.validity        
    }

    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

Class Results {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [System.Collections.Generic.List[Result]]$ResultsList
    [Int]$TotalCount

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Variables

    Hidden [Int]$Offset
    Hidden [Int]$Limit = 2000

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    #Get All Results 
    Results([CxOneConnection]$conn, [String]$scanId) { $this.GetResultsList($conn, $scanId) }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods

    [void] Hidden GetResultsList([CxOneConnection]$conn, [String]$scanId) {
        
        Write-Verbose "Retrieving results"

        $this.Offset = 0
        $this.ResultsList = [System.Collections.Generic.List[Result]]::New()

        do {
    
            Write-Verbose "Retrieving results Offset=$($this.Offset)"
        
            $uri = "$($conn.baseUri)/api/results/?scan-id=$scanId&offset=$($this.Offset)&limit=$($this.Limit)"
            
            $response = ApiCall { Invoke-RestMethod $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
        
            if ($this.Offset -eq 0) { $this.TotalCount = $response.totalCount }

            foreach ($r in $response.results) { 
                switch ($r.type) {
                    "sast" { $this.ResultsList.Add([SastResult]::new($r)) }
                    "kics" { $this.ResultsList.Add([KicsResult]::new($r)) }
                    "containers" { $this.ResultsList.Add([ContainerResult]::new($r)) }
                    "sca" { $this.ResultsList.Add([ScaResult]::new($r)) }
                    "sscs-scorecard" { $this.ResultsList.Add([SscsResult]::new("scorecard",$r)) }
                    "sscs-secret-detection" { $this.ResultsList.Add([SscsResult]::new("secret",$r)) }
                    default { $this.ResultsList.Add([Result]::new($r)) }
                }
            }

            Write-Verbose "$($this.Limit) Results Retrieved with Offset: $($this.Offset)"
            $this.Offset++
            
        } while ($this.Offset * $this.Limit -lt $this.TotalCount)
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------
#region SeverityCounters Classes

class SeverityCount {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables
    
    [HashTable]$Totals  
    [HashTable]$Sast
    [HashTable]$Kics
    [HashTable]$Sca
    [HashTable]$Packages
    [HashTable]$Api
    [HashTable]$SSCS  
    [HashTable]$Containers
    
    #endregion    
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Variables
        
        [Int]$Total
        [Int]$TotalCritical
        [Int]$TotalHigh
        [Int]$TotalMedium
        [Int]$TotalLow
        [Int]$TotalInfo

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    SeverityCount ([Array]$summary) { $this.SetVariables($summary) }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods
    
    [void] Hidden SetVariables([Array]$summary) {
                
        $this.Sast = $this.CreateHashAndIncrementTotal($summary.sastCounters.totalCounter)    
        $this.SetCounts($summary.sastCounters.severityCounters, $this.Sast)

        $this.Kics = $this.CreateHashAndIncrementTotal($summary.kicsCounters.totalCounter) 
        $this.SetCounts($summary.kicsCounters.severityCounters, $this.Kics)

        $this.Sca = $this.CreateHashAndIncrementTotal($summary.scaCounters.totalCounter)
        $this.SetCounts($summary.scaCounters.severityCounters, $this.Sca)
        
        $this.Packages = $this.CreateHashAndIncrementTotal($summary.scaPackagesCounters.totalCounter)
        if ($summary.scaPackagesCounters.totalPackagesCounter) { 
            $this.Packages.Add("Total Packages", $summary.scaPackagesCounters.totalPackagesCounter)
        }
        else { $this.Packages.Add("Total Packages", $null) }
        if ($summary.scaPackagesCounters.outdatedCounter) {
            $this.Packages.Add("Outdated Packages", $summary.scaPackagesCounters.outdatedCounter)
        }
        else { $this.Packages.Add("Outdated Packages", $null) }
        $this.SetCounts($summary.scaPackagesCounters.severityCounters, $this.Packages)

        $this.Api = $this.CreateHashAndIncrementTotal($summary.apiSecCounters.totalCounter)
        $this.SetCounts($summary.apiSecCounters.severityCounters, $this.Api)

        $this.SSCS = $this.CreateHashAndIncrementTotal($summary.microEnginesCounters.totalCounter)
        $this.SetCounts($summary.microEnginesCounters.severityCounters, $this.SSCS)

        $this.Containers = $this.CreateHashAndIncrementTotal($summary.containersCounters.totalCounter)
        $this.SetCounts($summary.containersCounters.severityCounters, $this.Containers)

        $this.Totals = @{
            total = $this.Total
            Critical = $this.TotalCritical
            High = $this.TotalHigh
            Medium = $this.TotalMedium
            Low = $this.TotalLow
            Info = $this.TotalInfo
        }
    }

    [Hashtable] Hidden CreateHashAndIncrementTotal ( [Nullable[System.Int32]] $totalCount) { 
        $this.Total += $totalCount
        if ($totalCount -eq 0) { $totalCount = $null }
            return @{ 
                total = $totalCount
                Critical = $null
                High = $null
                Medium = $null
                Low = $null
                Info = $null
        }
    }

    [void] Hidden SetCounts([Array]$severityCounter, [Hashtable]$hash) {
        foreach ($sc in $severityCounter) {
            switch ($sc.severity) {
                'CRITICAL' { 
                    $hash.Critical = $sc.counter
                    $this.TotalCritical += $sc.counter
                }
                'HIGH' { 
                    $hash.High = $sc.counter
                    $this.TotalHigh += $sc.counter
                }
                'MEDIUM' { 
                    $hash.Medium = $sc.counter
                    $this.TotalMedium += $sc.counter
                }
                'LOW' { 
                    $hash.Low = $sc.counter
                    $this.TotalLow += $sc.counter
                }
                'INFO' { 
                    $hash.Info = $sc.counter
                    $this.TotalInfo += $sc.counter
                }
            }
        }
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

class SeverityCounters {
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Variables

    [System.Collections.Generic.Dictionary[String, SeverityCount]]$SeverityCountersHash

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Constructors

    #Get All Results 
    SeverityCounters([CxOneConnection]$conn, [System.Collections.Generic.Dictionary[String, Scan]]$ScansHash) { 
        $this.GetSeverityCountersHash($conn, $ScansHash) 
    }
    
    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
    #region Hidden Methods

    Hidden [void] GetSeverityCountersHash([CxOneConnection]$conn, [System.Collections.Generic.Dictionary[String, Scan]]$ScansHash) {

        $this.SeverityCountersHash = [System.Collections.Generic.Dictionary[String, SeverityCount]]::New()
        
        foreach ($scan in $ScansHash.values) {    
            $uri = "$($conn.BaseURI)/api/scan-summary/?scan-ids=$($scan.ScanID)"
            $response = ApiCall { Invoke-RestMethod $uri -Method GET -Headers $conn.Headers -UseBasicParsing } $conn
            $this.SeverityCountersHash.Add($scan.ScanID, [SeverityCount]::new($response.scansSummaries))
        }
    }

    #endregion
    #------------------------------------------------------------------------------------------------------------------------------------------------
}

#endregion
#----------------------------------------------------------------------------------------------------------------------------------------------------