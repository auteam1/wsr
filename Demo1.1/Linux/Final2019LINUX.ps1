Set-PowerCLIConfiguration -InvalidCertificateAction Ignore

# CONNECT TO ESX
$secpasswd = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("root", $secpasswd)
# Connect-VIServer -Server 10.10.10.203 -User root -Password P@ssw0rd
Connect-VIServer -Server 10.10.10.203 -Credentials $myCredentialsObject

# GET VM's NAME
#Get-View -ViewType VirtualMachine -Property Name
$LCLIA = Get-VM -Name 'L-CLI-A'
$LCLIB = Get-VM -Name 'L-CLI-B'
$LFW = Get-VM -Name 'L-FW'
$LRTRA = Get-VM -Name 'L-RTR-A'
$LRTRB = Get-VM -Name 'L-RTR-B'
$LSRV = Get-VM -Name 'L-SRV'
$OUTCLI = Get-VM -Name 'OUT-CLI'
$RCLI = Get-VM -Name 'R-CLI'
$RFW = Get-VM -Name 'R-FW'
$RRTR = Get-VM -Name 'R-RTR'
$RSRV = Get-VM -Name 'R-SRV'


echo "###############################################################'L-CLI-A R-CLI L-SRV' Hostnames#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "echo '';cat /etc/hostname" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Hostnames command cat /etc/hostname') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LSRV -ScriptText "echo '';cat /etc/hostname" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Hostnames command cat /etc/hostname') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RCLI -ScriptText "echo '';cat /etc/hostname" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Hostnames command cat /etc/hostname') | Out-File D:\resultlin.txt

 echo "###############################################################L-CLI-A R-CLI' IPv4 connectivity#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "ping r-cli.skill39.wsr -c 4; ping 20.20.20.10 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A IPv4 connectivity command ping r-cli.skill39.wsr -c 4; ping 20.20.20.10 -c 4') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RCLI -ScriptText "ping 10.10.10.10 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI IPv4 connectivity command ping 10.10.10.10 -c 4') | Out-File D:\resultlin.txt

  echo "###############################################################'L-FW R-FW' Software installation#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber
  #/#
 Invoke-VMScript -vm $LFW -ScriptText "whereis tcpdump vim lynx" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW Software installation command whereis tcpdump vim lynx') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RFW -ScriptText "whereis tcpdump vim lynx" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW Software installation command whereis tcpdump vim lynx') | Out-File D:\resultlin.txt
 #/#
  echo "###############################################################L-CLI-A R-CLI' Local hostname table#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "cat /etc/hosts" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Local hostname table command cat /etc/hosts') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RCLI -ScriptText "cat /etc/hosts" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Local hostname table command cat /etc/hosts') | Out-File D:\resultlin.txt

  echo "###############################################################L-CLI-A R-CLI' Name lookup order#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "cat /etc/nsswitch.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Name lookup order command cat /etc/nsswitch.conf | grep dns files') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RCLI -ScriptText "cat /etc/nsswitch.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Name lookup order command cat /etc/nsswitch.conf | grep dns files') | Out-File D:\resultlin.txt

  echo "###############################################################L-CLI-A' DHCP: Left side #########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DHCP: Left command dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf') | Out-File D:\resultlin.txt

  echo "###############################################################L-CLI-B' DHCP: Address Reservation #########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIB -ScriptText "dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B DHCP: Address Reservation command dhclient -r; dhclient -v; ip a;ip r; cat /etc/resolv.conf') | Out-File D:\resultlin.txt

    echo "###############################################################L-CLI-A L-CLI-B' DHCP: Relay #########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIB -ScriptText "dhclient -r; dhclient -v" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B DHCP: Address Reservation command dhclient -r; dhclient -v') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $LCLIA -ScriptText "dhclient -r; dhclient -v" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DHCP: Relay command cat /var/lib/dhcp/dhclient.leases') | Out-File D:\resultlin.txt


  echo "###############################################################L-CLI-A' DNS: Forward zone#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "host l-srv.skill39.wsr; host vpn.skill39.wsr; host r-cli.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DNS: Forward zone command nslookup skill39.wsr; nslookup L-SRV.skill39.wsr') | Out-File D:\resultlin.txt


  echo "###############################################################L-CLI-A' DNS: Reverse zone#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "host 172.16.20.10; host 192.168.20.10" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DNS: Reverse zone command host 172.16.20.10; host 192.168.20.10') | Out-File D:\resultlin.txt

