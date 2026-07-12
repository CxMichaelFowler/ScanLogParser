This module has been created to simplify common tasks when scritpting for Checkmarx One
   
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
            $response = ApiCall { Invoke-WebRequest $uri -Method GET -Headers $conn.Headers } $conn
    
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
            Connection object is needed for additional calls in module
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
            getLanguages = optional switch to get language metrics when sast engine used
        Parameters
            CxOneConnObj - Checkmarx One connection object
            statuses - CSV string of scan statuses to filter results
            getLanguages - switch
        Example
            $scans = Get-AllScans $conn "Completed","Partial" -getLanguages
            
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
            getLanguages = optional switch to get language metrics when sast engine used
        Parameters
            CxOneConnObj - Checkmarx One connection object
            Statuses - CSV string of scan statuses
            scanDays - Integer value between 0 and 366
            getLanguages - switch
        Example
            $scans = Get-ScansByDays $conn "All","Partial" 90 -getLanguages

    Get-ScansByDates
        Details
            Function to get a hash of all scans between two dates(inclusive), filtered by statuses.
            Key = Scan ID and Value = Scan Object
            Statuses = CSV of Scan statuses to filter results
               Valid Statuses are Queued, Running, Completed, Failed, Partial, Canceled
               If all Statuses are required use "All"
            fromDate = The starting date to return values for
            toDate = The last date to return values for
            getLanguages = optional switch to get language metrics when sast engine used

        Parameters
            CxOneConnObj - Checkmarx One connection object
            Statuses - CSV string of scan statuses
            fromDate - Date string in the format yyyy-MM-dd
            toDate - Date string in the format yyyy-MM-dd
            getLanguages - switch
        Example
            $scans = Get-ScansByDates $conn "Completed","Partial" "2025-01-01" "2025-06-30" -getLanguages
   
    Get-ScansByProjects
        Details
            Function to get a hash scans for a provided hash of project objects
            Key = Scan ID and Value = Scan Object
            getLanguages = optional switch to get language metrics when sast engine used
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectsHash - Hash of projects to return last of. Must be a hash as provided by call above
            getLanguages - switch
        Example
            $scans = Get-ScansByIds $conn $projects -getLanguages

    Get-ScansByIds
        Details
            Function to get a hash scans for a provided as a CSV string of Scan IDs
            Key = Scan ID and Value = Scan Object
            getLanguages = optional switch to get language metrics when sast engine used
        Parameters
            CxOneConnObj - Checkmarx One connection object
            ScanIds - CSV string of scan IDs
            getLanguages - switch
        Example
            $scans = Get-ScansByIds $conn "4bf2d7fc-8a7c-420d-ac1a-7c62cebb7bbb,141cf46f-1781-45ab-8cee-0f5856337b2f" -getLanguages
        
    Get-LastScans
        Details
            Get a hash of the the last scans for the projects provided in the projects hash.
            Key = Project ID and Value = Scan Object
            Optional switch to return last scan for Main Branch (if set)
            getLanguages = optional switch to get language metrics when sast engine used
            Will return null object for projects with no scans
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectsHash - Hash of projects to return last of. Must be a hash as provided by call above
            useMainBranch - optional switch to specify only return last scan on Main branch (if set)
            getLanguages - switch
        Example
            $scans = Get-LastScans $conn $projects -getLanguages
            
    Get-LastScansForGivenBranches
        Details
            Get a hash of the last scan for the projects provided in the projects hash.
            Key = Project ID and Value = Scan Object
            getLanguages = optional switch to get language metrics when sast engine used
            Returns last scan for the branch provided in the CSV file
            Will return null object for projects with no scans
            branchesCSV must be a file path to a CSV with the header Projects,Branches and one project,branch per line
        Parameters
            CxOneConnObj - Checkmarx One connection object
            projectsHash - Hash of projects to return last of. Must be a hash as provided by call above
            branchesCSV - file path to CSV file containing the mapping of projects to primary branch
            getLanguages - switch
        Example
            $scans = Get-LastScansForGivenBranches $conn $projects "C:\files\branches.csv" -getLanguages
            
    Get-ScanResults
        Details
            Get the results for a given scan ID
            Returns a list of result objects
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
