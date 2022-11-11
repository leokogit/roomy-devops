# serial console

& bcdedit /ems "{current}" on
& bcdedit /emssettings EMSPORT:2 EMSBAUDRATE:115200

# powerplan

& powercfg -setactive "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
& powercfg -change -monitor-timeout-ac 0
& powercfg -change -standby-timeout-ac 0
& powercfg -change -hibernate-timeout-ac 0

# shutdown
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "ShutdownWarningDialogTimeout" -Value 1

# clock
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1 -Type DWord -Force

# icmp
Get-NetFirewallRule -Name "vm-monitoring-icmpv4" | Enable-NetFirewallRule

# invoke userdata at startup
& schtasks /Create /TN "userdata" /RU SYSTEM /SC ONSTART /RL HIGHEST /TR "Powershell -NoProfile -ExecutionPolicy Bypass -Command \`"& {iex (irm -H @{\\\`"Metadata-Flavor\\\`"=\\\`"Google\\\`"} \\\`"http://169.254.169.254/computeMetadata/v1/instance/attributes/user-data\\\`")}\`"" | Out-Null

# Set never expiried Administrator password
Get-LocalUser | Where-Object -Property "SID" -like "S-1-5-21-*-500" | Set-LocalUser -PasswordNeverExpires 1

Get-CimInstance -ClassName Win32_TSGeneralSetting -Namespace root\cimv2\terminalservices | Invoke-CimMethod -MethodName SetUserAuthenticationRequired -Arguments @{ UserAuthenticationRequired = 1 }

Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Get-ScheduledTask -TaskName "ScheduledDefrag" | Disable-ScheduledTask | Out-Null

<#
    .FUNCTIONS
        Functions, used in script below.
#>

function Get-WinrmCertificateThumbPrint {
    $Listner = Get-WinrmHTTPSListener
    return Get-ChildItem "WSMan:\localhost\Listener\$Listner\CertificateThumbPrint" | Select-Object -ExpandProperty Value
}

function Get-WinrmHTTPSListener {
    return Get-ChildItem WSMan:\localhost\Listener\ | Where-Object Keys -contains "Transport=HTTPS" | Select-Object -ExpandProperty Name
}

function New-WinrmCertificate {
    $DnsName = [System.Net.Dns]::GetHostByName($env:computerName).Hostname
    $WindowsVersion = Get-WindowsVersion
    if ($WindowsVersion -match "Windows Server 2012 R2*") {
        # yup, black sheep
        return New-SelfSignedCertificate -CertStoreLocation "Cert:\LocalMachine\My" -DnsName $DnsName
    }

    return New-SelfSignedCertificate -CertStoreLocation "Cert:\LocalMachine\My" -DnsName $DnsName -Subject $ENV:COMPUTERNAME
}

function Get-WindowsVersion {
    return Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" -Name ProductName | Select-Object -ExpandProperty ProductName
}

<#
    .SCRIPT
        Actual script
#>

# Remove old winrm certificate, if any
Remove-Item -Path "Cert:\LocalMachine\My\$CertificateThumbPrint" | Out-Null

# Remove old winrm listeners, if any
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse | Out-Null

# Create Listeners
$Certificate = New-WinrmCertificate

New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Certificate.ThumbPrint -HostName $ENV:COMPUTERNAME -Force | Out-Null
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTP -Address * -HostName $ENV:COMPUTERNAME -Force | Out-Null

# Create allow firewall rules

$WINRMHTTPS = Get-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" -ErrorAction SilentlyContinue

if ($WINRMHTTPS) {
    $WINRMHTTPS | Enable-NetFirewallRule  
}
else {
    $NetFirewallRuleParams = @{
        Group = "Windows Remote Management"
        DisplayName = "Windows Remote Management (HTTPS-In)"
        Name = "WINRM-HTTPS-In-TCP"
        LocalPort = 5986
        Action = "Allow"
        Protocol = "TCP"
        Program = "System"
    }

    New-NetFirewallRule @NetFirewallRuleParams
}

$WINRMHTTPS = Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue

if ($WINRMHTTPS) {
    $WINRMHTTPS | Enable-NetFirewallRule  
}
else {
    $NetFirewallRuleParams = @{
        Group = "Windows Remote Management"
        DisplayName = "Windows Remote Management (HTTP-In)"
        Name = "WINRM-HTTP-In-TCP"
        LocalPort = 5985
        Action = "Allow"
        Protocol = "TCP"
        Program = "System"
    }

    New-NetFirewallRule @NetFirewallRuleParams
}

& del "C:\Windows\Setup\Scripts\" /F /S /Q

Stop-Computer -Force