echo "###############################################################L-CLI-A' DNS: ISP Forwarders#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "host ya.ru" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DNS: ISP Forwarders command host ya.ru') | Out-File D:\resultlin.txt


echo "###############################################################'R-CLI' DNS: Slave#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $RCLI -ScriptText "host r-fw.skill39.wsr; cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI DNS: Slave command host r-fw.skill39.wsr; cat /etc/resolv.conf') | Out-File D:\resultlin.txt

echo "###############################################################L-CLI-A' DNS: Delegation#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "host -v ext.skill39.wsr; host test.ext.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DNS: Delegation command host ext.skill39.wsr; host test.ext.skill39.wsr') | Out-File D:\resultlin.txt


 echo "###############################################################L-CLI-B L-CLI-A' DNS: Dynamic DNS#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIB -ScriptText "host L-CLI-A; host L-CLI-B" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B DNS: Dynamic DNS command host L-CLI-A; host L-CLI-B') | Out-File D:\resultlin.txt


 Invoke-VMScript -vm $LCLIA -ScriptText "ifdown ens32" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A DNS: Dynamic DNS command ifdown ens32') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $LCLIB -ScriptText "host L-CLI-A" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW DNS: Dynamic DNS command host L-CLI-A') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LCLIA -ScriptText "ifup ens32" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B DNS: Dynamic DNS command ifup ens32') | Out-File D:\resultlin.txt


 echo "###############################################################L-FW R-FW' Internet Gateway (Dynamic NAT)#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

Invoke-VMScript -vm $LFW -ScriptText "ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat " -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW Internet Gateway (Dynamic NAT) command ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat ') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $RFW -ScriptText "ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat " -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW Internet Gateway (Dynamic NAT) command  ping 10.10.10.10 -c 4; ping 20.20.20.10 -c 4; iptables -L -v -t nat ') | Out-File D:\resultlin.txt


echo "###############################################################L-SRV' LDAP: Users, Groups and OU#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LSRV -ScriptText "ldapsearch -x cn=user -b ou=users,dc=skill39,dc=wsr; ldapsearch -x cn=Admin -b ou=groups,dc=skill39,dc=wsr; ldapsearch -x cn=VPN -b ou=groups,dc=skill39,dc=wsr > /root/ldapcheck; cat /root/ldapcheck; rm -rf /root/ldapcheck" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Users, Groups and OU command ldapsearch -x cn=user -b ou=users,dc=skill39,dc=wsr; ldapsearch -x cn=Admin -b ou=groups,dc=skill39,dc=wsr; ldapsearch -x cn=VPN -b ou=groups,dc=skill39,dc=wsr > /root/ldapcheck; cat /root/ldapcheck; rm -rf /root/ldapcheck') | Out-File D:\resultlin.txt

