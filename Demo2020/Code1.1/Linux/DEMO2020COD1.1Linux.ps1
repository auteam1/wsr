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
$SCRIPT = 'ls /opt/vpn /etc/openvpn; netstat -npl | grep 1122; echo Unit status: &&  systemctl status openvpn@server | cat | grep Active; echo Config file: && grep -v "^[# $ ;]" /etc/openvpn/*.conf | grep -v "^$"'
SendScript -VM 'L-FW'                                 `
           -Script $SCRIPT                            `
           -Description 'RA: OpenVPN basic'

# TODO: A3.2 RA: VPN Clients have full access to LEFT and RIGHT LANs
$SCRIPT = 'ls /opt/vpn; start_vpn.sh; sleep 5; ping L-SRV.skill39.wsr -c 2; ping R-SRV.skill39.wsr -c 2'
SendScript -VM 'OUT-CLI'                              `
           -Script $SCRIPT                            `
           -Description 'RA: VPN Clients have full access to LEFT and RIGHT LANs'

# TODO: A3.3 IPSEC + GRE
$SCRIPT = 'ipsec status | grep connections:'
SendScript -VM 'R-FW'                                 `
           -Script $SCRIPT                            `
           -Description 'IPSEC + GRE'
$SCRIPT = 'ipsec status'
SendScript -VM 'L-FW'                                 `
           -Script $SCRIPT                            `

# TODO: A3.4 GRE Tunnel Cinnectivity
$SCRIPT = 'ping 10.5.5.1 -c 2'
SendScript -VM 'R-FW'                                 `
           -Script $SCRIPT                            `
           -Description 'GRE Tunnel Cinnectivity'
$SCRIPT = 'ping 10.5.5.2 -c 2'
SendScript -VM 'L-FW'                                 `
           -Script $SCRIPT                            `

# TODO: A3.5 FRR: Neigbours 
SendScript -VM 'L-FW','R-FW'                          `
           -Script 'vtysh -E -c "show ip ospf ne"'    `
           -Description 'FRR: Neigbours'

# TODO: A3.6 FRR: Local interfaces 
SendScript -VM 'L-FW','R-FW'                          `
           -Script 'vtysh -E -c "show run"'           `
           -Description 'FRR: Local interfaces'

# TODO: A3.7 FRR: Passive interfaces
SendScript -VM 'L-RTR-A','R-RTR'                      `
           -Script 'vtysh -E -c "show run"'           `
           -Description 'FRR: Local interfaces'

# TODO: A3.8 SSH: Users
SendScript -VM 'OUT-CLI'                              `
           -Script 'ssh ssh_c@l-fw.skill39.wsr'       `
           -Description 'SSH: Users'

SendScript -VM 'OUT-CLI'                              `
           -Script 'ssh root@l-fw.skill39.wsr'        `

SendScript -VM 'OUT-CLI'                              `
           -Script 'ssh abc@l-fw.skill39.wsr'         `

# TODO: A3.9 SSH: Key authentication
SendScript -VM 'OUT-CLI'                              `
           -Script 'ssh ssh_p@l-fw.skill39.wsr'       `
           -Description 'SSH: Key authentication'

# TODO: A4.1 Apache: Port, PHP
SendScript -VM 'R-SRV'                                `
           -Script 'ssh ssh_p@l-fw.skill39.wsr'       `
           -Description 'SSH: Key authentication'


$DATE = Get-Date
Write-Output $DATE        | Out-File $FILE -Append -NoClobber


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
