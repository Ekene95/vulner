#!/bin/bash

#This function controls every other function in this script. It is simply used to interact with the user of the script.
Control () {
	figlet -m 50 "VULNER ^-^"
	echo -e "[!!!] Please note all scans are saved to a file. \n[!!!] Check your current directory." 
	echo -e "\nWhich of the following actions would you like to carry out..."
	echo -e "\n1. Network Device detection. \n2. Enumeration of the network devices found. \n3. Vulnerability scanning of your network devices. \n4. Brute Forcing for weak passwords."
	echo " "
	read -p "Please choose a number: " OPTION
	clear
	
	case $OPTION in 
	1) 
		figlet -m 5 "Network detection selected!"
		#1. Map Network Devices and Open Ports 
		#1.1 Automatically identify the LAN network range 
		#1.2 Automatically scan the current LAN 

		Device_Scan () {
			read -p "Enter a network address range to scan: " NET_RANGE
	
			nmap_scanTypes () {
				echo "These are the available nmap scans"
				echo -e "\n1. Fast Scan \n2. Version Detection \n3. All purpose Scan \n4. Specific Port Scan \n5. Back to main menu." 
			}
			nmap_scanTypes
	
		read -p "Enter a number to perform scan: " NUM_SCAN
		case $NUM_SCAN in

		1)
			nmap -F $NET_RANGE -oX nmapFast.xml
			;;

		2)
			nmap -Pn $NET_RANGE -p- -sV -oX nmapVersion.xml
			;;

		3)
			nmap -A $NET_RANGE -p- -oX nmapALL.xml
			;;
    
		4)
			read -p "Enter desired port or ports seperated by commas, to scan: " PORT
			nmap -sV $NET_RANGE -p $PORT -oX nmapALL.xml
			;;
	
		5)
			Control
			;;
		
		*)
			echo "No Network Address entered..."
			;;
		esac
		}
		Device_Scan
		;;

####################################################################################################################################################		
	2)
		figlet -m 3 "Enumeration of the network devices selected!"
		#1.3 Enumerate each live host 

		Enumerate () {
			read -p "Enter a network address range to scan: " NET_RANGE
	
			nmap_scanTypes () {
				echo "These are the available nmap scans for enumeration."
				echo -e "\n1. Default Script Scan \n2. Vulnerability Scan \n3. Specific port enumeration, using nse scripts \n4. Back to main menu" 
			}
			nmap_scanTypes
	
		read -p "Enter a number to perform scan: " NUM_SCAN
		case $NUM_SCAN in

		1)
			nmap -sV $NET_RANGE -p- --script=default -oX nmapScripScan.xml
			;;

		2)
			nmap -sV $NET_RANGE -p- --script=vuln -oX nmapVulnScan.xml
			;;

		3)
			read -p "Enter desired port to enumerate: " PORT
			read -p "Enter the corresponding service name: " SERVICE
			echo " "
			echo -e "Choose a service nse enum script: \n$(locate *.nse | grep -i $SERVICE)"
			echo " "
			read CHOICE
			nmap -sV $NET_RANGE -p $PORT --script=$CHOICE -oX nmapPortEnum.xml
			;;
	
		4)
			Control
			;;
		
		*)
			echo "No Number entered. Exit!"
			;;
		esac
		}
		Enumerate
		;;

####################################################################################################################################################	
	3)##1.4 Find potential vulnerabilities for each device 
		figlet -m 3 "Vulnerability scanning of your network devices, selected!"
		vuln_finder () {
			read -p "Enter a network address range to scan: " NET_RANGE
			echo "[+] Scanning for vulnerabilities on each live host..."
			nmap -sV -F $NET_RANGE -oX vuln_found.xml 2>/dev/null
			searchsploit --nmap vuln_found.xml 2>/dev/null > vuln.txt #3.2 Save all the results into a report 
			clear
			echo "[+] Scan completed, refer to the file vuln.txt, for potential vulnerabilities in your system."
			echo "Thank you , exiting...."
			sleep 2
			exit
		}
		vuln_finder
		;;

####################################################################################################################################################		
	4)
		figlet -m 3 "Brute Forcing for weak passwords, selected!"
		#2. Check for Weak Passwords Usage
		#2.1 Allow the user to specify a user list 
		#2.2 Allow the user to specify a password list 
		#2.3 Allow the user to create a password list 
		#2.4 If a login service is available, Brute Force with the password list 
		#2.5 If more than one login service is available, choose the first service 

		Password_checker () {
		#3.3 Allow the user to enter an IP address; display the relevant findings
			read -p "Enter the first three octets of a network address to scan e.g. x.x.x: " NETWORK_ADDR
			echo -e "[+] Finding live IP addresses on your network..."
			for i in `seq 1 255`
			do
				ping -c 1 $NETWORK_ADDR.$i | grep ttl | awk '{print $4}' | cut -d: -f1 &
			done > LiveDevices.txt
			sleep 2
			clear
			echo -e "[+] Found devices at $(date) \n$(cat LiveDevices.txt) " #3.1 Display general statistics (time of the scan, number of found devices, etc.) 
			sleep 1
			echo "[*] nmap scanning in progress, please wait...."
			for i in $(cat LiveDevices.txt)
			do
				nmap -F $i 
			done
			sleep 1
			echo "Create a password list for brute forcing."
			read -p "[*] Specify a user list for brute forcing: " USER_LST
			read -p "[*] Specify a password list for brute forcing: " PASS_LST
			read -p "[*] Enter an IP Address from the nmap scan result for brute forcing: " IP
			read -p "[*] Enter a log in service to brute force " SERVICE
			clear
			echo "[++] Brute force starting.... "
			hydra -L $USER_LST -P $PASS_LST $IP $SERVICE -vV
			echo "Thank you , exiting...."
			sleep 2
			exit
		}
		Password_checker
		;;
	
	*) 
		echo "No option selected!"
		exit
		;;
	esac
}
Control
