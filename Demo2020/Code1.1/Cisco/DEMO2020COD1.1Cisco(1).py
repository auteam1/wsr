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
            Write('ScriptOutput : ' + con[host].send_command(command) + '\n\n\n')

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
startTime   = time.time() 
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
# Time to connect on all devices
print(int(time.time() - startTime))

#############################--=START=--####################################

now = datetime.datetime.now()
Write('\n\n' + now.strftime("%Y-%m-%d %H:%M") + '\n\n')
Write(COMPETITOR)

# TODO: C1.1 Hostname

hosts       = ['HQ1', 'SW1']
commands    = ['sh run | i hostname']
description = 'Hostname'
SendCommand(hosts, commands, description)

# TODO: C1.2 Domain name

hosts       = ['SW2', 'SW3']
commands    = ['sh run | i domain name']
description = 'Hostname'
SendCommand(hosts, commands, description)
