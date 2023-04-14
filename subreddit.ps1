
#Display the most recent 26 users that have posted (and at what time) in any Subreddit. Searches in "r/powershell" by default
function Get-RecentUsers {
    param (
        [string]$SubReddit = "powershell"
    )

    #Retrieve JSON of most recent posters/authors in the subreddit
    $url = "https://www.reddit.com/r/$SubReddit/.json"
    $R= Invoke-WebRequest -Uri $url -Headers $headers -ContentType "application/json" -Method Get -UseBasicParsing
    $x = $R.Content | Out-String | ConvertFrom-Json
    $authorlist = @()
    $timeslist = @()

    #Create datetime object for unix time conversion
    $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    [datetime]$origin = '1970-01-01 00:00:00'

    #loop through JSON to get users and times
    $children = $x.data.children
    $children | ForEach-Object {
        $_.data | ForEach-Object {
            #Add the author to a list
            $author = $_.author
            $authorlist += $author
            #Add the creation time to a separate list
            $unixtime = $_.created
            $actualtime = $origin.AddSeconds($unixtime)
            $timeslist += $actualtime
        }
    }

    #Put the author and creation time into a table for display
    $max = ($authorlist, $timeslist | Measure-Object -Maximum -Property Count).Maximum
    0..$max | Select-Object @{n="Author";e={$authorlist[$_]}}, @{n="Date of posting";e={$timeslist[$_]}}

}

#Ermm... Ended up not using this function but would like to keep it... for history
function Format-Results {
    param (
        [string]$authorname,
        [System.DateTime]$actualtimename
    )

    $props = [ordered]@{ 
        author=[string]
        actualtime=[System.DateTime]
    }

    $ReportObj = New-Object -TypeName PSObject -Property $props
    $ReportObj.author = $authorname
    $ReportObj.actualtime = $actualtimename

}

Get-RecentUsers
