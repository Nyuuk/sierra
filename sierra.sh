#!/bin/bash
modem='/dev/ttyUSB2'
_CONFIG='/etc/config/sierra'
R='\e[31;1m' #RED
G='\e[32;1m' #GREEN
ak='\e[0m'
Cus=$2
_ke2=$2
INTER='wwan0'

APN(){
	echo -e "AT+CGDCONT=1,\"IP\",\"$Cus\""|atinout - $modem -
}

STATUS(){
	echo -e 'AT&V'|atinout - $modem -
	}

START(){
for (( ; ; )); do
AT=$(echo -e 'AT!SCACT=1,1'|atinout - $modem -|awk NR==2)
IP=$(ifconfig $INTER|grep inet)
if [[ "$AT" = "OK"* ]]; then
	echo -e "Modem$G Sudah$ak Start"
	for (( ; ; )); do
	Ip=$(ifconfig wwan0|grep 'inet addr'|awk -F 'addr:' '{print $2}'|awk '{print $1}')
	if [ -n "$Ip" ]; then
		echo -e "Current IP $G$Ip$ak"
		break
	fi
	done
	break
else
	echo -e "Modem$R Gagal$ak Start"
fi
sleep 2
done
}

CONNECTION(){
	for (( ; ; )); do
	if [[ -n "$(lsusb | grep sierra)" || -n "$(lsusb | grep Airprime)" ]];then 
	if [ -z "$(ifconfig $INTER|grep inet)" ]; then \
		echo -e "Sierra ${R}Not${ak} Connected"
		echo -e "AT!SCACT=1,1"|atinout - $modem - &>/dev/null
	else
		echo -e "Sierra ${G}Connected${ak}"
		echo -e "IP Local : ${G}$(ifconfig $INTER|grep inet|awk NR==1 \
		|awk '{print $2}'|awk -F ':' '{print $2}')$AK"
		break
	fi
	else
		echo -e "${R}Sierra tidak terdeteksi$ak"
	fi
	sleep 1
	done
	}
	
AUTO(){
	for (( ; ; )); do
	ceksi=$(lsusb|grep Sierra)
	if [ -n "$ceksi" ]; then
	echo -e "Sierra$G Terdeteksi$ak"
		cekip=$(ifconfig wwan0|grep 'inet addr')
		if [ -z "$cekip" ]; then
			START
		fi
	else
		echo -e "Sierra$R Tidak Terdeteksi$ak"
	fi
	Ip=$(ip route|grep wwan0|awk NR==1|awk '{print $3}')
	echo -e "IP $Ip"
	sleep 2
	done
}

STOP(){
AT=$(echo -e 'AT!SCACT=0,1'|atinout - $modem -|awk NR==2)
if [[ "$AT" = "OK"* ]]; then
	echo -e "Modem$G Disconnect$ak"
else
	echo -e "Modem$R Gagal$ak Disconnect"
fi
}

RESET(){
for (( ; ; )); do
AT=$(echo -e 'AT!RESET'|atinout - $modem -|awk NR==4)
if [[ "$AT" = "OK"* ]]; then
	echo -e "Modem$G Restart$ak"
	break
else
	echo -e "Modem$R Gagal$ak Restart"
fi
sleep 2
done
}

CUSTOM(){
echo -e $Cus
echo -e $Cus|atinout - $modem -
}

En(){
	if [ -z "$(grep sierra /etc/rc.local)" ]; then
		sed -i "s/$(grep exit /etc/rc.local)/screen -dmS sierra \/root\/sierra auto\nexit 0/g" /etc/rc.local
		echo -e "AutoStart Is enable"
	else
		echo -e "AutoStart Is enable"
	fi
}

Dis(){
	if [ -z "$(grep sierra /etc/rc.local)" ]; then
		echo -e "AutoStart Is disable"
	else
		sed -i "/screen -dmS sierra \/root\/sierra auto/d" /etc/rc.local
		echo -e "Succes disable Autostart"
	fi
}

ENABLED(){
	if [ -z "$(grep sierra /etc/rc.local)" ]; then
		echo -e "AutoStart Is disable"
	else
		echo -e "AutoStart Is enable"
	fi
}

Note(){
	clear
	TOTAL=$(grep -n '' /root/ip.txt|awk -F ':' '{print $1}')
	echo -e "Current IP : $(ifconfig wwan0|grep 'inet addr'|\
			awk -F 'addr:' '{print $2}'|awk '{print $1}')"
	echo -e "=========================="
	echo -e "	  List Note"
	for cek in $(echo $TOTAL)
	do
		if [[ "$(cat /root/ip.txt|awk NR==$cek)" == "•"* ]]
		then
			echo -e "$cek. $(cat /root/ip.txt|awk NR==$cek)"
		else
			echo -e "	|-- > $(cat /root/ip.txt|awk NR==$cek)"
		fi
	done
	echo -e "=========================="
	echo -e "     CTRL + C : exit"
	echo -e "=========================="
}

CATAT(){
	Note
	for (( ; ; )); do
		read -p "Add List note (Y/n) : " ADD
		if [[ "$ADD" == "Y" || "$ADD" == "y" ]]; then
			echo -e 'Add list note'
			read -p "Name for Note : " Nam
			echo -e "• $Nam">>/root/ip.txt
			echo -e "Succes Add Note"
			break
		elif [[ "$ADD" == "N" || "$ADD" == "n" ]]; then
			break
		else
			echo -en "(Y/n)"
			sleep 1
		fi
	done
	for (( ; ; )); do
		Note
		read -p	 "Number Note : " Num
		Cek=$(cat /root/ip.txt|awk NR==$Num|grep •)
		if [ -n "$Cek" ]
		then
			Ip=$(ifconfig wwan0|grep 'inet addr'|\
			awk -F 'addr:' '{print $2}'|awk '{print $1}')
			sed -i "s/$Cek/$Cek\n$Ip/g" /root/ip.txt
			echo -e "Succes Add Note"
			break
		else
			echo -e "Please equalizing list number"
			sleep 1
		fi
	done
}

