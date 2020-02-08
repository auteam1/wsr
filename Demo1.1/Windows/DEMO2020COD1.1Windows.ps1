Param(
[string]$NAMEWIN,
[string]$SERVERWIN,
[string]$LOGINSERVERWIN,
[string]$PASSSERVERWIN,
[string]$PATHWIN,
[string]$DATA
)
$DIR = $PATHWIN + $NAMEWIN + '.txt'
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server $SERVERWIN -User $LOGINSERVERWIN -Password $PASSSERVERWIN
$DC1 = Get-VM -Name 'DC1'
$DC2 = Get-VM -Name 'DC2'
$CLI1 = Get-VM -Name 'CLI1'
$SRV1 = Get-VM -Name 'SRV1'
$DCA = Get-VM -Name 'DCA'
$R1 = Get-VM -Name 'R1'
$R2 = Get-VM -Name 'R2'
$SRV2 = Get-VM -Name 'SRV2'
$CLI2 = Get-VM -Name 'CLI2'
Start-VM -VM $DC1 -Confirm:$false
Start-VM -VM $DC2 -Confirm:$false
Start-VM -VM $CLI1 -Confirm:$false
Start-VM -VM $SRV1 -Confirm:$false
Start-VM -VM $DCA -Confirm:$false
Start-VM -VM $R1 -Confirm:$false
Start-VM -VM $R2 -Confirm:$false
Start-VM -VM $CLI2 -Confirm:$false
Start-VM -VM $SRV2 -Confirm:$false

echo "Дата начала проверки:" $DATA | Out-File $DIR -Append -NoClobber
echo "Кто выполнял задание:" $NAMELIN | Out-File $DIR -Append -NoClobber


echo "###############################################################'DC1: Network interface configuration'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "ipconfig /all" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber #DHCP service scope
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Network interface configuration "ipconfig /all"') | Out-File $DIR

echo "###############################################################'CLI1: Ping allow'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $CLI1 -ScriptText "ping R1.Kazan.wsr" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'CLI1: Ping allow command "ping R1.Kazan.wsr"') | Out-File $DIR

echo "###############################################################'DC1: Domain Kazan.wsr'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "Get-ADDomainController | findstr ComputerObjectDN" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Domain Kazan.wsr command "Get-ADDomainController | findstr ComputerObjectDN"') | Out-File $DIR

echo "###############################################################'SRV1: Secondary domain controller + RODC'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "Get-ADDomainController | findstr IsReadOnly" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: Secondary domain controller + RODC "Get-ADDomainController | findstr IsReadOnly"') | Out-File $DIR

echo "###############################################################'DC1: DNS service zone and records'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-dnsserverresourcerecord -ZoneName kazan.wsr | findstr "A CNAME"; SRV1: Get-DNSServerZone | findstr Slave" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: DNS service zone and records "get-dnsserverresourcerecord -ZoneName kazan.wsr | findstr "A CNAME"; SRV1: Get-DNSServerZone | findstr Slave"') | Out-File $DIR

echo "###############################################################'DC1: Domain clients'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "Get-ADComputer -Filter * | findstr SamAccountName" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Domain clients command "Get-ADComputer -Filter * | findstr SamAccountName"') | Out-File $DIR

echo "###############################################################'DC1: Domain group'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "net group" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Domain group command "net group"') | Out-File $DIR

echo "###############################################################'DC1: 60 users with correct names and passwords exists'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "Get-ADUsers -Filter * | FindStr SamAccountName" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: 60 users with correct names and passwords exists command "Get-ADUsers -Filter * | FindStr SamAccountName"') | Out-File $DIR

echo "###############################################################'DC1: Corret users in correct groups'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "Get-ADGroupMember -Identity IT | FindStr SamAccountName" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Corret users in correct groups command "Get-ADGroupMember -Identity IT | FindStr SamAccountName"') | Out-File $DIR

echo "###############################################################'DC1: No first sign animation'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: No first sign animation command "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name"') | Out-File $DIR

echo "###############################################################'DC1: Default Home Page for Edge and IE'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Default Home Page for Edge and IE command "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name"') | Out-File $DIR

echo "###############################################################'DC1: Local admin GPO'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Local admin GPO command "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name"') | Out-File $DIR

echo "###############################################################'DC1: Shares message'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Shares message command "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name"') | Out-File $DIR

echo "###############################################################'DC1: DHCP service scope'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "Get-DhcpServerv4Scope" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Get-DhcpServerv4Scope"') | Out-File $DIR

echo "###############################################################'DC1: Sleep mode'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Sleep mode command "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name"') | Out-File $DIR

echo "###############################################################'DC1: Shortcut to Calc'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Shortcut to Calc command "get-gporeport -all -path c:\gpo.xml -reporttype xml; [xml] $gpo = Get-Content c:\gpo.xml; $gpo.report.GPO.Computer.extensiondata.extension.policy | Format-Table -AutoSize -Property State,Name"') | Out-File $DIR

echo "###############################################################'CLI1: Home folder'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $CLI1 -ScriptText "net use U: \\srv1\IT_1" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'CLI1: Home folder command "net use U: \\srv1\IT_1"') | Out-File $DIR

