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
$LOGIN_VM           = 'root'            # VM Login
$PASS_VM            = 'toor'            # VM Password
$DELAY              = 0                 # Delay before start VM

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
 If ($Description -ne $null)
 {
   echo "#########################--=$Description=--#########################" `
   | Out-File $FILE -Append -NoClobber
 }
 echo "Script	     : $Script" | Out-File $FILE -Append -NoClobber
 If ( ($Username  -eq $null) -or ($Password  -eq $null) )
 {
   $Username = $LOGIN_VM
   $Password = $PASS_VM
 }
 else {
   echo "Username     : $Username" | Out-File $FILE -Append -NoClobber
   echo "Password     : $Password" | Out-File $FILE -Append -NoClobber
 }
 Invoke-VMScript  -vm $VM                                   `
                  -ScriptText $Script                       `
                  -GuestUser $Username                      `
                  -GuestPassword $Password                  `
                  -ScriptType Bash                          `
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
echo '' > $FILE

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
echo $DATE        | Out-File $FILE -Append -NoClobber
echo $COMPETITOR  | Out-File $FILE -Append -NoClobber

# TODO: A1.1 Hostnames
SendScript -VM 'L-CLI-A', 'R-SRV'                     `
           -Script 'cat /etc/hostname'                `
           -Description 'Hostnames'

# TODO: A1.2 IPv4 connectivity
SendScript -VM 'L-CLI-B', 'R-CLI'                     `
           -Script 'ping -c 4 2.2.2.2'                `
           -Description 'IPv4 connectivity'

# TODO: A1.3 Software installation
SendScript -VM 'L-SRV', 'R-RTR'                       `
           -Script 'whereis tcpdump vim lynx curl'    `
           -Description 'Software installation'

# TODO: A1.4 Local hostname table
SendScript -VM 'OUT-CLI', 'L-RTR-B'                   `
           -Script 'cat /etc/hosts'                   `
           -Description 'Local hostname table'

# TODO: A1.5 Name lookup order
SendScript -VM 'OUT-CLI', 'L-RTR-B'                   `
           -Script "grep '^hosts' /etc/nsswitch.conf" `
           -Description 'Name lookup order'

# TODO: A1.6 DHCP-A: Basic Operation
$SCRIPT = 'dhclient -r &> /dev/null; dhclient -v &> /dev/null; ip a | sed -n 7,9p; ip r'
SendScript -VM 'L-CLI-A'                              `
           -Script $SCRIPT                            `
           -Description 'DHCP-A: Basic Operation'

# TODO: A1.7 DHCP-A: Additional Parameters
SendScript -VM 'L-CLI-A'                              `
           -Script 'cat /etc/resolv.conf'             `
           -Description 'DHCP-A: Additional Parameters'

# TODO: A1.8 DHCP-B: Basic Operation
$SCRIPT = 'dhclient -r &> /dev/null; dhclient -v &> /dev/null; ip a | sed -n 7,9p; ip r'
SendScript -VM 'L-CLI-B'                              `
           -Script $SCRIPT                            `
           -Description 'DHCP-B: Basic Operation'

# TODO: A1.9 DHCP-B: Additional Parameters
SendScript -VM 'L-CLI-B'                              `
           -Script 'cat /etc/resolv.conf'             `
           -Description 'DHCP-B: Additional Parameters'

# TODO: A1.10 DNS: Forward zone
$SCRIPT = 'host l-srv.skill39.wsr; host vpn.skill39.wsr; host r-cli.skill39.wsr'
SendScript -VM 'L-CLI-A'                              `
           -Script $SCRIPT                            `
           -Description 'DNS: Forward zone'

# TODO: A1.11 DNS: Reverse zone
$SCRIPT = 'host 172.16.20.10; host 192.168.20.10'
SendScript -VM 'L-CLI-A'                              `
           -Script $SCRIPT                            `
           -Description 'DNS: Reverse zone'

# TODO: A1.12 DNS: ISP Forwarders
SendScript -VM 'R-CLI'                                `
           -Script 'host ya.ru'                       `
           -Description 'DNS: ISP Forwarders'

# TODO: A1.13 DNS: Secondary DNS
SendScript -VM 'R-CLI'                                `
           -Script 'host ya.ru'                       `
           -Description 'DNS: Secondary DNS'

# TODO: A1.14 DNS: Dynamic DNS
# 1. Resolve L-CLI-A
SendScript -VM 'L-CLI-B'                              `
           -Script 'host L-CLI-A'                     `
           -Description 'DNS: Dynamic DNS'

# 2. Rental exemption L-CLI-A
SendScript -VM 'L-CLI-A'                              `
           -Script 'dhclient -r &> /dev/null; sleep 5'

# 3. Resolve again
SendScript -VM 'L-CLI-B'                              `
           -Script 'host L-CLI-A'

# 4. Request address L-CLI-A
SendScript -VM 'L-CLI-A'                              `
           -Script 'dhclient -v &> /dev/null'

# TODO: A1.15 Internet Gateway (Dynamic NAT)-LEFT
SendScript -VM 'L-CLI-A'                              `
           -Script 'ping 20.20.20.10 -c 4'            `
           -Description 'Internet Gateway (Dynamic NAT)-LEFT'

# TODO: A1.16 Internet Gateway (Dynamic NAT)-RIGHT
SendScript -VM 'R-CLI'                                `
           -Script 'ping 10.10.10.10 -c 4'            `
           -Description 'Internet Gateway (Dynamic NAT)-RIGHT'

# TODO: A1.17 DNS-Proxy
SendScript -VM 'OUT-CLI'                              `
           -Script 'host www.skill39.wsr'             `
           -Description 'DNS-Proxy'

# TODO: A2.1 LDAP: Users, Groups and OU
$SCRIPT = 'ldapsearch -x cn=user -b ou=Guest,dc=skill39,dc=wsr'
SendScript -VM 'L-SRV'                                `
           -Script $SCRIPT                            `
           -Description 'LDAP: Users, Groups and OU'

# TODO: A2.2 LDAP: Clients authentication
# 1. Login from tux
$SCRIPT = 'grep ^tux /etc/passwd; echo LDAP Authentication from tux has been successfully'
SendScript -VM 'L-CLI-A'                              `
           -Script $SCRIPT                            `
           -Username 'tux'                            `
           -Password 'toor'                           `
           -Description 'LDAP: Clients authentication'

# 2. Login from tux
$SCRIPT = 'grep ^user /etc/passwd; echo LDAP Authentication from user has been successfully'
SendScript -VM 'L-CLI-B'                              `
           -Script $SCRIPT                            `
           -Username 'user'                           `
           -Password 'P@ssw0rd'

# TODO: A2.3 Syslog: L-SRV
$SCRIPT = 'date && tail -n 1 /opt/logs/L-SRV/auth.log'
SendScript -VM 'L-SRV'                                `
           -Script $SCRIPT                            `
           -Description 'Syslog: L-SRV'

# TODO: A2.4 Syslog: L-FW
$SCRIPT = 'grep 172.16.20.10 /etc/rsyslog.conf && logger -p err ERROR FROM L-FW'
SendScript -VM 'L-FW'                                `
           -Script $SCRIPT                           `
           -Description 'Syslog: L-FW'

$SCRIPT = 'date && grep "ERROR FROM L-FW" /opt/logs/L-FW/error.log'
SendScript -VM 'L-SRV'                                `
           -Script $SCRIPT

# TODO: A3.1 RA: OpenVPN basic
$SCRIPT = 'ls /opt/vpn; netstat -npl | grep 1122; systemctl status openvpn@server | grep Active; grep -v "^[# $]" /etc/openvpn/*.conf'
SendScript -VM 'L-FW'                                 `
           -Script $SCRIPT                            `
           -Description 'RA: OpenVPN basic'

# TODO: A3.2 RA: VPN Clients have full access to LEFT and RIGHT LANs
$SCRIPT = 'ls /opt/vpn; start_vpn.sh; sleep 5; ping L-SRV.skill39.wsr -c 4; ping R-SRV.skill39.wsr -c 4'
SendScript -VM 'OUT-CLI'                              `
           -Script $SCRIPT                            `
           -Description 'RA: VPN Clients have full access to LEFT and RIGHT LANs'


$DATE = Get-Date
echo $DATE        | Out-File $FILE -Append -NoClobber
#
# echo "###############################################################'L-FW' RA: OpenVPN basic#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $LFW -ScriptText "ls /opt/vpn; netstat -npl | grep 1122; grep -v '^[# $]' /etc/openvpn/server.conf; ip a" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-FW RA: OpenVPN basic Script ls /opt/vpn; netstat -npl | grep 1122; grep -v "^[# $]" /etc/openvpn/server.conf; ip a') | Out-File $FILE
#
# echo "###############################################################'L-FW' Routing: Dynamic#########################################################################" | Out-File $FILE -Append -NoClobber
#
#    Invoke-VMScript -vm $LFW -ScriptText "ip r; vtysh -e 'sh ip ospf nei' ; vtysh -e 'sh ip route ospf'" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-FW Routing: Dynamic Script ip r; vtysh -e sh ip ospf nei; vtysh -e sh ip route ospf') | Out-File $FILE
#
# echo "###############################################################'R-FW' Routing: OSPF over GRE#########################################################################" | Out-File $FILE -Append -NoClobber
#
#     Invoke-VMScript -vm $RFW -ScriptText "vtysh -e 'sh ip ospf nei'" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-FW Routing: OSPF over GRE Script vtysh -e sh ip ospf nei') | Out-File $FILE
#
# echo "###############################################################'L-CLI-A' Routing: Filter#########################################################################" | Out-File $FILE -Append -NoClobber
#
# Invoke-VMScript -vm $LCLIA -ScriptText "timeout 10 tcpdump -i ens32 -n 'ip[9] == 89'" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'LCLIA Routing: Filter Script  timeout 10 tcpdump -i eth1 -n ip[9] == 89') | Out-File $FILE
#
# echo "###############################################################'R-FW' IPSec Active Status#########################################################################" | Out-File $FILE -Append -NoClobber
#
#     Invoke-VMScript -vm $RFW -ScriptText "ipsec status; cat /etc/ipsec.confs" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-FW IPSec Active Status Script ipsec status cat /etc/ipsec.conf') | Out-File $FILE
#
# echo "###############################################################'R-FW' IPSec Parameters and GRE only#########################################################################" | Out-File $FILE -Append -NoClobber
#
#     Invoke-VMScript -vm $RFW -ScriptText "ipsec status" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-FW IPSec Parameters and GRE only Script ipsec status') | Out-File $FILE
#
# echo "###############################################################'R-FW' GRE Tunnel#########################################################################" | Out-File $FILE -Append -NoClobber
#
#     Invoke-VMScript -vm $RFW -ScriptText "ip a; ping 10.5.5.2 -c 4; ping 10.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-FW GRE Tunnel Script ip a; ping 10.5.5.2 -c 4 ; ping 10.5.5.1 -c 4') | Out-File $FILE
#
# echo "###############################################################'R-FW' GRE over IPSec#########################################################################" | Out-File $FILE -Append -NoClobber
#
#     Invoke-VMScript -vm $RFW -ScriptText "ipsec status" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-FW GRE over IPSec Script tcpdump -I any  esp -v') | Out-File $FILE

# echo "###############################################################'OUT-CLI' RA: VPN Connect Script#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $OUTCLI -ScriptText "ip a; ls /opt/vpn; cd ~ ; stop_vpn.sh ; sleep 5; ping 5.5.5.1 -c 4 ;start_vpn.sh vpn66 Passw0rd; sleep 5 ; ip a; ping 5.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI RA: VPN Connect Script Script ip a; ls /opt/vpn; cd ~ ; stop_vpn.sh ; sleep 5; ping 5.5.5.1 -c 4 ;start_vpn.sh vpn66 Passw0rd; sleep 5 ; ip a; ping 5.5.5.1 -c 4') | Out-File $FILE
#
# echo "###############################################################'OUT-CLI' RA: VPN Disconnect Script#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $OUTCLI -ScriptText "op a; stop_vpn.sh;sleep 5; ip a; ping 5.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI RA: VPN Disconnect Script Script stop_vpn.sh; ip a; ping 5.5.5.1 -c 4') | Out-File $FILE
#
#
# echo "###############################################################'OUT-CLI' RA: OpenVPN LDAP authentication 	RA: OpenVPN Client Autoconf#########################################################################" | Out-File $FILE -Append -NoClobber
#
#           Invoke-VMScript -vm $OUTCLI -ScriptText "cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI RA: VPN Disconnect Script Script cat /etc/resolv.conf') | Out-File $FILE
#
#         Invoke-VMScript -vm $OUTCLI -ScriptText "start_vpn.sh vpn66 VRONPassw0rd; sleep 5; ip a; ping 5.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI RA: VPN Disconnect Script Script start_vpn.sh vpn66 Passw0rd') | Out-File $FILE
#
# echo "###############################################################'OUT-CLI' SSH: Users#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $OUTCLI -ScriptText "sshpass -p P@ssw0rd ssh -o 'StrictHostKeyChecking no' ssh_c@vpn.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI SSH: Users Script sshpass -p toor ssh -o StrictHostKeyChecking no root@vpn.skill39.wsr') | Out-File $FILE
#
#
# echo "###############################################################'OUT-CLI' SSH: Key authentication#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $OUTCLI -ScriptText "timeout 10 ssh ssh_p@vpn.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI SSH: Key authentication Script sshpass -p toor ssh vpn.skill39.wsr') | Out-File $FILE
#
#
# echo "###############################################################'L-SRV' RAID#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LSRV -ScriptText "lsblk" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV RAID Script lsblk') | Out-File $FILE
#
#
# echo "###############################################################'R-RTR' LVM: Volume LVM: Snapshots LVM: Snapshot Filename#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $RRTR -ScriptText "lvs; lvdisplay" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-RTR LVM: Volume LVM: Snapshots LVM: Snapshot Filename Script lvs; lvdisplay') | Out-File $FILE
#
#
# echo "###############################################################'L-CLI-A L-SRV L-CLI-B' RSYNC: Sync#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "cp /etc/passwd /root/sync/cli_to_srv.test && sleep 90" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'LCLIA RSYNC: Sync Script cp /etc/passwd /root/sync/cli_to_srv.test && sleep 90') | Out-File $FILE
#
#
#  Invoke-VMScript -vm $LSRV -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'LSRV RSYNC: Sync Script ls /opt/sync') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'LCLIB RSYNC: Sync Script ls /opt/sync') | Out-File $FILE
#
#
#  echo "###############################################################'L-CLI-A L-SRV L-CLI-B' RSYNC: Delete Sync#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "rm -f /root/sync/cli_to_srv.test && sleep 90" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'LCLIA RSYNC: Delete Sync Script rm -f /root/sync/cli_to_srv.test && sleep 90') | Out-File $FILE
#
#
#  Invoke-VMScript -vm $LSRV -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV RSYNC: Delete Sync Script ls /opt/sync') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B RSYNC: Delete Sync Script ls /opt/sync') | Out-File $FILE
#
#   Invoke-VMScript -vm $LCLIA -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A RSYNC: Delete Sync Script ls /opt/sync') | Out-File $FILE
#
#   echo "###############################################################'L-CLI-A L-SRV 'RSYNC: Security#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LSRV -ScriptText "cat /etc/rsyncd.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV  RSYNC: Security Script cat /etc/rsyncd.conf') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "cat /root/sync.sh" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A  RSYNC: Security Script cat /root/sync.sh') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "crontab -l" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A  RSYNC: Security Script crontab -l') | Out-File $FILE
#
# echo "###############################################################L-CLI-A AND R-CLI AND OUT-CLI and L-CLI-B' Web: http/s intra.skill39.wsr , http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https Web: http://www.skill39.wsr/  : Static content Web: http://www.skill39.wsr/date.php  : PHP content #########################################################################" | Out-File $FILE -Append -NoClobber
#
# Invoke-VMScript -vm $LCLIA -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A Web: http/s intra.skill39.wsr, Web: Trusted SSL , Web: http –> https Script curl -L http://intra.skill39.wsr ') | Out-File $FILE
#
# Invoke-VMScript -vm $LCLIB -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B Web: http/s intra.skill39.wsr , Web: Trusted SSL , Web: http –> https Script curl -L http://intra.skill39.wsr') | Out-File $FILE
#
# Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI Web: http/s intra.skill39.wsr , Web: Trusted SSL , Web: http –> https Script curl -L http://intra.skill39.wsr') | Out-File $FILE
#
# Invoke-VMScript -vm $RCLI -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-CLI Web: http/s intra.skill39.wsr , Web: Trusted SSL , Web: http –> https Script curl -L http://intra.skill39.wsr') | Out-File $FILE
#
# Invoke-VMScript -vm $LCLIA -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A Web: http/s www.skill39.wsr, Web: Trusted SSL , Web: http –> https Script curl -L http://www.skill39.wsr ') | Out-File $FILE
#
# Invoke-VMScript -vm $LCLIB -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B Web: http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https Script curl -L http://www.skill39.wsr') | Out-File $FILE
#
# Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI Web: http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https Script curl -L http://www.skill39.wsr') | Out-File $FILE
#
# Invoke-VMScript -vm $RCLI -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-CLI Web: http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https Script curl -L http://www.skill39.wsr') | Out-File $FILE
#
# Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/index.html" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI Web: http://www.skill39.wsr/  : Static content') | Out-File $FILE
#
#  Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/date.php" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI  Web: http://www.skill39.wsr/date.php  : PHP content') | Out-File $FILE
#
# echo "###############################################################'R-FW' NGINX: Proxy#########################################################################" | Out-File $FILE -Append -NoClobber
#  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/nginx/conf.d/task.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW NGINX: Proxy Script cat /etc/nginx/conf.d/task.conf') | Out-File $FILE
#
# echo "###############################################################'OUT-CLI' NGINX: SSL and ReFILEection#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/index.html" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI  Web: http://www.skill39.wsr/index.html NGINX: SSL and ReFILEection') | Out-File $FILE
#
# echo "###############################################################'R-FW' NGINX: Backend Health check#########################################################################" | Out-File $FILE -Append -NoClobber
#  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/nginx/conf.d/task.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW NGINX: Backend Health check Script cat /etc/nginx/conf.d/task.conf') | Out-File $FILE
#
# echo "###############################################################'R-FW OUT-CLI R-SRV' NGINX: Caching capability#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/nginx/conf.d/task.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW NGINX: Caching capability Script cat /etc/nginx/conf.d/task.conf') | Out-File $FILE
#
# Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/date.php  && sleep 10 curl -L http://www.skill39.wsr/date.php" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI  NGINX: Caching capability Script curl -L http://www.skill39.wsr/date.php  && sleep 10 curl -L http://www.skill39.wsr/date.php') | Out-File $FILE
#
# Invoke-VMScript -vm $RSRV -ScriptText "echo 'SECRET_STRING' >> /var/www/html/out/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-SRV  NGINX: Caching capability Script echo "SECRET_STRING" >> /var/www/html/out/secret.txt') | Out-File $FILE
#
# Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI  NGINX: Caching capability Script curl -L http://www.skill39.wsr/secret.txt') | Out-File $FILE
#
# Invoke-VMScript -vm $RSRV -ScriptText "rm -f /var/www/html/out/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-SRV  NGINX: Caching capability Script rm -f /var/www/html/out/secret.txt ') | Out-File $FILE
#
# Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/secret.txt  && sleep 50  && curl -L http://www.skill39.wsr/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI  NGINX: Caching capability Script curl -L http://www.skill39.wsr/secret.txt  && sleep 50  && curl -L http://www.skill39.wsr/secret.txt') | Out-File $FILE
#
# echo "###############################################################'R-FW' OpenSSL: CA#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $RFW -ScriptText "ls /etc/ca; openssl ca" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW OpenSSL: CA Script ls /etc/ca') | Out-File $FILE
#
# echo "###############################################################'R-FW' Certificate Attributes#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/ca/cacert.pem" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW Certificate Attributes Script cat /etc/ca/cacert.pem') | Out-File $FILE
#
# echo "###############################################################'L-FW R-FW' IPTables: Block input traffic IPTables: DNS port forwarding IPTables: Allow GRE & IPSec IPTables: Allow SSH IPTables: Allow VPN IPTables: No Access to www.skill39.wsr via OpenVPN IPTables: HTTP/HTTPS#########################################################################" | Out-File $FILE -Append -NoClobber
#
#   Invoke-VMScript -vm $RFW -ScriptText "iptables -L -v -n -t filter; iptables -L -v -n -t nat" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW IPTables: Block input traffic IPTables: DNS port forwarding IPTables: Allow GRE & IPSec IPTables: Allow SSH IPTables: Allow VPN IPTables: No Access to www.skill39.wsr via OpenVPN IPTables: HTTP/HTTPS Script iptables -L -v -n -t filter; iptables -L -v -t nat') | Out-File $FILE
#
# Invoke-VMScript -vm $LFW -ScriptText "iptables -L -v -n -t filter; iptables -L -v -n -t nat" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-FW IPTables: Block input traffic IPTables: DNS port forwarding IPTables: Allow GRE & IPSec IPTables: Allow SSH IPTables: Allow VPN IPTables: No Access to www.skill39.wsr via OpenVPN IPTables: HTTP/HTTPS Script iptables -L -v -n -t filter; iptables -L -v -t nat') | Out-File $FILE