stat_apn(){
        /root/sierra cus 'AT+CGDCONT?'
}

LTE(){
	RESET; \
	sleep 35; \
	CONNECTION
	}

_ROUT(){
  clear
  if [ -z "$(ls $_CONFIG)" ]; then
    touch $_CONFIG
  fi
  if [ -z "$(grep route $_CONFIG)" ]; then
    echo -e "route=no">>$_CONFIG
   fi
  _TOTAL=$(grep server $_CONFIG|awk -F '=' 'print $1')
  _TOTALNum=$(grep -n 'server' $_CONFIG|awk -F ':' '{print $1}')
  case $ke2 in
    menu)
      echo -e "1. Set routing (true/false)"
      echo -e "2. Set Ip Server routing"
      read -p "Input number : " _pilNum
      case $_pilNum in
      1)
        read -p "Routing server VPN ? (default true/yes) [yes/NO]" _pil
        for (( ; ; )); do
        if [[ "$_pil" == "YES" || "$_pil" == "yes" ]]; then
            sed -si "s/route=no/route=yes/g" $_CONFIG;break
        elif [[ "$_pil" == "NO" || "$_pil" == "no" ]]; then
            sed -si "s/route=yes/route=no/g" $_CONFIG;break
        elif [ -z "$_pil" ]; then
            sed -si "s/route=no/route=yes/g" $_CONFIG; break
        else
            echo -e "Mohon masukan dengan benar"
        fi
        sleep 1; clear
        done
        /root/sierra rout menu
      ;;
      2)
        if [ -z "$(grep server $_CONFIG)" ]; then
          read -p "Input Ip server : " _ipServer
          echo -e "server1=$_ipServer">>$_CONFIG; exit
         fi
        for _LOOP in $_TOTALNum; do 
          echo -e "$_LOOP. server$_LOOP > $(grep server$_LOOP $_CONFIG|awk -F '=' '{print $2}')"
          done
        read -p "Add new server VPN ? (yes/No) " _pil
        if [[ "$_pil" == "yes" || "$_pil" == "YES" ]]; then
        clear;read -p "Ip Server : " _ipServer
        let _str=1+$(cut -b 7- $_CONFIG|cut -d "=" -f 1 -)
        echo -e "server$_str=$_ipServer">>$_CONFIG
        echo -e "Added server$_str $_ipServer";exit
        else
        echo "exited";exit
        fi
      ;;
      esac
    ;;
  esac
  _CEK=$(grep route $_CONFIG|awk -F '=' '{print $2}')
  case $_CEK in
    yes|YES)
      if [ -z "$(grep server $_CONFIG)" ];then
        clear
        echo -e "Please add Ip Server for Routing"
        echo -e "$0 rout menu"
        sed -si "s/route=yes/route=no/g" $_CONFIG; exit
       fi
      Ip=$(ifconfig wwan0|grep 'inet addr'|awk -F 'addr:' '{print $2}'|awk '{print $1}')
      for _LOOP in $_TOTAL; do
        _ipServer=$(grep $_LOOP $_CONFIG|awk -F '=' 'print $2')
        echo -en "Add route $_LOOP $_ipServer "
        _cek=$(ip route|grep "$_ipServer via $Ip")
        for i in 1 2; do
          if [ -z "$(ip route|grep $_ipServer)" ]; then
          ip route add $_ipServer via $Ip $>/dev/null
          echo -e "${G}SUCCES$AK"
          elif [ -n "$_cek" ]; then
          echo -e "${G}SUCCES$AK"
          else
          echo -e "${R}FAIL$AK"
          ip route |grep $_ipServer
          fi
        done
      done
    ;;
   esac
}
case $1 in
rout)
  _ROUT;exit
  ;;
lte)
	LTE;exit
	;;
        stat-apn)
                stat_apn;exit
                ;;
	catat)
		CATAT;exit
		;;
	apn)
		APN;exit
		;;
	enable)
		En;exit
		;;
	disable)
		Dis;exit
		;;
	enabled)
		ENABLED;exit
		;;
con)
	CONNECTION;exit
	;;
dis)
	STOP;exit
	;;
res)
	RESET;sleep 5; \
	for (( ; ; )); do \
	cek=$(ifconfig|grep wwan0|awk '{print$1}')
	if [[ "$cek" == "wwan0"* ]]; then
	CONNECTION;exit
	break
	fi
	done
	;;
reboot)
	RESET;exit
	;;
cus)
	CUSTOM;exit
	;;
stat)
	STATUS;exit
	;;
auto)
	AUTO;exit
	;;
esac

echo -e "Syntax: $0 [command]

Available commands:
        con		Start Sierra
	catat		Add or View Note list IP
        dis		Stop Sierra
        res	        Restart Sierra
	stat-apn	Status Apn
	cus		Custom AT Command
	auto		Auto detect Sierra
	apn		Change APN (sierra apn internet)
        enable          Enable Sierra autostart
        disable         Disable Sierra autostart
        enabled         Check if Sierra is started on boot"