echo "###############################################################'SRV1: Secondary domain controlle'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "Get-ADDomainController | findstr ComputerObjectDN" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: Secondary domain controlle command "Get-ADDomainController | findstr ComputerObjectDN"') | Out-File $DIR

echo "###############################################################'SRV1: RAID-5'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText 'echo "list volume" | out-file C:\script.txt -Encoding utf8; diskpart /s C:\script.txt' -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: RAID-5 command "echo "list volume" | out-file C:\script.txt -Encoding utf8; diskpart /s C:\script.txt"') | Out-File $DIR

echo "###############################################################'SRV1: Shared folders'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "net share" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: Shared folders command "net share"') | Out-File $DIR

echo "###############################################################'SRV1: Department folder'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "net share" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: Department folder command "net share"') | Out-File $DIR

echo "###############################################################'SRV1: Quota'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "Get-FSRMQuota" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: Quota command "Get-FSRMQuota"') | Out-File $DIR

echo "###############################################################'SRV1: File screen'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "Get-FSRMFileScreen" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: File screen command "Get-FSRMFileScreen"') | Out-File $DIR

echo "###############################################################'CLI1: www.Kazan.wsr'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $CLI1 -ScriptText "Invoke-WebRequest -Uri https://www.kazan.wsr -UseBasicParsing; Invoke-WebRequest -Uri https://kazan.wsr -UseBasicParsing" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'CLI1: www.Kazan.wsr command "Invoke-WebRequest -Uri https://www.kazan.wsr -UseBasicParsing; Invoke-WebRequest -Uri https://kazan.wsr -UseBasicParsing"') | Out-File $DIR

echo "###############################################################'SRV1: DHCP-failover'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $SRV1 -ScriptText "Get-DhcpServerv4Failover" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'SRV1: DHCP-failover command "Get-DhcpServerv4Failover"') | Out-File $DIR

echo "###############################################################'DCA: AD CS - installed'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DCA -ScriptText "Get-WindowsFeature Ad-Certificate" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DCA: AD CS - installed command "Get-WindowsFeature Ad-Certificate"') | Out-File $DIR

echo "###############################################################'DCA: AD CS - CS name'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DCA -ScriptText "certutil -dump" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DCA: AD CS - CS name command "certutil -dump"') | Out-File $DIR

echo "###############################################################'DCA: AD CS - CS Lifetime'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DCA -ScriptText "certutil -dump" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DCA: AD CS - CS Lifetime command "certutil -dump"') | Out-File $DIR

echo "###############################################################'DCA: AD CS - Templates'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DCA -ScriptText "certutil -template ITUsers" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DCA: AD CS - Templates command "certutil -template ITUsers"') | Out-File $DIR

echo "###############################################################'DC1: Static route is working'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "ping SPB.wse" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Static route is working command "ping SPB.wse"') | Out-File $DIR

echo "###############################################################'DC2: Domain SPB.wse'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC2 -ScriptText "Get-ADDomainController" -GuestUser 'Administrator@SPB.wse' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC2: Domain SPB.wse command "Get-ADDomainController"') | Out-File $DIR

echo "###############################################################'DC2: Network interface configuration'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC2 -ScriptText "ipconfig /all" -GuestUser 'Administrator@SPB.wse' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC2: Network interface configuration command "ipconfig /all"') | Out-File $DIR



echo "###############################################################'CLI2: Roaming profiles'#########################################################################" | Out-File $DIR -Append -NoClobber
if(Invoke-VMScript -vm $CLI2 -ScriptText "echo LOGIN FOR CLI2 YES user user1" -GuestUser 'user1' -GuestPassword 'P@ssw0rd' -ScriptType Powershell){
Invoke-VMScript -vm $CLI2 -ScriptText "echo $profile" -GuestUser 'user1' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'CLI2: Roaming profiles') | Out-File $DIR
}
else{
echo "LOGIN FOR CLI2 NO user:user1 password: P@ssw0rd" | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'CLI2: Roaming profiles') | Out-File $DIR
}


echo "###############################################################'DC1: Domain trust'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $DC1 -ScriptText "test-computersecurechannel dc2.spb.wse" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'DC1: Domain trust command "test-computersecurechannel dc2.spb.wse"') | Out-File $DIR



echo "###############################################################'CLI1: www.SPB.wse'#########################################################################" | Out-File $DIR -Append -NoClobber
Invoke-VMScript -vm $CLI1 -ScriptText "Invoke-WebRequest -Uri https://www.spb.wse -UseBasicParsing; Invoke-WebRequest -Uri https://spb.wse -UseBasicParsing" -GuestUser 'Administrator@Kazan.wsr' -GuestPassword 'P@ssw0rd' -ScriptType Powershell | Out-File $DIR -Append -NoClobber
(Get-Content $DIR).replace('ScriptOutput', 'CLI1: www.SPB.wse command "Invoke-WebRequest -Uri https://www.spb.wse -UseBasicParsing; Invoke-WebRequest -Uri https://spb.wse -UseBasicParsing"') | Out-File $DIR

