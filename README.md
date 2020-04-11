# Lab104
### Automatic data collection for championships and other events that are held according to the methodology of WorldSkills assignments. Linux and Windows scripts can be run from anywhere, the main thing is to have access to ESXi. Cisco has 2 versions of the script, 1 is launched from the topology from PC1, 2 is connected to the console server
## Getting Started
1. Clone repo `git clone https://github.com/auteam1/wsr`

2. Go to event folder `cd Demo2020`

3. Select Code folder `cd Code1.1`

4. Select Linux / Windows / Cisco folder `cd Linux`

5. And run Linux / Windows / Cisco script `DEMO2020COD1.1Linux.ps1`

> If you have any trouble with dependencies, please pay attention to the Dependencies(0) section in script.

## Non-interactive start for Linux and Windows scripts
All variables that are entered during the start of the script can be entered as parameters before starting

```bash
DEMO2020COD1.1Linux.ps1 1 2 3
```
* **1** - _integer_ Stand Number **Example** `1`
* **2** - _string_ Competitor name **Example** `IvanIvanov`
* **3** - _string_ Address Server IP **Example** `192.168.1.1`

```bash
DEMO2020COD1.1Linux.ps1 1 IvanIvanov 192.168.1.1
```

There are also variables that have a default value, they are provided below (if you need, you can change them in script before starting)

* **LOGIN_ESXi** - _string_ Username for login ESXi **Default** `root`
* **PASS_ESXi** - _string_ Password for login ESXi **Default** `P@ssw0rd`
* **LOGIN_VM** - _string_ Password for login to Virtual Machine **Default for Linux** `root` , **Default for Windows** `Administrator`
* **PASS_VM** - _string_ Password for login to Virtual Machine **Default for Linux** `toor` , **Default for Windows** `P@ssw0rd`
* **DELAY** - _integer_ Delay before power on VM, you can set this value to 0 for easy debugging **Default** `30`
> The domain name for the Administrator is set correctly and depends on the event

## Non-interactive start for Cisco scripts
### First version has name *Cisco(1).py and work from PC1 in topology, and connection occurs by SSH, on port by default 

```bash
DEMO2020COD1.1Cisco(1).py 1 2
```
* **1** - _integer_ Stand Number **Example** `1`
* **2** - _string_ Competitor name **Example** `IvanIvanov`

```bash
DEMO2020COD1.1Cisco(1).py 1 IvanIvanov
```

There are also variables that have a default value, they are provided below (if you need, you can change them in script before starting)

* **USER** - _string_ Username for login on network device 
* **PASSWORD** - _string_ Password for login on network device
* **ENABLE_PASS** - _string_ Exec password on network device
* **SSH_PORT** - _integer_ Port for create SSH conection **Default** `22`
> The USER, PASSWORD, ENABLE_PASS is set correctly and depends on the event

### Second version has name *Cisco(2).py and works from anywhere, the main thing is to have access to the console server
