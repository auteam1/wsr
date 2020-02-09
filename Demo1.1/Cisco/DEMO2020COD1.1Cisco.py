import time
import sys
from netmiko import ConnectHandler


# TODO: INIT

#Define Script Start Time
startTime = time.time()

# Define Usernames and passwords
USER = 'wsruser'
PASSWORD = 'network'
ENABLE_PASS = 'pass'
STAND_NUMBER = '1'
DEVICES_NAME = [ 'HQ1', 'SW1', 'SW2' ] #, 'SW3', 'ASA' ]
IP  =   {   'HQ1'   :   '1.1.1.1'       ,
            'SW1'   :   '172.16.1.1'    ,
            'SW2'   :   '172.16.1.2'
            # .......
            }
con = {}

# Create conn dictionary
for host in DEVICES_NAME:
    DEVICES_PARAMS = {  'device_type'   :   'cisco_ios' ,
                        'ip'            :   IP[host]    ,
                        'username'      :   USER        ,
                        'password'      :   PASSWORD    ,
                        'secret'        :   ENABLE_PASS ,
                        'port'          :   22
                        }
    try:
        con[host] = ConnectHandler(**DEVICES_PARAMS)
        con[host].enable()
    except:
        print('Not connected to ' + host)
openedFile = open( STAND_NUMBER + "_RESULT" + ".txt", "w") # Create result file



# TODO: Main Functions

# Use: SendCommand('HQ1','sh ip int b')
#
# OR
#
# hosts = ['HQ1', 'BR1']
# commands = ['sh run int tun1 | i mode', 'sh crypto isakmp sa']
# Use: SendCommand(hosts, commands)
#
# If not connected, return 0
def SendCommand(host_arr, command_arr):
	global openedFile
	global con
    for host in host_arr:
        for command in command_arr:
            try:
        		openedFile.write(con[host].send_command(command)+"\n")
        	except:
        		openedFile.write("Not connected to " + host + "\n")
                return 0

# Time to connect on all devices
print(int(time.time()-startTime))



# TODO: Start of check

#############################--=START=--####################################
openedFile.write("Stand number:" + STAND_NUMBER + "\n")

# TODO: C1.1
openedFile.write("===================================C1.1===================================\n")
openedFile.write("Description: Hostname\n")
openedFile.write("Checking on: HQ1, SW1\n")

hosts = ['HQ1', 'SW1']
commands = ['sh run | s hostname']
SendCommand(hosts, commands)

# TODO: C1.2
