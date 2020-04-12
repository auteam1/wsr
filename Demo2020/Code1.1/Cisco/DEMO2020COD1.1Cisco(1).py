'''

 This script consists of 3 section, separate through todo comments:

 0. Dependencies
 Section with links to download all needed dependencies

 1. Init
 This block describes all the necessary constants and variables

 2. Main functions
 Function block in which all necessary functions are defined

 3. Start of check
 The verification process itself

'''

# TODO: 0. Dependencies

import datetime
import time
import sys
from netmiko import ConnectHandler
# How to install netmiko:
# pip install netmiko
# https://www.jaacostan.com/2018/09/how-to-install-netmiko-on-windows.html
# https://pypi.org/project/netmiko/

# TODO: 1. Init

USER           = 'wsruser'     # Username
PASSWORD       = 'network'     # Password
ENABLE_PASS    = 'wsr'         # Enable password
SSH_PORT       = 22            # Port for SSH connection
DEVICES_NAME   = [ 'HQ1', 'FW1', 'BR1', 'SW1', 'SW2', 'SW3' ]
IP_ADDRESSES   = { 'HQ1'   :   ['1.1.1.1', '30.78.21.1']             ,
                   'FW1'   :   ['30.78.87.2', '192.168.254.2']       ,
                   'BR1'   :   ['172.16.3.3', '172.16.1.2',
                                   '3.3.3.3', '192.168.254.3']       ,
                   'SW1'   :   ['10.100.100.10', '192.168.254.10']   ,
                   'SW2'   :   ['10.100.100.20', '192.168.254.20']   ,
                   'SW3'   :   ['10.100.100.30', '192.168.254.30'] 
                   }

# TODO: 2. Main functions

# Just write in result file with description
#
# Use: Write('Sobaka')
def Write(string):
    openedFile.write(string + '\n')
    print(string)

# Function for send command to network device
#
# Use: SendCommand('HQ1','sh ip int b')
#
# OR
#
# hosts = ['HQ1', 'BR1']
# commands = ['sh run int tun1 | i mode', 'sh crypto isakmp sa']
# Use: SendCommand(hosts, commands)
#
# OR
#
# Use: SendCommand(['HQ1', 'BR1'], ['sh run int tun1 | i mode','sh crypto isakmp sa' ])
#
# If not connected, return 0
def SendCommand(host_arr, command_arr, description):
# Check that all hosts available
    if(description):
        Write('#########################--=' + description + '=--#########################')
    for host in host_arr:
        if host in DEAD_DEVICES:
            Write('Not connected to '  + host + '\n\n\n')
            return 0
    global con
    for command in command_arr:
        Write('Script	     : ' + command + '\n\n')
        for host in host_arr:
            Write('Device       : ' + host)    
            Write(con[host].send_command(command) + '\n\n\n')

# TODO: 3. Start of check

# Set STAND_NUMBER
try:
    STAND_NUMBER = int(sys.argv[1])
except:
    while True:
        STAND_NUMBER = input('Stand number: ')
        try: 
            int(STAND_NUMBER)
            break
        except:
            continue

# Set COMPETITOR
try:
    COMPETITOR = str(sys.argv[2])
except:
    while True:
        COMPETITOR = input('Competitor FirstnameLastname: ')
        try: 
            str(COMPETITOR)
            break
        except:
            continue

# Create result file and define Script Start Time
openedFile  = open( str(STAND_NUMBER) + "_RESULT" + ".txt", "w")
con = {}

# Empty list with dead devices
DEAD_DEVICES = list()

# Create conn dictionary
for host in DEVICES_NAME:
    if host == 'HQ1':
        username = 'radius'
        password = 'cisco'
    else:
        username = USER
        password = PASSWORD        
    for ip in IP_ADDRESSES[host]:
        try:
            DEVICES_PARAMS = {  'device_type'   :   'cisco_ios'   ,
                                'ip'            :   ip            ,
                                'username'      :   username      ,
                                'password'      :   password      ,
                                'secret'        :   ENABLE_PASS   ,
                                'port'          :   SSH_PORT
                                }
            con[host] = ConnectHandler(**DEVICES_PARAMS)
            con[host].enable()
            Write('Successfully connected to ' + host)
            break
        except:
            if ip == IP_ADDRESSES[host][-1]:
                DEAD_DEVICES.append(host)
                Write('Not connected to ' + host)
                break            
            continue

