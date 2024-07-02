#to Run, boot OSDCloudUSB, at the PS Prompt: iex (irm win10.wclc.com)
$ScriptName = 'win10.wclc.com'
$ScriptVersion = '1.0'
Write-Host -ForegroundColor Green "$ScriptName $ScriptVersion"
#iex (irm functions.wclc.com) #Add custom functions used in Script Hosting in GitHub
#iex (irm functions.osdcloud.com) #Add custom fucntions from OSDCloud

# Script start
Write-Host -ForegroundColor Cyan "Starting WCLC's Custom OSDCloud ..."
Start-Sleep -Seconds 5

# Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

# Make sure I have the latest OSD Content
Write-Host -ForegroundColor Cyan "Updating the OSD PowerShell Module"
Install-Module OSD -Force

Write-Host -ForegroundColor Cyan "Importing the OSD PowerShell Module"
Import-Module OSD -Force

# Start OSDCloud with custom parameters
Write-Host -ForegroundColor Cyan "Start OSDCloud with WCLC's Parameters"
Start-OSDCloud -OSName 'Windows 10 22H2 x64' -OSLanguage en-us -OSEdition Pro -OSActivation Retail -ZTI -Verbose

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
