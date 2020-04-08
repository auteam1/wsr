###
#
# This script consists of 3 section, separate through todo comments:
#
# 0. Dependencies
# Section with links to download all needed dependencies
#
# 1. Init
# This block describes all the necessary constants and variables
#
# 2. Main functions
# Function block in which all necessary functions are defined
#
# 3. Start of check
# The verification process itself
#
###

# TODO: 0. Dependencies

# 1. Run powershell as Administrator
#
# 2. Copy and Paste the following script to install this package
# Install-Module -Name VMware.PowerCLI -Force
#
# OR
#
# https://code.vmware.com/web/tool/11.5.0/vmware-powercli

# TODO: 1. Init

$LOGIN_ESXi         = 'root'            # ESXi login
$PASS_ESXi          = 'P@ssw0rd'        # ESXi password
$LOGIN_VM           = 'Administrator'   # VM Login
$PASS_VM            = 'P@ssw0rd'        # VM Password
$DELAY              = 30                # Delay before start VM

# TODO: 2. Main functions

# Function for send Script to VM
# Return a Script output from VM, if all ok
#
# Use: SendScript -VM 'L-SRV' -Script 'hostnamectl' -Description 'Hostname'
Function SendScript
{
  Param( $VM,
         $Script,
         $Description,
         $Username,
         $Password )
 If ($null -ne $Description)
 {
   Write-Output "#########################--=$Description=--#########################" `
   | Out-File $FILE -Append -NoClobber
 }
 Write-Output "Script	     : $Script" | Out-File $FILE -Append -NoClobber
 If ( ($null -eq $Username) -or ($null -eq $Password) )
 {
   $Username = $LOGIN_VM
   $Password = $PASS_VM
 }
 else {
   Write-Output "Username     : $Username" | Out-File $FILE -Append -NoClobber
   Write-Output "Password     : $Password" | Out-File $FILE -Append -NoClobber
 }
  Invoke-VMScript   -vm $VM                                   `
                    -ScriptText $Script                       `
                    -GuestUser $Username                      `
                    -GuestPassword $Password                  `
                    -ScriptType Powershell                    `
                    | Format-List -Property VM,ScriptOutput   `
                    | Out-File $FILE -Append -NoClobber

}

# Function for validate ip address
# Return True or False
#
# Use: isIP '1.1.1.1'
#
# OR
#
# Use: isIP $AnyIpAddress
Function isIP
{
  Param( [string]$ip )
  If ( $ip -match '^\d{0,3}.\d{0,3}.\d{0,3}.\d{0,3}$' )
  {
    return $True
  }
  else
  {
    return $False
  }
}

# TODO: 3. Start of check

# Set STAND_NUMBER
If ( $args[0] -is [int] )
{
  $STAND = $args[0]
}
else
{
  Do
  {
    $STAND = Read-Host "Stand number"
  } until ( $STAND -is [int] -eq $False )
}

# Set COMPETITOR
If ( $args[1] -is [string] )
{
  $COMPETITOR = $args[1]
}
else
{
  Do
  {
    $COMPETITOR = Read-Host "Competitor FirstnameLastname"
  } until ( $COMPETITOR.length -ge 2 )
}

# Set SERVER_IP
If ( isIp $args[2] )
{
  $SERVER_IP = $args[2]
}
else
{
  Do
  {
    $SERVER_IP = Read-Host "IP address ESXi"
  } until ( isIP $SERVER_IP -eq $False )
}

# Create output file
$FILE = [string]$STAND + '_RESULT' + '.txt'
Write-Output '' > $FILE

# Connect to Server and ignore invalid certificate
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple     `
                          -InvalidCertificateAction Ignore  `
                          -Confirm:$false
Connect-VIServer -Server $SERVER_IP -User $LOGIN_ESXi -Password $PASS_ESXi

# Start all VMs and delay for VM power on
Get-VM | Where-Object { $_.PowerState -eq 'PoweredOff' } | Start-VM
Start-Sleep -s $DELAY

###########################--=START=--##################################

$DATE = Get-Date
Write-Output $DATE        | Out-File $FILE -Append -NoClobber
Write-Output $COMPETITOR  | Out-File $FILE -Append -NoClobber

SendScript -VM 'DC1'                         `
           -Script 'ipconfig'                `
           -Description 'Network interface configuration'

SendScript -VM 'CLI1'                         `
           -Script 'ping R1.kazan.wsr'                `
           -Description 'Ping allow'

SendScript -VM 'DC1'                         `
           -Script 'Get-ADDomainController | findstr ComputerObjectDN'                `
           -Description 'Domain Kazan.wsr'

SendScript -VM 'SRV1'                         `
           -Script 'Get-ADDomainController | findstr IsReadOnly'                `
           -Description 'RODC'

SendScript -VM 'DC1'                         `
           -Script 'get-dnsserverresourcerecord -ZoneName kazan.wsr | findstr "A CNAME"'                `
           -Description 'DNS service and zone records'

SendScript -VM 'DC1'                         `
           -Script 'Get-DhcpServerv4Scope'                `
           -Description 'DHCP'

SendScript -VM 'DC1'                         `
           -Script 'Get-ADComputer -Filter * | findstr SamAccountName'                `
           -Description 'Domain clients'

SendScript -VM 'DC1'                         `
           -Script 'net group'                `
           -Description 'Domain groups'

SendScript -VM 'DC1'                         `
           -Script 'Get-ADUser -Filter {Name -Like "IT*"} | findstr SamAccountName'                `
           -Description '60 users with correct names and passwords exists (IT)' 

SendScript -VM 'DC1'                         `
           -Script 'Get-ADUser -Filter {Name -Like "Sales*"} | findstr SamAccountName'                `
           -Description '60 users with correct names and passwords exists (Sales)'

SendScript -VM 'DC1'                         `
           -Script 'Get-ADGroupMember -Identity IT | FindStr SamAccountName'               `
           -Description 'Correct users in correct groups (IT)' 

SendScript -VM 'DC1'                         `
           -Script 'Get-ADGroupMember -Identity Sales | FindStr SamAccountName'               `
           -Description 'Correct users in correct groups (Sales)' 

SendScript -VM 'DC1'                         `
           -Script 'get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'                `
           -Description 'All group polices'

SendScript -VM 'CLI1'                         `
           -Script 'net use U: \\srv1\IT_1'                `
           -Description 'Home folder (See already in use message)'

SendScript -VM 'SRV1'                         `
           -Script 'Get-ADDomainController | findstr ComputerObjectDN'                `
           -Description 'Secondary domain controller' 

SendScript -VM 'SRV1'                         `
           -Script 'echo "list volume" | out-file C:\script.txt -Encoding utf8'                `
           -Description  ' '

SendScript -VM 'SRV1'                         `
           -Script 'diskpart /s C:\script.txt'                `
           -Description  'RAID-5'

SendScript -VM 'SRV1'                         `
           -Script 'Get-DNSServerZone | findstr Secondary'                `
           -Description 'Secondary DNS'

SendScript -VM 'SRV1'                         `
           -Script 'net share'               `
           -Description 'Shared folders' 

SendScript -VM 'SRV1'                         `
           -Script 'tree D:'                `
           -Description 'Department folders'

SendScript -VM 'SRV1'                         `
           -Script 'Get-FSRMQuota'                `
           -Description 'Quota'

SendScript -VM 'SRV1'                         `
           -Script 'Get-FSRMFileScreen'               `
           -Description 'File screen'

SendScript -VM 'CLI1'                         `
           -Script 'Invoke-WebRequest -Uri https://www.kazan.wsr -UseBasicParsing'                `
           -Description 'www.Kazan.wsr'

SendScript -VM 'CLI1'                         `
           -Script 'Invoke-WebRequest -Uri https://kazan.wsr -UseBasicParsing'                `
           -Description 'Kazan.wsr'

SendScript -VM 'SRV1'                         `
           -Script 'Get-DhcpServerv4Failover'                `
           -Description 'DHCP-failover'

SendScript -VM 'DCA'                         `
           -Script 'Get-WindowsFeature Ad-Certificate'                `
           -Description 'ADCS installed'

SendScript -VM 'DCA'                         `
           -Script 'certutil | findstr Name'                `
           -Description 'ADCS - CS Name'

SendScript -VM 'DCA'                         `
           -Script 'certutil -tcainfo | findstr NotAfter'                `
           -Description 'ADCS - Validatity period' 

SendScript -VM 'DCA'                         `
           -Script 'certutil -tcainfo | FindStr "["'                `
           -Description 'ADCS - Templates' 

SendScript -VM 'DC1'                         `
           -Script 'ping SPB.wse'                `
           -Description 'Static route is working' 

SendScript -VM 'DC2'                         `
           -Script 'Get-ADDomainController'                `
           -Description 'Domain SPB.wse' 

SendScript -VM 'DC2'                         `
           -Script 'ipconfig'                `
           -Description 'Network interface configuration' 

SendScript -VM 'CLI2'                         `
           -Script 'Get-WmiObject Win32_UserProfile | FindStr RoamingPath'                `
           -Description 'Roaming profiles'             `
           -Username 'User1'                 `
           -Password 'P@ssw0rd'

SendScript -VM 'CLI2'                         `
           -Script 'net use X: \\SRV2.spb.wse\profiles\; tree X:'                `
           -Description 'Roaming profiles correct access (See only user1 profile folder)'             `
           -Username 'User1'                 `
           -Password 'P@ssw0rd'

SendScript -VM 'DC1'                         `
           -Script 'Get-ADTrust -Filter * | findstr "Direction Source Target ForestTransitive"'                `
           -Description 'Domain Trusts'

SendScript -VM 'CLI1'                         `
           -Script 'Invoke-WebRequest -Uri https://www.spb.wse -UseBasicParsing'                `
           -Description 'www.spb.wse' 

SendScript -VM 'CLI1'                         `
           -Script 'Invoke-WebRequest -Uri https://www.spb.wse -UseBasicParsing'                `
           -Description 'spb.wse' 