#############################--=START=--####################################

start = datetime.datetime.now()
Write('\n\n' + start.strftime("%Y-%m-%d %H:%M") + '\n\n')
Write(COMPETITOR)

# TODO: C1.1 Hostname

hosts       = ['HQ1', 'SW1']
commands    = ['sh run | i hostname']
description = 'Hostname'
SendCommand(hosts, commands, description)

# TODO: C1.2 Domain name

hosts       = ['SW2', 'SW3']
commands    = ['sh run | i ip domain']
description = 'Domain name'
SendCommand(hosts, commands, description)

# TODO: C1.3 Local user

hosts       = ['FW1', 'SW1']
commands    = ['sh run | i username ' + USER]
description = 'Local user'
SendCommand(hosts, commands, description)

# TODO: C1.4 Enable password

hosts       = ['SW2', 'BR1']
commands    = ['sh run | i enable secret']
description = 'Enable password'
SendCommand(hosts, commands, description)

# TODO: C1.5 Password encryption

hosts       = ['SW1', 'BR1']
commands    = ['sh run | i service password']
description = 'Password encryption'
SendCommand(hosts, commands, description)

# TODO: C1.6 Local AAA

hosts       = ['HQ1', 'FW1']
commands    = ['sh run | i aaa']
description = 'Local AAA'
SendCommand(hosts, commands, description)

# TODO: C1.7 IPv4 addressing and connectivity

hosts       = ['HQ1']
commands    = ['ping 8.8.8.8 source 30.78.21.1']
description = 'IPv4 addressing and connectivity'
SendCommand(hosts, commands, description)

# TODO: C1.8 IPv6 addressing and connectivity

hosts       = ['HQ1']
commands    = ['ping 2001:A:B:ACAD::10 source 2001:A:B:DEAD::1']
description = 'IPv6 addressing and connectivity'
SendCommand(hosts, commands, description)

# TODO: C1.9 Radius auth

hosts       = ['HQ1']
commands    = ['test aaa group radius server 172.16.20.20 auth-port 1812 acct-port 1813 radius cisco legacy']
description = 'Radius auth'
SendCommand(hosts, commands, description)

# TODO: C1.10 Remote management

hosts       = ['SW1', 'BR1']
commands    = ['sh ip ssh | i version']
description = 'Remote management'
SendCommand(hosts, commands, description)

# TODO: C1.11 VTP Server

hosts       = ['SW1']
commands    = ['show vtp status | i Operating Mode']
description = 'VTP Server'
SendCommand(hosts, commands, description)

# TODO: C1.12 VTP Client

hosts       = ['SW2', 'SW3']
commands    = ['show vtp status | i Operating Mode']
description = 'VTP Client'
SendCommand(hosts, commands, description)

# TODO: C1.13 DTP manipulation

hosts       = ['SW1', 'SW2', 'SW3']
commands    = ['show int trun | i trunking']
description = 'DTP manipulation'
SendCommand(hosts, commands, description)

# TODO: C1.14 Etherchannel LACP

hosts       = ['SW1', 'SW2']
commands    = ['sh ether sum | i LACP', 'sh ether detail | i Channel group = 1']
description = 'Etherchannel LACP'
SendCommand(hosts, commands, description)

# TODO: C1.15 Etherchannel PAgP

hosts       = ['SW1', 'SW3']
commands    = ['sh ether sum | i PAgP', 'sh ether detail | i Channel group = 2']
description = 'Etherchannel PAgP'
SendCommand(hosts, commands, description)

# TODO: C1.16 STP enable

hosts       = ['SW1', 'SW2', 'SW3']
commands    = ['sh span | i protocol']
description = 'STP enable'
SendCommand(hosts, commands, description)

# TODO: C1.17 STP root priority

hosts       = ['SW1', 'SW2']
commands    = ['sh span | i VLAN|Root ID|This']
description = 'STP root priority'
SendCommand(hosts, commands, description)

# TODO: C1.18 STP portfast

