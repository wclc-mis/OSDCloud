#To Run, boot OSDCloudUSB or the WinPE, at the PS Prompt: iex (irm osd.wclc.com)
$ScriptName = 'osd.wclc.com'
$ScriptVersion = '1.1'
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

#Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Product = (Get-MyComputerProduct)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$OSVersion = 'Windows 10' #Used to Determine Driver Pack
$OSReleaseID = '22H2' #Used to Determine Driver Pack
$OSName = 'Windows 10 22H2 x64'
$OSEdition = 'Pro'
$OSActivation = 'Retail'
$OSLanguage = 'en-us'

$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$false  #Disables OSDCloud automatically restarting
    RecoveryPartition = [bool]$true #Ensures a Recover partition is created, True is default unless on VM
    OEMActivation = [bool]$true #Attempts to look up the Windows Code in UEFI and activate Windows OS (SetupComplete Phase)
    WindowsUpdate = [bool]$true #Runs Windows Updates during Setup Complete
    WindowsUpdateDrivers = [bool]$true #Runs WU for Drivers during Setup Complete
    WindowsDefenderUpdate = [bool]$true #Run Defender Platform and Def updates during Setup Complete
    SetTimeZone = [bool]$true #Set the Timezone based on the IP Address
    ClearDiskConfirm = [bool]$false #Skip the Confirmation for wiping drive before format
    SyncMSUpCatDriverUSB = [bool]$true #Sync any MS Update Drivers during WinPE to Flash Drive, saves time in future runs
    ZTI = [bool]$true # Enables zero-touch 
    GetFeatureUpdate = [bool]$true # Enables any Windows 10 22H2 features if needed
    SkipAutopilot = [bool]$true  # Set SkipAutopilot to true
    SkipODT = [bool]$false
}

#Used to Determine Driver Pack
$DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID

if ($DriverPack){
    $Global:MyOSDCloud.DriverPackName = $DriverPack.Name
}

#Enable HPIA | Update HP BIOS | Update HP TPM
if (Test-HPIASupport){
    #$Global:MyOSDCloud.DevMode = [bool]$True
    $Global:MyOSDCloud.HPTPMUpdate = [bool]$True
    $Global:MyOSDCloud.HPIAALL = [bool]$true
    $Global:MyOSDCloud.HPBIOSUpdate = [bool]$true

}

#write variables to console
Write-Output $Global:MyOSDCloud

#Launch OSDCloud
Write-Host "Starting OSDCloud" -ForegroundColor Green
Write-host "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage"

Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage

Write-host "OSDCloud Process Complete, Running Custom Actions From Script Before Reboot" -ForegroundColor Green

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
#wpeutil reboot

#Restart Computer from WInPE into Full OS to continue Process
restart-computer
