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

# Install Python 3.x
import time
import sys
from netmiko import ConnectHandler
# How to install netmiko:
# https://www.jaacostan.com/2018/09/how-to-install-netmiko-on-windows.html

# TODO: 1. Init

USER                = 'wsruser'     # Username
PASSWORD            = 'network'     # Password
ENABLE_PASS         = 'pass'        # Enable password
SSH_PORT            = 22            # Port for SSH connection
DEVICES_NAME        = [ 'HQ1', 'SW1', 'SW2' ] #, 'SW3', 'ASA' ]
IP                  = { 'HQ1'   :   '1.1.1.1'       ,
                        'SW1'   :   '172.16.1.1'    ,
                        'SW2'   :   '172.16.1.2'
                        # .......
                        }

# TODO: 2. Main functions

# Just write in result file
#
# Use: Write('Sobaka')
def Write(string):
    print(string)
    openedFile.write(string)

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
def SendCommand(host_arr, command_arr):
# Check that all hosts available
    for host in host_arr:
        if host in DEAD_DEVICES:
            Write('Not connected to '  + host + '\n')
            return 0
    global con
    for host in host_arr:
        for command in command_arr:
            Write(con[host].send_command(command) + '\n')

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


# Create result file
openedFile = open( STAND_NUMBER + "_RESULT" + ".txt", "w")
startTime = time.time() # Define Script Start Time
con = {}

# Empty list with dead devices
DEAD_DEVICES = list()

# Create conn dictionary
for host in DEVICES_NAME:
    DEVICES_PARAMS = {  'device_type'   :   'cisco_ios' ,
                        'ip'            :   IP[host]    ,
                        'username'      :   USER        ,
                        'password'      :   PASSWORD    ,
                        'secret'        :   ENABLE_PASS ,
                        'port'          :   SSH_PORT
                        }
    try:
        con[host] = ConnectHandler(**DEVICES_PARAMS)
        con[host].enable()
        Write('Successfully connected to ' + host + '\n')
    except:
        DEAD_DEVICES.append(host)
        Write('Not connected to ' + host + '\n')
# Time to connect on all devices
print(int(time.time() - startTime))

#############################--=START=--####################################

Write('Stand number: ' + STAND_NUMBER + '\n')

# TODO: C1.1
Write('===================================C1.1===================================\n')
Write('Description: Hostname\n')
Write('Checking on: HQ1, SW1\n')

hosts = ['HQ1', 'SW1']
commands = ['sh run | i hostname']
SendCommand(hosts, commands)

# TODO: C1.2
