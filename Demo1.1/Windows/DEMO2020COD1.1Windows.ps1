$NAMEWIN = "Ivanov Ivan" #Competitor name
$SERVERWIN = "10.10.10.10" #ESXI Stand address
$LOGINSERVERWIN = "root" #ESXI login
$PASSSERVERWIN = "P@ssw0rd" #ESXI password
$DATE = Get-Date -Format "dd-MM-yyyy_HH-MM-ss" #Current time

$DIR = $DATE.ToString() + $NAMEWIN + "_Windows_" + '.txt' #Output file
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -InvalidCertificateAction Ignore -Confirm:$false #Ignore invalid certificate
Connect-VIServer -Server $SERVERWIN -User $LOGINSERVERWIN -Password $PASSSERVERWIN #Connect to Server



Get-VM | Start-VM #Start all VMs
Start-Sleep -s 240 #Delay for VM power on

#Start File
echo "Start Check Time:" $DATE | Out-File $DIR -Append -NoClobber
echo "Competitor:" $NAMEWIN | Out-File $DIR -Append -NoClobber

#Function sending commands to VM
function SendCommand ($VM, $Command) {
  Invoke-VMScript -vm $VM -ScriptText $Command -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
}

echo "###############################################################'DC1: Network interface configuration'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'ipconfig'

echo "###############################################################'CLI1: Ping allow'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM CLI1 -Command 'ping R1.kazan.wsr'

echo "###############################################################'DC1: Domain Kazan.wsr'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'Get-ADDomainController | findstr ComputerObjectDN'

echo "###############################################################'SRV1: Secondary domain controller + RODC'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'Get-ADDomainController | findstr IsReadOnly'

echo "###############################################################'DC1: DNS service zone and records'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-dnsserverresourcerecord -ZoneName kazan.wsr | findstr "A CNAME"'
SendCommand -VM SRV1 -Command 'Get-DNSServerZone | findstr Slave'

echo "###############################################################'DC1: Domain clients'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'Get-ADComputer -Filter * | findstr SamAccountName'

echo "###############################################################'DC1: Domain group'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'net group'

echo "###############################################################'DC1: 60 users with correct names and passwords exists'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'Get-ADUsers -Filter * | FindStr SamAccountName'

echo "###############################################################'DC1: Corret users in correct groups'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'Get-ADGroupMember -Identity IT | FindStr SamAccountName'

echo "###############################################################'DC1: No first sign animation'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-gporeport -all -path c:\gpo.xml -reporttype xml'
SendCommand -VM DC1 -Command '[xml] $gpo = Get-Content c:\gpo.xml'
SendCommand -VM DC1 -Command '$gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'

echo "###############################################################'DC1: Default Home Page for Edge and IE'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-gporeport -all -path c:\gpo.xml -reporttype xml'
SendCommand -VM DC1 -Command '[xml] $gpo = Get-Content c:\gpo.xml'
SendCommand -VM DC1 -Command '$gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'

echo "###############################################################'DC1: Local admin GPO'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-gporeport -all -path c:\gpo.xml -reporttype xml'
SendCommand -VM DC1 -Command '[xml] $gpo = Get-Content c:\gpo.xml'
SendCommand -VM DC1 -Command '$gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'

echo "###############################################################'DC1: Shares message'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-gporeport -all -path c:\gpo.xml -reporttype xml'
SendCommand -VM DC1 -Command '[xml] $gpo = Get-Content c:\gpo.xml'
SendCommand -VM DC1 -Command '$gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'

echo "###############################################################'DC1: DHCP service scope'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'Get-DhcpServerv4Scope'

echo "###############################################################'DC1: Sleep mode'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-gporeport -all -path c:\gpo.xml -reporttype xml'
SendCommand -VM DC1 -Command '[xml] $gpo = Get-Content c:\gpo.xml'
SendCommand -VM DC1 -Command '$gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'

echo "###############################################################'DC1: Shortcut fo Calc'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'get-gporeport -all -path c:\gpo.xml -reporttype xml'
SendCommand -VM DC1 -Command '[xml] $gpo = Get-Content c:\gpo.xml'
SendCommand -VM DC1 -Command '$gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name'

echo "###############################################################'CLI1: Home folder'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM CLI1 -Command 'net use U: \srv1\IT_1'

echo "###############################################################'SRV1: Secondary domain controller'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'Get-ADDomainController | findstr ComputerObjectDN'

echo "###############################################################'SRV1: RAID-5'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'echo "list volume" | out-file C:\script.txt -Encoding utf8'
SendCommand -VM SRV1 -Command 'diskpart /s C:\script.txt'

echo "###############################################################'SRV1: Secondary DNS'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'Get-DNSServerZone'

echo "###############################################################'SRV1: Shared folders'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'net share'

echo "###############################################################'SRV1: Department folder'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'net share'

echo "###############################################################'SRV1: Quota'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'Get-FSRMQuota'

echo "###############################################################'SRV1: File screen'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'Get-FSRMFileScreen'

echo "###############################################################'CLI1: www.Kazan.wsr'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM CLI1 -Command 'Invoke-WebRequest -Uri https://www.pest.com -UseBasicParsing'
SendCommand -VM CLI1 -Command 'Invoke-WebRequest -Uri https://pest.com -UseBasicParsing'

echo "###############################################################'SRV1: DHCP-failover'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM SRV1 -Command 'Get-DhcpServerv4Failover'

echo "###############################################################'DCA: AD CS - installed'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DCA -Command 'Get-WindowsFeature Ad-Certificate'

echo "###############################################################'DCA: AD CS - CS name'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DCA -Command 'certutil -dump'

echo "###############################################################'DCA: AD CS - CS Lifetime'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DCA -Command 'certutil -dump'

echo "###############################################################'DCA: AD CS - Templates'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DCA -Command 'certutil -template ITUsers'

echo "###############################################################'DC1: Static route is working'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'ping SPB.wse'

echo "###############################################################'DC2: Domain SPB.wse'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC2 -Command 'Get-ADDomainController'

echo "###############################################################'DC2: Network interface configuration'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC2 -Command 'ipconfig'

echo "###############################################################'CLI2: Roaming profiles'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM CLI2 -Command 'login with user1 > Echo $profile'

echo "###############################################################'CLI2: Roaming profiles correct access'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM CLI2 -Command 'login with user1 > Echo $profile'

echo "###############################################################'DC1: Domain trust'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM DC1 -Command 'test-computersecurechannel dc2.spb.wse'

echo "###############################################################'CLI1: www.spb.wse'#########################################################################" | Out-File $DIR -Append -NoClobber
SendCommand -VM CLI1 -Command 'Invoke-WebRequest -Uri https://www.pest.com -UseBasicParsing'
SendCommand -VM CLI1 -Command 'Invoke-WebRequest -Uri https://pest.com -UseBasicParsing'
