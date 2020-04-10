# Dynamically generate the Zwift activity file location
$ZwiftFilesPath = "$([Environment]::GetFolderPath("MyDocuments"))\Zwift\Activities"

# This is the file path for the current activity. Not sure if it's needed, but just in case.
$ZwiftInProgressFile = "$ZwiftFilesPath\inProgressActivity.fit"

# Obtain todays date in the format zwift files are saved (e.g. 2020-04-01) in so we can filter on the files to backup.
# The file names are marked with the timestamp as well, but I'll just back up all of todays files
$TodaysDate = Get-Date -Format "yyyy-MM-dd"

# Specify the desktop as the target backup location. I could prompt, but it seemed the easiest location just just specify because everyone knows how to find it (I Hope).
# I've also put the files into a folder specifically for today.
$ZwiftBackupLocation = "$([Environment]::GetFolderPath("Desktop"))\Zwift\Activities\$TodaysDate"

# Set the backup frequency in seconds
[int]$BackupWaitTime = 60 

# Obtain todays date in the format zwift files are saved (e.g. 2020-04-01) in so we can filter on the files to backup.
# The file names are marked with the timestamp as well, but I'll just back up all of todays files
$TodaysDate = Get-Date -Format "yyyy-MM-dd"

# Create backup location if it does not exist
If(-Not(Test-Path $ZwiftBackupLocation)){
    New-Item $ZwiftBackupLocation -Type Directory
}

# Start checking to see if Zwift is running
do {
    "waiting for Zwift to be launched...."
    Start-Sleep -Seconds 10
} until (Get-Process ZwiftLauncher -ErrorAction SilentlyContinue) # Continue looping until PowerShell is closed or Zwift is started

# Now that zwift has started, we can start taking copies of the fit files
# This loop will continue until Zwift.exe terminates
do {
    # I obtain the list in here in the unlucky event that zwift decides to create additional files for the day during the ride
    $LatestZwiftFiles = (Get-ChildItem $ZwiftFilesPath -Filter "$TodaysDate*").FullName
    "Backing up Zwift Activities..."
    If ($Null -ne $LatestZwiftFiles){
        Copy-Item -Path $LatestZwiftFiles -Destination $ZwiftBackupLocation
    }
    Copy-Item -Path $ZwiftInProgressFile -Destination $ZwiftBackupLocation
    # Put in a sleep wait so I only copy the files every minute. This can be adjusted quite easily by changing the seconds.
    
    "Waiting $BackupWaitTime seconds before next backup..."
    Start-Sleep -Seconds $BackupWaitTime
} until ($null -eq (Get-Process ZwiftLauncher -ErrorAction SilentlyContinue)) # Continue looping until PowerShell is closed or Zwift is closed, including the tray icon

# Open backup location in Windows Explorer in case I need to find the fit files that were backed up.
"Opening the folder where todays file have been backed up to"
explorer $ZwiftBackupLocation

