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
Start-OSDCloud "-ZTI -OSName 'Windows 10 22H2 x64' -OSLanguage en-us -OSEdition Pro -OSActivation Retail" -CloudDriver HP,LenovoDock,IntelNet,USB,WiFi -Verbose

# Custom OOBE configuration
Write-Host -ForegroundColor Cyan "Applying custom OOBE settings"

# Unattend.xml content
$unattendXml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>jrZVBZFaF#UBHK95</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>jrZVBZFaF#UBHK95</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Name>Administrator</Name>
                        <Group>Administrators</Group>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <AutoLogon>
                <Password>
                    <Value>jrZVBZFaF#UBHK95</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>Administrator</Username>
            </AutoLogon>
            <TimeZone>Central Standard Time</TimeZone>
            <RegisteredOrganization>My Organization</RegisteredOrganization>
            <RegisteredOwner>My Company</RegisteredOwner>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <CommandLine>cmd /c echo Hello World!</CommandLine>
                    <Description>FirstLogon</Description>
                </SynchronousCommand>
            </FirstLogonCommands>
        </component>
    </settings>
</unattend>
"@

# Save unattend.xml to the appropriate location
$unattendPath = "C:\Windows\System32\Sysprep\unattend.xml"
$unattendXml | Out-File -FilePath $unattendPath -Encoding UTF8

# Custom JSON configuration
$jsonConfig = @"
{
    "regionalSettings": {
        "inputLocale": "en-US",
        "systemLocale": "en-US",
        "uiLanguage": "en-US",
        "userLocale": "en-US",
        "timezone": "Central Standard Time"
    },
    "autologin": {
        "enabled": true,
        "username": "Administrator",
        "password": "jrZVBZFaF#UBHK95"
    },
    "organization": "My Organization",
    "location": "Winnipeg, Canada"
}
"@

# Save JSON configuration
$jsonConfigPath = "C:\OSDCloud\config.json"
$jsonConfig | Out-File -FilePath $jsonConfigPath -Encoding UTF8

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