hosts       = ['SW1']
commands    = ['sh spanning-tree interface fastEthernet 1/0/1 portfast']
description = 'STP portfast'
SendCommand(hosts, commands, description)

# TODO: C1.19 VLAN port assignment

hosts       = ['SW2', 'SW3']
commands    = ['sh ip int b | i 0/10', 'sh vl b | i 0/10']
description = 'VLAN port assignment'
SendCommand(hosts, commands, description)

# TODO: C1.20 HQ1 FW1 trunk

hosts       = ['FW1']
commands    = ['sh sw vl', 'sh run int e0/2']
description = 'HQ1 FW1 trunk'
SendCommand(hosts, commands, description)

# TODO: C1.21 SW1 interface shutdown

hosts       = ['SW1']
commands    = ['sh ip int b | i 24']
description = 'SW1 interface shutdown'
SendCommand(hosts, commands, description)

# TODO: C1.22 Shutdown unused ports

hosts       = ['SW1', 'SW2', 'SW3']
commands    = ['sh ip int b | i administratively down']
description = 'Shutdown unused ports'
SendCommand(hosts, commands, description)

# TODO: C1.23 Vlan unused ports

hosts       = ['SW1', 'SW2', 'SW3']
commands    = ['sh vl b | s 600']
description = 'Vlan unused ports'
SendCommand(hosts, commands, description)

# TODO: C1.24 FW IPoE ISP1

hosts       = ['FW1']
commands    = ['sh int ip b ']
description = 'FW IPoE ISP1'
SendCommand(hosts, commands, description)

# TODO: C1.25 FW IPoE ISP2

hosts       = ['FW1']
commands    = ['sh int ip b']
description = 'FW IPoE ISP2'
SendCommand(hosts, commands, description)

# TODO: C1.26 L2 VPN ISP3

hosts       = ['BR1']
commands    = ['ping 172.16.3.2', 'ping 172.16.3.1']
description = 'L2 VPN ISP3'
SendCommand(hosts, commands, description)

# TODO: C1.27 PPP Multilink

hosts       = ['BR1']
commands    = ['show ppp multilink', 'show ip int b | i Multilink']
description = 'PPP Multilink'
SendCommand(hosts, commands, description)

# TODO: C1.28 BR1 HDLC ISP1

hosts       = ['BR1']
commands    = ['sh int Serial0/2/0 | i Encap|Serial0/2/0', 'sh ip int Serial0/2/0 | i Address']
description = 'BR1 HDLC ISP1'
SendCommand(hosts, commands, description)

# TODO: C1.29 OSPF neighbors

hosts       = ['HQ1']
commands    = ['sh ip ospf neighbors']
description = 'OSPF neighbors'
SendCommand(hosts, commands, description)

hosts       = ['FW1']
commands    = ['sh ospf neighbors']
SendCommand(hosts, commands, False)

# TODO: C1.30 OSPF routes

hosts       = ['HQ1']
commands    = ['sh ip route ospf | b Gateway']
description = 'OSPF routes'
SendCommand(hosts, commands, description)

hosts       = ['FW1']
commands    = ['sh route ospf | b Gateway']
SendCommand(hosts, commands, False)

# TODO: C1.31 OSPF passive interface

hosts       = ['HQ1']
commands    = ['sh ip proto | s ospf']
description = 'OSPF passive interface'
SendCommand(hosts, commands, description)

# TODO: C1.32 OSPF BR1

hosts       = ['BR1']
commands    = ['sh ip proto | s ospf', 'sh ip ospf ne', 'sh ip route ospf | b Gateway']
description = 'OSPF passive interface'
SendCommand(hosts, commands, description)

# TODO: C1.33 BGP HQ1

hosts       = ['HQ1']
commands    = ['sh ip bgp sum', 'sh ip bgp | b Network', 'sh ip route bgp | b Gateway']
description = 'BGP HQ1'
SendCommand(hosts, commands, description)

# TODO: C1.34 BGP FW1

hosts       = ['FW1']
commands    = ['sh bgp sum', 'sh bgp | b Network', 'sh route bgp | b Gateway']
description = 'BGP FW1'
SendCommand(hosts, commands, description)

# TODO: C1.35 BGP BR1

