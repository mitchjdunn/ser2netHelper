#!/bin/bash
#
#TODO
#read device name as argument
#determine which /dev/ttyUSB# to connect to
#S1 is alwasy on hubport 7-7
#R1 is always on hubport 7-6
#S2 is alwasy on hubport 7-5
#R2 is alwasy on hubport 4
#S3 is alwasy on hubport 3
#R3 is alwasy on hubport 2
#S4 is alwasy on hubport 1
#R4 is awlays on hubport 5
#S5 is always on hubport 6
#connect to that device.
#
port=0
network="10.123.18."
ip=201
printf "%s\t %s\n" "IP Address" "hostname" > hostnames
cp base.conf ser2net.conf #base.conf should exist in the directory
echo -e "auto eth0\niface eth0 inet static\naddress ${network}200\n" >> interfaces #Raspberry Pi ip
for pod in "P1" "P2" "P3" "P4" "P5"; do
	case $pod in
		P1)
			port=$((port + 9)) #+9 because there are nine devices that are not being configured yet
			ip=$((ip +9))
			continue
			;;
		P2)
			port=$((port + 9))
			ip=$((ip +9))
			continue
			;;
		P3)
			port=$((port + 9))
			ip=$((ip +9))
			continue
			;;
		P4)
			port=$((port + 9))
			ip=$((ip +9))
			continue
			;;
		P5)
			bus="1" #These are specific to where the pods USB hub is plugged into the raspbery pi.
				# determined with lsusb -t
				# this must be done for P1-P4
			usbport="1.5"
			;;
	esac
	for dev in "S1" "R1" "S2" "R2" "S3" "R3" "S4" "R4" "S5"; do
		case $dev in #If the same USB hub is used with the same configuration this should remain the same
				# otherwise use lsusb to determin the port on the hub
			S1)
				hubport="7.7"
				;;

			R1)
				hubport="7.6"
				;;

			S2)
				hubport="7.5"
				;;
			R2)
				hubport="4"
				;;
			S3)
				hubport="3"
				;;
			R3)
				hubport="2"
				;;
			S4)
				hubport="1"
				;;
			R4)
				hubport="5"
				;;
			S5)
				hubport="6"
				;;
			*)
		esac	
		device=$(find /sys/devices -name tty | grep -F $bus-$usbport.$hubport | grep -o ttyUSB.) # this is used to find the /dev/ttyUSB# for ser2net

		echo BANNER:$pod$dev:Connected to $pod$dev >> ser2net.conf
		echo 10.123.18.$ip,5555:telnet:0:/dev/$device:9600 8DATABITS NONE $pod$dev remctl >> ser2net.conf
		printf "%s\t %s\n" "10.123.18.$ip" "$pod$dev" >> hostnames
		ifconfig eth0:$port ${network}$ip #sets interface ip
		echo -e "auto eth0:$port\niface eth0:$port inet static\naddress ${network}$ip\n" >> interfaces #virtual interface
		port=$((port + 1))
		ip=$((ip +1))
	done
done
