#!/bin/bash

#--- Inicio validacion Salud OS
# Variables de Ambiente OS
TIME=$(date +'%a-%b-%e %H:%M')
IPS=$(ip -o -4 addr | tr " " "," | sed 's/,,,,/,/g;s/inet,//g;s/:,/:/g' | cut -d: -f2 | cut -d'/' -f1)
OSPF=$(cat /etc/*release | grep ^ID= | cut -d= -f2 | tr -d "\"")
UPSN=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -s; fi)
UPPF=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -p; fi)
CPUMEM=$(top | head -5)
STSFW=$(firewall-cmd 2>/dev/null --state)
VALFW=$(if [ "$STSFW" = "running" ]; then echo "$STSFW"; else echo "not running"; fi)
IPTBL=$(iptables -n -L -v)
FSNM=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | wc -l)
OSRL=$(cat /etc/*release | egrep -w "^ID=|^VERSION_ID|^PRETTY_NAME" | sort)

#for i in foto_salud_servidor_previa.txt foto_pps_previa.txt patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
#do
#	touch /var/opt/ansible/$i
#done

echo "-------------------------------------------" > /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Informacion de salud del SSOO" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Fecha: $TIME" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Hostname: $(hostname)" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Direcciones IPs:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$IPS" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
if [ "$OSPF" = "rhel" ]
then
	echo "Ultimo arranque de Sistema Operativo:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo "$UPSN" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo "$UPPF" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
else
	echo "Ultimo arranque de Sistema Operativo:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo "$UPSN" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
fi
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Uso de CPU y Memoria:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$CPUMEM" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Estado del firewall:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$VALFW" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$IPTBL" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Estado del FileSystems:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "VGS,LV,Tipo,Tamaño,T.Utilizado,T.Disponible,% de Uso,Montura" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$FSNM" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Numero de Filesystems: $FSC" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Versión de sistema operativo:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$OSRL" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt



#--- Inicio validacion PPS
# Variables de Ambiente PPS
#---Patrol
PAITL=/patrol/Patrol3/scripts.d/S50PatrolAgent.sh
PAAG=$(ps -eo comm | grep -wi patrolagent | grep -v grep | wc -l)
#---Capacity
CAITL="$(ls 2>/dev/null -1R /performance | grep bgs/bin:$ | tr -d ':')/bgsagent"
CAAG=$(ps -eo comm | egrep -wi "bgssd|bgsagent|bgscollect" | grep -v grep | wc -l)
#---ControlM
CTMITL="$(ls 2>/dev/null -1R /controlm | grep ctm/scripts:$ | tr -d ':')/start-ag"
CTMAG=$(ps -eo comm | grep -wi ctma[a-z] | awk -F ' ' '{print $1}' | wc -l)
#---Dimensions
DMITL="$(ls 2>/dev/null -1R /opt/dimensions | grep cm/prog:$ | tr -d ':')/dmstartup"
DMAG=$(ps -eo comm | grep -wi dimensions | grep -v grep | wc -l)
#---SentinelOne
S1ITL="$(ls 2>/dev/null -1R /opt/sentinelone | grep bin:$ | tr -d ':')/sentinelctl"
S1AG=$(ps -eo comm | grep -wi s1-[a-z] | grep -v grep | wc -l)
#---ConnectDirect
CDITL="$(ls 2>/dev/null -1R /NDM36 2>/dev/null | grep depura:$ | tr -d ':')/startcd.sh"
CDAG=$(ps -eo comm | egrep -wi "cdpmgr|cdstatm" | grep -v grep | wc -l)
#---TetSensor
#TTITL=
#TTAG=
#---TetEnforce
#TEITL=
#TEAG=

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_previa.txt
echo "Informacion Programas Producto" >> /var/opt/ansible/foto_pps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_previa.txt
if [ -f "$PAITL" ] && [ $PAAG -eq 1 ]; then
	echo "PatrolAgent ------ ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "PatrolAgent ------ ACTIVO" > /var/opt/ansible/patrol.asb
elif [ -f "$PAITL" ] && [ $PAAG -eq 0 ]; then
	echo "PatrolAgent ------ INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "PatrolAgent ------ INACTIVO" > /var/opt/ansible/patrol.asb
else
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" > /var/opt/ansible/patrol.asb
fi
if [ -f "$CAITL" ] && [ $CAAG -eq 3 ]; then
	echo "CapacityAgent ---- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "CapacityAgent ---- ACTIVO" > /var/opt/ansible/capacity.asb
elif [ -f "$CAITL" ] && [ $CAAG -eq 0 ]; then
	echo "CapacityAgent ---- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "CapacityAgent ---- INACTIVO" > /var/opt/ansible/capacity.asb
else
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/capacity.asb
fi
if [ $(echo $CTMITL | wc -l) -eq 1 ] && [ $CTMAG -eq 3 ]; then
	echo "Control-MAgent --- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Control-MAgent --- ACTIVO" > /var/opt/ansible/ctm.asb
elif [ $(echo $CTMITL | wc -l) -eq 1 ] && [ $CTMAG -eq 0 ]; then
	echo "Control-MAgent --- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Control-MAgent --- INACTIVO" > /var/opt/ansible/ctm.asb
else
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" > /var/opt/ansible/ctm.asb
fi
if [ -f "$DMITL" ] && [ $DMAG -eq 3 ]; then
	echo "Dimensions ------- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Dimensions ------- ACTIVO" > /var/opt/ansible/dim.asb
elif [ -f "$DMITL" ] && [ $DMAG -eq 0 ]; then
	echo "Dimensions ------- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Dimensions ------- INACTIVO" > /var/opt/ansible/dim.asb
else
	echo "Dimensions ------- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Dimensions ------- NO SE DETECTA INSTALACION" > /var/opt/ansible/dim.asb
fi
if [ -f "$CDITL" ] && [ $CDAG -eq 2 ]; then
	echo "ConnectDirect ---- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "ConnectDirect ---- ACTIVO" > /var/opt/ansible/cd.asb
elif [ -f "$CDITL" ] && [ $CDAG -eq 0 ]; then
	echo "ConnectDirect ---- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "ConnectDirect ---- INACTIVO" > /var/opt/ansible/cd.asb
else
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/cd.asb
fi
if [ -f "$S1ITL" ] && [ $S1AG -eq 5 ]; then
	echo "SentinelOneAgent - ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "SentinelOneAgent - ACTIVO" > /var/opt/ansible/s1.asb
elif [ -f "$S1ITL" ] && [ $S1AG -eq 0 ]; then
	echo "SentinelOneAgent - INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "SentinelOneAgent - INACTIVO" > /var/opt/ansible/s1.asb
else
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" > /var/opt/ansible/s1.asb
fi

echo "-------------------------------------------" > /var/opt/ansible/foto_aps_previa.txt
echo "Informacion Aplicaciones" >> /var/opt/ansible/foto_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
FSWAS=$(df -h | awk '{print $6}' | egrep "WebSphere80$|WebSphere85$|WebSphere90$" | sort)
counter=1
for fs in $FSWAS; do
  eval WASITL$counter=$fs
  counter=$((counter + 1))
done

if [ -n "$WASITL1" ]; then
  WSV1=$(ls 2>/dev/null -1R $WASITL1/AppServer/profiles | grep bin:$ | tr ":" "/")
  WSA1=$(ls -1 $(ls 2>/dev/null -1R $WASITL1/AppServer/profiles | grep bin:$ | tr ":" "/" | grep AppSrv01) |egrep -i "^start|^stop" | wc -l)
  WSD1=$(ls -1 $(ls 2>/dev/null -1R $WASITL1/AppServer/profiles | grep bin:$ | tr ":" "/" | grep Dmgr01) |egrep -i "^start|^stop" | wc -l)
  WSI1=$(ps -eo args | grep $WASITL1  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent" | wc -l)
  WSP1=$(ps -eo args | grep $WASITL1  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent" | wc -l)
  if [ $WSA1 -eq 6 ] && [ $WSD1 -eq 6 ] && [ $WSI1 -ge 1 ] && [ $WSP1 -ge 1 ]; then
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Lista de instancias $WASITL1" >> /var/opt/ansible/foto_aps_previa.txt
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep $WASITL1  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent")
  	do
  		ps -eo args | grep -i $i >/dev/null && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done

	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Procesos dmge y nodeagent $WASITL1" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep $WASITL1  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent")
  	do
  		ps -eo args | grep -i $i >/dev/null && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done
  else
    echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "WebSphere Application ----- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  fi
fi

if [ -n "$WASITL2" ]; then
   WSV2=$(ls 2>/dev/null -1R $WASITL2/AppServer/profiles | grep bin:$ | tr ":" "/")
   WSA2=$(ls -1 $(ls 2>/dev/null -1R $WASITL2/AppServer/profiles | grep bin:$ | tr ":" "/" | grep AppSrv01) |egrep -i "^start|^stop" | wc -l)
   WSD2=$(ls -1 $(ls 2>/dev/null -1R $WASITL2/AppServer/profiles | grep bin:$ | tr ":" "/" | grep Dmgr01) |egrep -i "^start|^stop" | wc -l)
   WSB2=$(ps -eo args | grep $WASITL2  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent" | wc -l)
   WSP2=$(ps -eo args | grep $WASITL2  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent" | wc -l)
  if [ $WSA2 -eq 6 ] && [ $WSD2 -eq 6 ] && [ $WSB2 -ge 1 ] && [ $WSP2 -ge 1 ]; then
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Lista de instancias $WASITL2" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep $WASITL2  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent")
  	do
  		ps -eo args | grep -i $i >/dev/null && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done

	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Procesos dmge y nodeagent $WASITL2" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep $WASITL2  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent")
  	do
  		ps -eo args | grep -i $i >/dev/null && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done
  else
    echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "WebSphere Application ----- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  fi
fi

if [ -n "$WASITL3" ]; then
   WAV3=$(ls 2>/dev/null -1R $WASITL3/AppServer/profiles | grep bin:$ | tr ":" "/")
   WSA3=$(ls -1 $(ls 2>/dev/null -1R $3/AppServer/profiles | grep bin:$ | tr ":" "/" | grep AppSrv01) |egrep -i "^start|^stop" | wc -l)
   WSD3=$(ls -1 $(ls 2>/dev/null -1R $3/AppServer/profiles | grep bin:$ | tr ":" "/" | grep Dmgr01) |egrep -i "^start|^stop" | wc -l)
   WAB3=$(ps -eo args | grep $WASITL1  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent" | wc -l)
   WAP3=$(ps -eo args | grep $WASITL1  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent" | wc -l)
  if [ $WSA3 -eq 6 ] && [ $WSD3 -eq 6 ] && [ $WAB3 -ge 1 ] && [ $WAP3 -ge 1 ]; then
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Lista de instancias $WASITL3" >> /var/opt/ansible/foto_aps_previa.txt
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
	echo " "
  	for i in $(ps -eo args | grep $WASITL3  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent")
  	do
  		ps -eo args | grep -i $i >/dev/null && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done

	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Procesos dmge y nodeagent $WASITL3" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo " "
  	for i in $(ps -eo args | grep $WASITL3 | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent")
  	do
  		ps -eo args | grep -i $i >/dev/null && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done
  else
    echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "WebSphere Application ----- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  fi
fi

for i in foto_salud_servidor_previa.txt foto_pps_previa.txt patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
do
	chown bvmuxat2:automate /var/opt/ansible/$i
	chmod 644 /var/opt/ansible/$i
done