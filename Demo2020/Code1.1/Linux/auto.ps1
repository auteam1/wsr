Set-ExecutionPolicy -ExecutionPolicy UNRESTRICTED
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
# CONNECT TO ESX
$secPass = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$myCreds = New-Object System.Management.Automation.PSCredential ("root", $secPass)
# Connect-VIServer -Server 10.10.10.203 -User root -Password P@ssw0rd
Connect-VIServer -Server 10.10.10.203 -Credentials $myCreds

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

# TODO: Main Function
# Return output $Command. Example: ExecuteCommand('cat /etc/hostname', $LFW, 'root', 'P@ssw0rd')
Function ExecuteCommand([String]$Command, [String]$VM, [String]$User, [String]$Password) {
  return Invoke-VMScript -ScriptText $Command -vm $VM  -GuestUser $User -GuestPassword $Password
  # OR -Credentials $myCredentialsObject
}

#############################--=START=--####################################
$standNumb = read-host
$fileName = $standNumb + '_RESULT.txt'

# TODO: C1.1
echo "===================================C1.1===================================" | Out-File $fileName -Append -NoClobber
echo "Description: Hostname" | Out-File $fileName -Append -NoClobber
echo "Checking on: " | Out-File $fileName -Append -NoClobber
echo ExecuteCommand("echo '';cat /etc/hostname", $LFW, 'root', 'toor') | Out-File $fileName -Append -NoClobber

 #
 # Invoke-VMScript -vm $LCLIA -ScriptText "echo '';cat /etc/hostname" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 # (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-CLI-A Hostnames command cat /etc/hostname') | Out-File D:\resultlin.txt
 #
 #  Invoke-VMScript -vm $LSRV -ScriptText "echo '';cat /etc/hostname" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 # (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'L-SRV Hostnames command cat /etc/hostname') | Out-File D:\resultlin.txt
 #
 #  Invoke-VMScript -vm $RCLI -ScriptText "echo '';cat /etc/hostname" -GuestUser 'root' -GuestPassword 'toor' -ScriptType Bash | Out-File D:\resultlin.txt -Append -NoClobber
 # (Get-Content D:\resultlin.txt).replace('ScriptOutput', 'R-CLI Hostnames command cat /etc/hostname') | Out-File D:\resultlin.txt
