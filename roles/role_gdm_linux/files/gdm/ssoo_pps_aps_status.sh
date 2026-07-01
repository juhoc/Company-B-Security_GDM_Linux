#!/bin/bash

#--- Inicio validacion Salud OS
# Variables de Ambiente OS
TIME=$(date +'%a-%b-%e %H:%M')
IPS=$(ip -o -4 addr | tr " " "," | sed 's/,,,,/,/g;s/inet,//g;s/:,/:/g' | cut -d: -f2 | cut -d'/' -f1)
OSPF=$(cat /etc/*release | grep ^ID= | cut -d= -f2 | tr -d "\"")
UPSN=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -s; fi)
UPPF=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -p; fi)
CPUMEM=$(top -b -n 1 | head -5)
VALFW=$(firewall-cmd 2>/dev/null --state || echo "not running")
IPTBL=$(iptables -n -L -v)
FSNM=$(df -hT | grep -Ev "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -hT | grep -Ev "Filesystem|#|tmpfs|boot" | wc -l)
OSRL=$(cat /etc/*release | grep -Ew "^ID=|^VERSION_ID|^PRETTY_NAME" | sort)

# Crear directorio e inicializar archivos de estado
mkdir -p /var/opt/ansible
for i in foto_salud_servidor_previa.txt foto_pps_previa.txt patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
do
	touch /var/opt/ansible/$i
done

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
PAAG=$(pgrep -ic "^patrolagent$")
#---Capacity
CAITL=$(find /performance -maxdepth 4 -name bgsagent -print -quit 2>/dev/null)
CAAG=$(pgrep -ic -f "bgssd|bgsagent|bgscollect")
#---ControlM
CTMITL=$(find /controlm -maxdepth 4 -name start-ag -print -quit 2>/dev/null)
CTMAG=$(pgrep -ic -f "^ctma")
#---Dimensions
DMITL=$(find /opt/dimensions -maxdepth 5 -name dmstartup -print -quit 2>/dev/null)
DMAG=$(pgrep -ic "^dimensions$")
#---SentinelOne
S1ITL=$(find /opt/sentinelone -maxdepth 4 -name sentinelctl -print -quit 2>/dev/null)
S1AG=$(pgrep -ic -f "^s1-")
#---ConnectDirect
CDITL=$(find /NDM36 -maxdepth 4 -name startcd.sh -print -quit 2>/dev/null)
CDAG=$(pgrep -ic -f "^cdpmgr|^cdstatm")

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_previa.txt
echo "Informacion Programas Producto" >> /var/opt/ansible/foto_pps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_previa.txt

if [ -f "$PAITL" ] && [ "$PAAG" -ge 1 ]; then
	echo "PatrolAgent ------ ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "PatrolAgent ------ ACTIVO" > /var/opt/ansible/patrol.asb
elif [ -f "$PAITL" ] && [ "$PAAG" -eq 0 ]; then
	echo "PatrolAgent ------ INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "PatrolAgent ------ INACTIVO" > /var/opt/ansible/patrol.asb
else
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" > /var/opt/ansible/patrol.asb
fi

if [ -f "$CAITL" ] && [ "$CAAG" -ge 1 ]; then
	echo "CapacityAgent ---- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "CapacityAgent ---- ACTIVO" > /var/opt/ansible/capacity.asb
elif [ -f "$CAITL" ] && [ "$CAAG" -eq 0 ]; then
	echo "CapacityAgent ---- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "CapacityAgent ---- INACTIVO" > /var/opt/ansible/capacity.asb
else
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/capacity.asb
fi

if [ -f "$CTMITL" ] && [ "$CTMAG" -ge 1 ]; then
	echo "Control-MAgent --- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Control-MAgent --- ACTIVO" > /var/opt/ansible/ctm.asb
elif [ -f "$CTMITL" ] && [ "$CTMAG" -eq 0 ]; then
	echo "Control-MAgent --- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Control-MAgent --- INACTIVO" > /var/opt/ansible/ctm.asb
else
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" > /var/opt/ansible/ctm.asb
fi

if [ -f "$DMITL" ] && [ "$DMAG" -ge 1 ]; then
	echo "Dimensions ------- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Dimensions ------- ACTIVO" > /var/opt/ansible/dim.asb
elif [ -f "$DMITL" ] && [ "$DMAG" -eq 0 ]; then
	echo "Dimensions ------- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Dimensions ------- INACTIVO" > /var/opt/ansible/dim.asb
else
	echo "Dimensions ------- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "Dimensions ------- NO SE DETECTA INSTALACION" > /var/opt/ansible/dim.asb
fi

if [ -f "$CDITL" ] && [ "$CDAG" -ge 1 ]; then
	echo "ConnectDirect ---- ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "ConnectDirect ---- ACTIVO" > /var/opt/ansible/cd.asb
elif [ -f "$CDITL" ] && [ "$CDAG" -eq 0 ]; then
	echo "ConnectDirect ---- INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "ConnectDirect ---- INACTIVO" > /var/opt/ansible/cd.asb
else
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/cd.asb
fi

if [ -f "$S1ITL" ] && [ "$S1AG" -ge 1 ]; then
	echo "SentinelOneAgent - ACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "SentinelOneAgent - ACTIVO" > /var/opt/ansible/s1.asb
elif [ -f "$S1ITL" ] && [ "$S1AG" -eq 0 ]; then
	echo "SentinelOneAgent - INACTIVO" >> /var/opt/ansible/foto_pps_previa.txt
	echo "SentinelOneAgent - INACTIVO" > /var/opt/ansible/s1.asb
else
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_previa.txt
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" > /var/opt/ansible/s1.asb
fi

echo "-------------------------------------------" > /var/opt/ansible/foto_aps_previa.txt
echo "Informacion Aplicaciones" >> /var/opt/ansible/foto_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt

# Deteccion dinamica de montajes WebSphere
FSWAS=$(df -h | awk '{print $6}' | grep -E "WebSphere80$|WebSphere85$|WebSphere90$" | sort)
counter=1
for fs in $FSWAS; do
  declare "WASITL$counter=$fs"
  counter=$((counter + 1))
done

if [ -n "$WASITL1" ]; then
  WSV1=$(find "$WASITL1/AppServer/profiles" -maxdepth 3 -type d -name bin 2>/dev/null)
  WSA1=$(find "$WASITL1/AppServer/profiles" -maxdepth 4 -path "*AppSrv01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
  WSD1=$(find "$WASITL1/AppServer/profiles" -maxdepth 4 -path "*Dmgr01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
  WSI1=$(ps -eo args | grep "$WASITL1" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -Ev "dmgr|nodeagent" | wc -l)
  WSP1=$(ps -eo args | grep "$WASITL1" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -E "dmgr|nodeagent" | wc -l)
  if [ "$WSA1" -ge 1 ] && [ "$WSD1" -ge 1 ] && [ "$WSI1" -ge 1 ] && [ "$WSP1" -ge 1 ]; then
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Lista de instancias $WASITL1" >> /var/opt/ansible/foto_aps_previa.txt
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep "$WASITL1"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -Ev "dmgr|nodeagent")
  	do
  		ps -eo args | grep -qi "$i" && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done

	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Procesos dmge y nodeagent $WASITL1" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep "$WASITL1"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -E "dmgr|nodeagent")
  	do
  		ps -eo args | grep -qi "$i" && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done
  else
    echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "WebSphere Application ----- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  fi
fi

if [ -n "$WASITL2" ]; then
   WSV2=$(find "$WASITL2/AppServer/profiles" -maxdepth 3 -type d -name bin 2>/dev/null)
   WSA2=$(find "$WASITL2/AppServer/profiles" -maxdepth 4 -path "*AppSrv01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
   WSD2=$(find "$WASITL2/AppServer/profiles" -maxdepth 4 -path "*Dmgr01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
   WSB2=$(ps -eo args | grep "$WASITL2"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -Ev "dmgr|nodeagent" | wc -l)
   WSP2=$(ps -eo args | grep "$WASITL2"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -E "dmgr|nodeagent" | wc -l)
   if [ "$WSA2" -ge 1 ] && [ "$WSD2" -ge 1 ] && [ "$WSB2" -ge 1 ] && [ "$WSP2" -ge 1 ]; then
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Lista de instancias $WASITL2" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep "$WASITL2"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -Ev "dmgr|nodeagent")
  	do
  		ps -eo args | grep -qi "$i" && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done

	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Procesos dmge y nodeagent $WASITL2" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	for i in $(ps -eo args | grep "$WASITL2"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -E "dmgr|nodeagent")
  	do
  		ps -eo args | grep -qi "$i" && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done
   else
     echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "WebSphere Application ----- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
   fi
fi

if [ -n "$WASITL3" ]; then
   WAV3=$(find "$WASITL3/AppServer/profiles" -maxdepth 3 -type d -name bin 2>/dev/null)
   WSA3=$(find "$WASITL3/AppServer/profiles" -maxdepth 4 -path "*AppSrv01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
   WSD3=$(find "$WASITL3/AppServer/profiles" -maxdepth 4 -path "*Dmgr01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
   WAB3=$(ps -eo args | grep "$WASITL3"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -Ev "dmgr|nodeagent" | wc -l)
   WAP3=$(ps -eo args | grep "$WASITL3"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -E "dmgr|nodeagent" | wc -l)
   if [ "$WSA3" -ge 1 ] && [ "$WSD3" -ge 1 ] && [ "$WAB3" -ge 1 ] && [ "$WAP3" -ge 1 ]; then
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Lista de instancias $WASITL3" >> /var/opt/ansible/foto_aps_previa.txt
	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
	echo " "
  	for i in $(ps -eo args | grep "$WASITL3"  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -Ev "dmgr|nodeagent")
  	do
  		ps -eo args | grep -qi "$i" && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
  	done

	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "Procesos dmge y nodeagent $WASITL3" >> /var/opt/ansible/foto_aps_previa.txt
  	echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt
  	echo " "
  	for i in $(ps -eo args | grep "$WASITL3" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | grep -E "dmgr|nodeagent")
  	do
  		ps -eo args | grep -qi "$i" && echo "$i ----- ACTIVA" || echo "$i ----- INACTIVO" >> /var/opt/ansible/foto_aps_previa.txt
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