hosts       = ['BR1']
commands    = ['sh ip bgp sum', 'sh ip bgp | b Network', 'sh ip route bgp | b Gateway']
description = 'BGP BR1'
SendCommand(hosts, commands, description)

# TODO: C1.36 EIGRP neighbors

hosts       = ['HQ1', 'BR1']
commands    = ['sh ip eigrp neighbors']
description = 'EIGRP neighbors'
SendCommand(hosts, commands, description)

# TODO: C1.37 EIGRP routes

hosts       = ['HQ1', 'BR1']
commands    = ['sh ip route eigrp']
description = 'EIGRP routes'
SendCommand(hosts, commands, description)

# TODO: C1.38 NTP

hosts       = ['BR1', 'SW1', 'HQ1']
commands    = ['sh ntp as', 'sh run | i timezone', 'sh clock']
description = 'NTP'
SendCommand(hosts, commands, description)

# TODO: C1.39 NAT HQ1

hosts       = ['HQ1']
commands    = ['-']
description = '-'
SendCommand(hosts, commands, description)

# TODO: C1.40 NAT BR1

hosts       = ['BR1']
commands    = ['-']
description = '-'
SendCommand(hosts, commands, description)

# TODO: C1.41 DHCP

hosts       = ['HQ1']
commands    = ['sh ip dhcp bind', 'sh run | s dhcp']
description = 'DHCP'
SendCommand(hosts, commands, description)

# TODO: C1.42 PPPoE server

hosts       = ['BR1']
commands    = ['sh pppoe summ', 'sh ppp all']
description = 'PPPoE server'
SendCommand(hosts, commands, description)

# TODO: C1.43 PPPoE session

hosts       = ['BR1']
commands    = ['sh pppoe summ', 'sh ppp all']
description = 'PPPoE server'
SendCommand(hosts, commands, description)

# TODO: C1.44 User1 privilege

hosts       = ['BR1']
commands    = ['sh run | i user1', 'sh run | i privilege exec level 5']
description = 'User1 privilege'
SendCommand(hosts, commands, description)

# TODO: C1.45 User2 view

hosts       = ['BR1']
commands    = ['sh run | i user2', 'sh run | s view']
description = 'User2 view'
SendCommand(hosts, commands, description)

# TODO: C1.46 Port Security

hosts       = ['SW2']
commands    = ['sh port-security interface fastEthernet 0/10']
description = 'Port Security'
SendCommand(hosts, commands, description)

# TODO: C1.47 Syslog

hosts       = ['HQ1', 'FW1']
commands    = ['sh run | i logging']
description = 'Syslog'
SendCommand(hosts, commands, description)

# TODO: C1.48 SNMP

hosts       = ['HQ1', 'FW1']
commands    = ['sh run | i snmp']
description = 'SNMP'
SendCommand(hosts, commands, description)

# TODO: C1.49 Archive

hosts       = ['HQ1']
commands    = ['sh run | s archive']
description = 'Archive'
SendCommand(hosts, commands, description)

# TODO: C1.50 GRE tunnel ipv4

hosts       = ['HQ1', 'BR1']
commands    = ['sh run int tun1', 'ping 172.16.1.1', 'ping 172.16.1.2']
description = 'GRE tunnel ipv4'
SendCommand(hosts, commands, description)

# TODO: C1.51 GRE tunnel ipv6

hosts       = ['HQ1', 'BR1']
commands    = ['ping 2001::1', 'ping 2001::2']
description = 'GRE tunnel ipv6'
SendCommand(hosts, commands, description)

# TODO: C1.52 GRE protection tunnel

hosts       = ['HQ1', 'BR1']
commands    = ['sh ip int b | i Tunnel1', 'sh crypto isakmp key', 'sh crypto isakmp policy', 'sh crypto isakmp sa', 'sh crypto ipsec sa | i inbound esp|outbound esp|Status']
description = 'x'
SendCommand(hosts, commands, description)

end = datetime.datetime.now()
Write('\n\n Start time:' + start.strftime("%Y-%m-%d %H:%M") + '\n\n')
Write('\n\n End time:' + end.strftime("%Y-%m-%d %H:%M") + '\n\n')
