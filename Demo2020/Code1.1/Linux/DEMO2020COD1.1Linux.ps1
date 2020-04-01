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
# Use: SendScript -VM L-SRV -Script 'hostnamectl'
Function SendScript
{
  Param( $VM,
         $Script,
         $Description )
 echo "#########################--=$Description=--#########################" `
      | Out-File $FILE -Append -NoClobber
 echo "Script	     : $Script" | Out-File $FILE -Append -NoClobber
 Invoke-VMScript  -vm $VM                                   `
                  -ScriptText $Script                       `
                  -GuestUser $LOGIN_VM                      `
                  -GuestPassword $PASS_VM                   `
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
    $COMPETITOR = Read-Host "Competitor Firstname Lastname"
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




# echo "###############################################################L-CLI-A R-CLI' Name lookup order#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "cat /etc/nsswitch.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A Name lookup order Script cat /etc/nsswitch.conf | grep dns files') | Out-File $FILE
#
#  Invoke-VMScript -vm $RCLI -ScriptText "cat /etc/nsswitch.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-CLI Name lookup order Script cat /etc/nsswitch.conf | grep dns files') | Out-File $FILE
#
# echo "###############################################################L-CLI-A' DHCP: Left side #########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DHCP: Left Script dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf') | Out-File $FILE
#
# echo "###############################################################L-CLI-B' DHCP: Address Reservation #########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B DHCP: Address Reservation Script dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf') | Out-File $FILE
#
#   echo "###############################################################L-CLI-A L-CLI-B' DHCP: Relay #########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "dhclient -r; dhclient -v" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B DHCP: Address Reservation Script dhclient -r; dhclient -v') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "dhclient -r; dhclient -v" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DHCP: Relay Script cat /var/lib/dhcp/dhclient.leases') | Out-File $FILE
#
#
# echo "###############################################################L-CLI-A' DNS: Forward zone#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "host l-srv.skill39.wsr; host vpn.skill39.wsr; host r-cli.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DNS: Forward zone Script nslookup skill39.wsr; nslookup L-SRV.skill39.wsr') | Out-File $FILE
#
#
# echo "###############################################################L-CLI-A' DNS: Reverse zone#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "host 172.16.20.10; host 192.168.20.10" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DNS: Reverse zone Script host 172.16.20.10; host 192.168.20.10') | Out-File $FILE
#
# echo "###############################################################L-CLI-A' DNS: ISP Forwarders#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "host ya.ru" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DNS: ISP Forwarders Script host ya.ru') | Out-File $FILE
#
#
# echo "###############################################################'R-CLI' DNS: Slave#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $RCLI -ScriptText "host r-fw.skill39.wsr; cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-CLI DNS: Slave Script host r-fw.skill39.wsr; cat /etc/resolv.conf') | Out-File $FILE
#
# echo "###############################################################L-CLI-A' DNS: Delegation#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "host -v ext.skill39.wsr; host test.ext.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DNS: Delegation Script host ext.skill39.wsr; host test.ext.skill39.wsr') | Out-File $FILE
#
#
# echo "###############################################################L-CLI-B L-CLI-A' DNS: Dynamic DNS#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "host L-CLI-A; host L-CLI-B" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B DNS: Dynamic DNS Script host L-CLI-A; host L-CLI-B') | Out-File $FILE
#
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "ifdown ens32" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A DNS: Dynamic DNS Script ifdown ens32') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "host L-CLI-A" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-FW DNS: Dynamic DNS Script host L-CLI-A') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIA -ScriptText "ifup ens32" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B DNS: Dynamic DNS Script ifup ens32') | Out-File $FILE
#
#
# echo "###############################################################L-FW R-FW' Internet Gateway (Dynamic NAT)#########################################################################" | Out-File $FILE -Append -NoClobber
#
# Invoke-VMScript -vm $LFW -ScriptText "ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat " -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-FW Internet Gateway (Dynamic NAT) Script ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat ') | Out-File $FILE
#
# Invoke-VMScript -vm $RFW -ScriptText "ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat " -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'R-FW Internet Gateway (Dynamic NAT) Script  ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat ') | Out-File $FILE
#
#
# echo "###############################################################L-SRV' LDAP: Users, Groups and OU#########################################################################" | Out-File $FILE -Append -NoClobber
#
#  Invoke-VMScript -vm $LSRV -ScriptText "ldapsearch -x cn=user -b ou=users,dc=skill39,dc=wsr; ldapsearch -x cn=Admin -b ou=groups,dc=skill39,dc=wsr; ldapsearch -x cn=VPN -b ou=groups,dc=skill39,dc=wsr > /root/ldapcheck; cat /root/ldapcheck; rm -rf /root/ldapcheck" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
# (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Users, Groups and OU Script ldapsearch -x cn=user -b ou=users,dc=skill39,dc=wsr; ldapsearch -x cn=Admin -b ou=groups,dc=skill39,dc=wsr; ldapsearch -x cn=VPN -b ou=groups,dc=skill39,dc=wsr > /root/ldapcheck; cat /root/ldapcheck; rm -rf /root/ldapcheck') | Out-File $FILE
#
# echo "###############################################################'L-CLI-A L-CLI-B' LDAP: Clients authentication#########################################################################" | Out-File $FILE -Append -NoClobber
#
# if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
#
# if(Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user tux password toor YES" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user tux password toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Clients authentication') | Out-File $FILE
# }
#
#
# echo "###############################################################'L-CLI-A L-CLI-B' LDAP: Home FILEectory#########################################################################" | Out-File $FILE -Append -NoClobber
#
#
# if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
# {Invoke-VMScript -vm $LCLIA -ScriptText "echo 'Test321' > ~/test321; mount" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Home FILEectory Script echo "Test321" > ~/test321; mount ') | Out-File $FILE
#  }
#  else{
#  Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Home FILEectory from user user66 password P@ssw0rd toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Home FILEectory') | Out-File $FILE
#  }
#
#  if(Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
#  {
#  Invoke-VMScript -vm $LCLIB -ScriptText "cat ~/test321" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Home FILEectory Script cat ~/test321') | Out-File $FILE
#  }
#  else{
#  Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Home FILEectory from user user66 password P@ssw0rd toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Home FILEectory') | Out-File $FILE
#  }
#
# echo "###############################################################'L-CLI-B' LDAP: Home FILEectory quota#########################################################################" | Out-File $FILE -Append -NoClobber
#
#   Invoke-VMScript -vm $LCLIB -ScriptText "dd if=/dev/zero of=/tmp/big; bs=1024 count=10240" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Home FILEectory quota Script dd if=/dev/zero of=/tmp/big; bs=1024 count=10240') | Out-File $FILE
#
#  if(Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user user50 password P@ssw0rd YES" -GuestUser 'user50' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
#  {
#  Invoke-VMScript -vm $LCLIB -ScriptText "cat ~/test321" -GuestUser 'user50' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Home FILEectory quota Script cat ~/test321') | Out-File $FILE
#  }
#  else{
#  Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Home FILEectory from user user50 password P@ssw0rd toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B LDAP: Home FILEectory quota') | Out-File $FILE
#  }
#
#
# echo "###############################################################'L-CLI-A L-SRV' LDAP: Logon restriction#########################################################################" | Out-File $FILE -Append -NoClobber
#
# if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
#
# if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'vpn1' -GuestPassword 'Passw0rd' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd YES" -GuestUser 'vpn1' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
#
# if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user tux password toor YES" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user tux password toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File $FILE
# }
#
# if(Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File $FILE
# }
#
# if(Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP" -GuestUser 'vpn1' -GuestPassword 'Passw0rd' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd YES" -GuestUser 'vpn1' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File $FILE
# }
#
# if(Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash)
# {
#  Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user tux password toor YES" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File $FILE
# }
# else{
# Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user tux password toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File $FILE
# }
#
# echo "###############################################################'L-CLI-A' LDAP: Process Limit#########################################################################" | Out-File $FILE -Append -NoClobber
#
# if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
# {
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user47 password P@ssw0rd YES; ulimit -a" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: authentication user47 and Script ulimit -a') | Out-File $FILE
# }
# elseif(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
# {
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user47 password P@ssw0rd YES; ulimit -a" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: authentication user47 and after Script ulimit -a') | Out-File $FILE
# }
# else
# {
# Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user47 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A LDAP: authentication user47') | Out-File $FILE
# }
#
# echo "###############################################################All host Syslog: All Critical messages#########################################################################" | Out-File $FILE -Append -NoClobber
#
# Invoke-VMScript -vm $LCLIA -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $LCLIB -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $LFW -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-FW Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $LRTRA -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-RTR-A Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $LRTRB -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-RTR-B Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $LSRV -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $OUTCLI -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $RCLI -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-CLI Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $RFW -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-FW Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $RRTR -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-RTR Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $RSRV -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#  Invoke-VMScript -vm $LSRV -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV Syslog: All Critical messages Script logger -p crit TESTCRIT') | Out-File $FILE
#
#   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-CLI-A/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/L-CLI-A/crit.log') | Out-File $FILE
#
#    Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-CLI-B/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/L-CLI-B/crit.log') | Out-File $FILE
#
#    Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-FW/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/L-FW/crit.log') | Out-File $FILE
#
#     Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/R-FW/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/R-FW/crit.log') | Out-File $FILE
#
#     Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-RTR-A/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/L-RTR-A/crit.log') | Out-File $FILE
#
#      Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-RTR-B/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/L-RTR-B/crit.log') | Out-File $FILE
#
#       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/OUT-CLI/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/OUT-CLI/crit.log') | Out-File $FILE
#
#       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/R-CLI/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/R-CLI/crit.log') | Out-File $FILE
#
#       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/R-RTR/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/R-RTR/crit.log') | Out-File $FILE
#
#       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/R-SRV/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/R-SRV/crit.log') | Out-File $FILE
#
#        Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-SRV/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages Script tail -n10 /opt/logs/L-SRV/crit.log') | Out-File $FILE
#
# echo "###############################################################Syslog: L-SRV auth.*#########################################################################" | Out-File $FILE -Append -NoClobber
#
#   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-SRV/auth.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV Syslog: L-SRV auth.* messages Script cat /opt/logs/L-SRV/auth.log') | Out-File $FILE
#
# echo "###############################################################Syslog: L-FW *.err#########################################################################" | Out-File $FILE -Append -NoClobber
#
#   Invoke-VMScript -vm $LFW -ScriptText "logger -p err L-FW" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-FW Syslog: L-FW *.err Script logger -p err TESTERROR') | Out-File $FILE
#
#   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-FW/error.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV Syslog: L-SRV auth.* messages Script tail -n10 /opt/logs/L-FW/error.log') | Out-File $FILE
#
# echo "###############################################################Syslog: R-RTR alert#########################################################################" | Out-File $FILE -Append -NoClobber
#
#   Invoke-VMScript -vm $RRTR -ScriptText "logger -p alert TESTALERT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-RTR Syslog: R-RTR alert Script logger -p alert TESTALERT') | Out-File $FILE
#
#   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/R-RTR/alert.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV Syslog: R-RTR alert Script tail -n10 /opt/logs/R-RTR/alert.log') | Out-File $FILE
#
#
# echo "###############################################################Syslog: Clients error messages#########################################################################" | Out-File $FILE -Append -NoClobber
#
#   Invoke-VMScript -vm $LCLIA -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-A Syslog: Clients error messages Script logger -p err CLIENTERR') | Out-File $FILE
#
#    Invoke-VMScript -vm $LCLIB -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-CLI-B Syslog: Clients error messages Script logger -p err CLIENTERR') | Out-File $FILE
#
#    Invoke-VMScript -vm $RCLI -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'R-CLI Syslog: Clients error messages Script logger -p err CLIENTERR') | Out-File $FILE
#
#    Invoke-VMScript -vm $OUTCLI -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'OUT-CLI Syslog: Clients error messages Script logger -p err CLIENTERR') | Out-File $FILE
#
#    Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/err.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-SRV Syslog: Clients error message Script tail -n10 /opt/logs/err.log') | Out-File $FILE
#
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
#
# echo "###############################################################'L-FW' RA: OpenVPN basic#########################################################################" | Out-File $FILE -Append -NoClobber
#
#         Invoke-VMScript -vm $LFW -ScriptText "ls /opt/vpn; netstat -npl | grep 1122; grep -v '^[# $]' /etc/openvpn/server.conf; ip a" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File $FILE -Append -NoClobber
#  (Get-Content $FILE).replace('ScriptOutput', 'L-FW RA: OpenVPN basic Script ls /opt/vpn; netstat -npl | grep 1122; grep -v "^[# $]" /etc/openvpn/server.conf; ip a') | Out-File $FILE
#
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