echo "###############################################################'L-CLI-A L-CLI-B' LDAP: Clients authentication#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
{
 Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

if(Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash)
{
 Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user tux password toor YES" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user tux password toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Clients authentication') | Out-File D:\resultlin.txt
}


echo "###############################################################'L-CLI-A L-CLI-B' LDAP: Home directory#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber


if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
{Invoke-VMScript -vm $LCLIA -ScriptText "echo 'Test321' > ~/test321; mount" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Home directory command echo "Test321" > ~/test321; mount ') | Out-File D:\resultlin.txt
 }
 else{
 Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Home directory from user user66 password P@ssw0rd toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Home directory') | Out-File D:\resultlin.txt
 }

 if(Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user user66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
 {
 Invoke-VMScript -vm $LCLIB -ScriptText "cat ~/test321" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Home directory command cat ~/test321') | Out-File D:\resultlin.txt
 }
 else{
  Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Home directory from user user66 password P@ssw0rd toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Home directory') | Out-File D:\resultlin.txt
 }

 echo "###############################################################'L-CLI-B' LDAP: Home directory quota#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

   Invoke-VMScript -vm $LCLIB -ScriptText "dd if=/dev/zero of=/tmp/big; bs=1024 count=10240" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Home directory quota command dd if=/dev/zero of=/tmp/big; bs=1024 count=10240') | Out-File D:\resultlin.txt

 if(Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Authentication from user user50 password P@ssw0rd YES" -GuestUser 'user50' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
 {
 Invoke-VMScript -vm $LCLIB -ScriptText "cat ~/test321" -GuestUser 'user50' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Home directory quota command cat ~/test321') | Out-File D:\resultlin.txt
 }
 else{
  Invoke-VMScript -vm $LCLIB -ScriptText "echo LDAP Home directory from user user50 password P@ssw0rd toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B LDAP: Home directory quota') | Out-File D:\resultlin.txt
 }


echo "###############################################################'L-CLI-A L-SRV' LDAP: Logon restriction#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
{
 Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'vpn1' -GuestPassword 'Passw0rd' -ScriptType Bash)
{
 Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd YES" -GuestUser 'vpn1' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash)
{
 Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user tux password toor YES" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user tux password toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

if(Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
{
 Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd YES" -GuestUser 'user66' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user uer66 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

if(Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP" -GuestUser 'vpn1' -GuestPassword 'Passw0rd' -ScriptType Bash)
{
 Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd YES" -GuestUser 'vpn1' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user vpn1 password Passw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

if(Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash)
{
 Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user tux password toor YES" -GuestUser 'tux' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File D:\resultlin.txt
}
else{
Invoke-VMScript -vm $LSRV -ScriptText "echo LDAP Authentication from user tux password toor NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV LDAP: Clients authentication') | Out-File D:\resultlin.txt
}

echo "###############################################################'L-CLI-A' LDAP: Process Limit#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

if(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user47 password P@ssw0rd YES; ulimit -a" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: authentication user47 and command ulimit -a') | Out-File D:\resultlin.txt
}
elseif(Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash)
{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user47 password P@ssw0rd YES; ulimit -a" -GuestUser 'user47' -GuestPassword 'P@ssw0rd' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: authentication user47 and after command ulimit -a') | Out-File D:\resultlin.txt
}
else
{
Invoke-VMScript -vm $LCLIA -ScriptText "echo LDAP Authentication from user user47 password P@ssw0rd NO" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A LDAP: authentication user47') | Out-File D:\resultlin.txt
}

echo "###############################################################All host Syslog: All Critical messages#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

Invoke-VMScript -vm $LCLIA -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $LCLIB -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $LFW -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $LRTRA -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-RTR-A Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LRTRB -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-RTR-B Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LSRV -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $OUTCLI -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RCLI -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RFW -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RRTR -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-RTR Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $RSRV -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LSRV -ScriptText "logger -p crit TESTCRIT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Syslog: All Critical messages command logger -p crit TESTCRIT') | Out-File D:\resultlin.txt

   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-CLI-A/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/L-CLI-A/crit.log') | Out-File D:\resultlin.txt

    Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-CLI-B/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/L-CLI-B/crit.log') | Out-File D:\resultlin.txt

    Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-FW/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/L-FW/crit.log') | Out-File D:\resultlin.txt

     Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/R-FW/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/R-FW/crit.log') | Out-File D:\resultlin.txt

     Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/L-RTR-A/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/L-RTR-A/crit.log') | Out-File D:\resultlin.txt

      Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-RTR-B/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/L-RTR-B/crit.log') | Out-File D:\resultlin.txt

       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/OUT-CLI/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/OUT-CLI/crit.log') | Out-File D:\resultlin.txt

       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/R-CLI/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/R-CLI/crit.log') | Out-File D:\resultlin.txt

       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10  /opt/logs/R-RTR/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/R-RTR/crit.log') | Out-File D:\resultlin.txt

       Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/R-SRV/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/R-SRV/crit.log') | Out-File D:\resultlin.txt

        Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-SRV/crit.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV Syslog: All Critical messages command tail -n10 /opt/logs/L-SRV/crit.log') | Out-File D:\resultlin.txt

 echo "###############################################################Syslog: L-SRV auth.*#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-SRV/auth.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Syslog: L-SRV auth.* messages command cat /opt/logs/L-SRV/auth.log') | Out-File D:\resultlin.txt

  echo "###############################################################Syslog: L-FW *.err#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

   Invoke-VMScript -vm $LFW -ScriptText "logger -p err L-FW" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW Syslog: L-FW *.err command logger -p err TESTERROR') | Out-File D:\resultlin.txt

   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/L-FW/error.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Syslog: L-SRV auth.* messages command tail -n10 /opt/logs/L-FW/error.log') | Out-File D:\resultlin.txt

  echo "###############################################################Syslog: R-RTR alert#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

   Invoke-VMScript -vm $RRTR -ScriptText "logger -p alert TESTALERT" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-RTR Syslog: R-RTR alert command logger -p alert TESTALERT') | Out-File D:\resultlin.txt

   Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/R-RTR/alert.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Syslog: R-RTR alert command tail -n10 /opt/logs/R-RTR/alert.log') | Out-File D:\resultlin.txt


  echo "###############################################################Syslog: Clients error messages#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

   Invoke-VMScript -vm $LCLIA -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Syslog: Clients error messages command logger -p err CLIENTERR') | Out-File D:\resultlin.txt

    Invoke-VMScript -vm $LCLIB -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B Syslog: Clients error messages command logger -p err CLIENTERR') | Out-File D:\resultlin.txt

    Invoke-VMScript -vm $RCLI -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Syslog: Clients error messages command logger -p err CLIENTERR') | Out-File D:\resultlin.txt

    Invoke-VMScript -vm $OUTCLI -ScriptText "logger -p err CLIENTERR" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI Syslog: Clients error messages command logger -p err CLIENTERR') | Out-File D:\resultlin.txt

    Invoke-VMScript -vm $LSRV -ScriptText "tail -n10 /opt/logs/err.log" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Syslog: Clients error message command tail -n10 /opt/logs/err.log') | Out-File D:\resultlin.txt


echo "###############################################################'L-FW' Routing: Dynamic#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

    Invoke-VMScript -vm $LFW -ScriptText "ip r; vtysh -e 'sh ip ospf nei' ; vtysh -e 'sh ip route ospf'" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW Routing: Dynamic command ip r; vtysh -e sh ip ospf nei; vtysh -e sh ip route ospf') | Out-File D:\resultlin.txt

echo "###############################################################'R-FW' Routing: OSPF over GRE#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

     Invoke-VMScript -vm $RFW -ScriptText "vtysh -e 'sh ip ospf nei'" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW Routing: OSPF over GRE command vtysh -e sh ip ospf nei') | Out-File D:\resultlin.txt

echo "###############################################################'L-CLI-A' Routing: Filter#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

Invoke-VMScript -vm $LCLIA -ScriptText "timeout 10 tcpdump -i ens32 -n 'ip[9] == 89'" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'LCLIA Routing: Filter command  timeout 10 tcpdump -i eth1 -n ip[9] == 89') | Out-File D:\resultlin.txt

echo "###############################################################'R-FW' IPSec Active Status#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

     Invoke-VMScript -vm $RFW -ScriptText "ipsec status; cat /etc/ipsec.confs" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW IPSec Active Status command ipsec status cat /etc/ipsec.conf') | Out-File D:\resultlin.txt

echo "###############################################################'R-FW' IPSec Parameters and GRE only#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

     Invoke-VMScript -vm $RFW -ScriptText "ipsec status" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW IPSec Parameters and GRE only command ipsec status') | Out-File D:\resultlin.txt

echo "###############################################################'R-FW' GRE Tunnel#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

     Invoke-VMScript -vm $RFW -ScriptText "ip a; ping 10.5.5.2 -c 4; ping 10.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW GRE Tunnel command ip a; ping 10.5.5.2 -c 4 ; ping 10.5.5.1 -c 4') | Out-File D:\resultlin.txt

echo "###############################################################'R-FW' GRE over IPSec#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

     Invoke-VMScript -vm $RFW -ScriptText "ipsec status" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW GRE over IPSec command tcpdump -I any  esp -v') | Out-File D:\resultlin.txt

 echo "###############################################################'L-FW' RA: OpenVPN basic#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

         Invoke-VMScript -vm $LFW -ScriptText "ls /opt/vpn; netstat -npl | grep 1122; grep -v '^[# $]' /etc/openvpn/server.conf; ip a" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW RA: OpenVPN basic command ls /opt/vpn; netstat -npl | grep 1122; grep -v "^[# $]" /etc/openvpn/server.conf; ip a') | Out-File D:\resultlin.txt

 echo "###############################################################'OUT-CLI' RA: VPN Connect Script#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

         Invoke-VMScript -vm $OUTCLI -ScriptText "ip a; ls /opt/vpn; cd ~ ; stop_vpn.sh ; sleep 5; ping 5.5.5.1 -c 4 ;start_vpn.sh vpn66 Passw0rd; sleep 5 ; ip a; ping 5.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI RA: VPN Connect Script command ip a; ls /opt/vpn; cd ~ ; stop_vpn.sh ; sleep 5; ping 5.5.5.1 -c 4 ;start_vpn.sh vpn66 Passw0rd; sleep 5 ; ip a; ping 5.5.5.1 -c 4') | Out-File D:\resultlin.txt

  echo "###############################################################'OUT-CLI' RA: VPN Disconnect Script#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

         Invoke-VMScript -vm $OUTCLI -ScriptText "op a; stop_vpn.sh;sleep 5; ip a; ping 5.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI RA: VPN Disconnect Script command stop_vpn.sh; ip a; ping 5.5.5.1 -c 4') | Out-File D:\resultlin.txt


  echo "###############################################################'OUT-CLI' RA: OpenVPN LDAP authentication 	RA: OpenVPN Client Autoconf#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

           Invoke-VMScript -vm $OUTCLI -ScriptText "cat /etc/resolv.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI RA: VPN Disconnect Script command cat /etc/resolv.conf') | Out-File D:\resultlin.txt

         Invoke-VMScript -vm $OUTCLI -ScriptText "start_vpn.sh vpn66 VRONPassw0rd; sleep 5; ip a; ping 5.5.5.1 -c 4" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI RA: VPN Disconnect Script command start_vpn.sh vpn66 Passw0rd') | Out-File D:\resultlin.txt

 echo "###############################################################'OUT-CLI' SSH: Users#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

         Invoke-VMScript -vm $OUTCLI -ScriptText "sshpass -p P@ssw0rd ssh -o 'StrictHostKeyChecking no' ssh_c@vpn.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI SSH: Users command sshpass -p toor ssh -o StrictHostKeyChecking no root@vpn.skill39.wsr') | Out-File D:\resultlin.txt


echo "###############################################################'OUT-CLI' SSH: Key authentication#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

         Invoke-VMScript -vm $OUTCLI -ScriptText "timeout 10 ssh ssh_p@vpn.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI SSH: Key authentication command sshpass -p toor ssh vpn.skill39.wsr') | Out-File D:\resultlin.txt


  echo "###############################################################'L-SRV' RAID#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

  Invoke-VMScript -vm $LSRV -ScriptText "lsblk" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV RAID command lsblk') | Out-File D:\resultlin.txt


 echo "###############################################################'R-RTR' LVM: Volume LVM: Snapshots LVM: Snapshot Filename#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

         Invoke-VMScript -vm $RRTR -ScriptText "lvs; lvdisplay" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-RTR LVM: Volume LVM: Snapshots LVM: Snapshot Filename command lvs; lvdisplay') | Out-File D:\resultlin.txt


  echo "###############################################################'L-CLI-A L-SRV L-CLI-B' RSYNC: Sync#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "cp /etc/passwd /root/sync/cli_to_srv.test && sleep 90" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'LCLIA RSYNC: Sync command cp /etc/passwd /root/sync/cli_to_srv.test && sleep 90') | Out-File D:\resultlin.txt


 Invoke-VMScript -vm $LSRV -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'LSRV RSYNC: Sync command ls /opt/sync') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LCLIB -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'LCLIB RSYNC: Sync command ls /opt/sync') | Out-File D:\resultlin.txt


   echo "###############################################################'L-CLI-A L-SRV L-CLI-B' RSYNC: Delete Sync#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LCLIA -ScriptText "rm -f /root/sync/cli_to_srv.test && sleep 90" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'LCLIA RSYNC: Delete Sync command rm -f /root/sync/cli_to_srv.test && sleep 90') | Out-File D:\resultlin.txt


 Invoke-VMScript -vm $LSRV -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV RSYNC: Delete Sync command ls /opt/sync') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LCLIB -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B RSYNC: Delete Sync command ls /opt/sync') | Out-File D:\resultlin.txt

   Invoke-VMScript -vm $LCLIA -ScriptText "ls /opt/sync" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A RSYNC: Delete Sync command ls /opt/sync') | Out-File D:\resultlin.txt

    echo "###############################################################'L-CLI-A L-SRV 'RSYNC: Security#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $LSRV -ScriptText "cat /etc/rsyncd.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV  RSYNC: Security command cat /etc/rsyncd.conf') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $LCLIA -ScriptText "cat /root/sync.sh" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A  RSYNC: Security command cat /root/sync.sh') | Out-File D:\resultlin.txt

  Invoke-VMScript -vm $LCLIA -ScriptText "crontab -l" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A  RSYNC: Security command crontab -l') | Out-File D:\resultlin.txt

 echo "###############################################################L-CLI-A AND R-CLI AND OUT-CLI and L-CLI-B' Web: http/s intra.skill39.wsr , http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https Web: http://www.skill39.wsr/  : Static content Web: http://www.skill39.wsr/date.php  : PHP content #########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

Invoke-VMScript -vm $LCLIA -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Web: http/s intra.skill39.wsr, Web: Trusted SSL , Web: http –> https command curl -L http://intra.skill39.wsr ') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $LCLIB -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B Web: http/s intra.skill39.wsr , Web: Trusted SSL , Web: http –> https command curl -L http://intra.skill39.wsr') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI Web: http/s intra.skill39.wsr , Web: Trusted SSL , Web: http –> https command curl -L http://intra.skill39.wsr') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $RCLI -ScriptText "curl -L http://intra.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Web: http/s intra.skill39.wsr , Web: Trusted SSL , Web: http –> https command curl -L http://intra.skill39.wsr') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $LCLIA -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Web: http/s www.skill39.wsr, Web: Trusted SSL , Web: http –> https command curl -L http://www.skill39.wsr ') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $LCLIB -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-B Web: http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https command curl -L http://www.skill39.wsr') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI Web: http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https command curl -L http://www.skill39.wsr') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $RCLI -ScriptText "curl -L http://www.skill39.wsr" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Web: http/s www.skill39.wsr , Web: Trusted SSL , Web: http –> https command curl -L http://www.skill39.wsr') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/index.html" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI Web: http://www.skill39.wsr/  : Static content') | Out-File D:\resultlin.txt

 Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/date.php" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI  Web: http://www.skill39.wsr/date.php  : PHP content') | Out-File D:\resultlin.txt

 echo "###############################################################'R-FW' NGINX: Proxy#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber
  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/nginx/conf.d/task.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW NGINX: Proxy command cat /etc/nginx/conf.d/task.conf') | Out-File D:\resultlin.txt

 echo "###############################################################'OUT-CLI' NGINX: SSL and Redirection#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/index.html" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI  Web: http://www.skill39.wsr/index.html NGINX: SSL and Redirection') | Out-File D:\resultlin.txt

 echo "###############################################################'R-FW' NGINX: Backend Health check#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber
  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/nginx/conf.d/task.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW NGINX: Backend Health check command cat /etc/nginx/conf.d/task.conf') | Out-File D:\resultlin.txt

echo "###############################################################'R-FW OUT-CLI R-SRV' NGINX: Caching capability#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/nginx/conf.d/task.conf" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW NGINX: Caching capability command cat /etc/nginx/conf.d/task.conf') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/date.php  && sleep 10 curl -L http://www.skill39.wsr/date.php" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI  NGINX: Caching capability command curl -L http://www.skill39.wsr/date.php  && sleep 10 curl -L http://www.skill39.wsr/date.php') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $RSRV -ScriptText "echo 'SECRET_STRING' >> /var/www/html/out/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV  NGINX: Caching capability command echo "SECRET_STRING" >> /var/www/html/out/secret.txt') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI  NGINX: Caching capability command curl -L http://www.skill39.wsr/secret.txt') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $RSRV -ScriptText "rm -f /var/www/html/out/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-SRV  NGINX: Caching capability command rm -f /var/www/html/out/secret.txt ') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $OUTCLI -ScriptText "curl -L http://www.skill39.wsr/secret.txt  && sleep 50  && curl -L http://www.skill39.wsr/secret.txt" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'OUT-CLI  NGINX: Caching capability command curl -L http://www.skill39.wsr/secret.txt  && sleep 50  && curl -L http://www.skill39.wsr/secret.txt') | Out-File D:\resultlin.txt

 echo "###############################################################'R-FW' OpenSSL: CA#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

 Invoke-VMScript -vm $RFW -ScriptText "ls /etc/ca; openssl ca" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW OpenSSL: CA command ls /etc/ca') | Out-File D:\resultlin.txt

 echo "###############################################################'R-FW' Certificate Attributes#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

  Invoke-VMScript -vm $RFW -ScriptText "cat /etc/ca/cacert.pem" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW Certificate Attributes command cat /etc/ca/cacert.pem') | Out-File D:\resultlin.txt

 echo "###############################################################'L-FW R-FW' IPTables: Block input traffic IPTables: DNS port forwarding IPTables: Allow GRE & IPSec IPTables: Allow SSH IPTables: Allow VPN IPTables: No Access to www.skill39.wsr via OpenVPN IPTables: HTTP/HTTPS#########################################################################" | Out-File D:\resultlin.txt -Append -NoClobber

   Invoke-VMScript -vm $RFW -ScriptText "iptables -L -v -n -t filter; iptables -L -v -n -t nat" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-FW IPTables: Block input traffic IPTables: DNS port forwarding IPTables: Allow GRE & IPSec IPTables: Allow SSH IPTables: Allow VPN IPTables: No Access to www.skill39.wsr via OpenVPN IPTables: HTTP/HTTPS command iptables -L -v -n -t filter; iptables -L -v -t nat') | Out-File D:\resultlin.txt

Invoke-VMScript -vm $LFW -ScriptText "iptables -L -v -n -t filter; iptables -L -v -n -t nat" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
(Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-FW IPTables: Block input traffic IPTables: DNS port forwarding IPTables: Allow GRE & IPSec IPTables: Allow SSH IPTables: Allow VPN IPTables: No Access to www.skill39.wsr via OpenVPN IPTables: HTTP/HTTPS command iptables -L -v -n -t filter; iptables -L -v -t nat') | Out-File D:\resultlin.txt
