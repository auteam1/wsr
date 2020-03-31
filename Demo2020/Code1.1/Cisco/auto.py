import time
import sys
from netmiko import ConnectHandler


# TODO: INIT
#Define Script Start Time
startTime = time.time()

# Define Usernames and passwords
USER = input('Username: ')
PASSWORD = input('Password: ')
ENABLE_PASS = input('Enable password: ')
STAND_NUMBER = input('Enter STAND_NUMBER: ')

# Define Host information and IP address

DEVICES_NAME = [ 'HQ1', 'SW1', 'SW2' ] #, 'SW3', 'ASA' ]

IP  =   {   'HQ1'   :   '1.1.1.1'       ,
            'SW1'   :   '172.16.1.1'    ,
            'SW2'   :   '172.16.1.2'
            # .......
            }
con = {}

# BASE

openedFile = open( STAND_NUMBER + "_RESULT" + ".txt", "w") # Create result file

# TODO: Main Function
# Use: Write_In_File('HQ1','sh ip int b')
def Write_In_File(host, command):
	global openedFile
	global con
	try:
		openedFile.write(con[host].send_command(command)+"\n")
	except:
		openedFile.write("Not connected to " + host + "\n")

# Create conn dictionary

for host in DEVICES_NAME:
    enable = ENABLE_PASS
    if host == 'ASA':
        enable = PASSWORD
    DEVICES_PARAMS = {  'device_type'   :   'cisco_ios' ,
                        'ip'            :   IP[host]    ,
                        'username'      :   USER        ,
                        'password'      :   PASSWORD    ,
                        'secret'        :   enable      ,
                        'port'          :   22
                        }
    try:
        conn[host] = ConnectHandler(**DEVICES_PARAMS)
        conn[host].enable()
    except:
        print('Not connected to ' + host)
# Time to connect on all devices
print(int(time.time()-startTime))



# TODO: Start of check
#############################--=START=--####################################
openedFile.write("Stand number:" + STAND_NUMBER + "\n")

# TODO: C1.1
openedFile.write("===================================C1.1===================================\n")
openedFile.write("Description: Hostname\n")
openedFile.write("Checking on: HQ1, SW2\n")
Write_In_File('HQ1', "sh run | s hostname")
Write_In_File('SW1', "sh run | s hostname")

# TODO: C1.2
openedFile.write("===================================C1.1===================================\n")
openedFile.write("Description: Hostname\n")
openedFile.write("Checking on: HQ1, SW2\n")
Write_In_File('HQ1', "sh run | s hostname")
Write_In_File('SW1', "sh run | s hostname")
