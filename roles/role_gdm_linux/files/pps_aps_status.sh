#!/bin/bash
#--- Inicio validacion PPS
# Variables de validadcion
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
#FileSystems
FSNM=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | wc -l)
NETSTAT=$(netstat -rn | grep -vi kernel | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g')
UP=$(uptime 2>/dev/null | cut -d' ' -f3-5 | sed 's/up/Activo:/g;s/day,/Dia/g')
TIME=$(date +'%a-%b-%e %H:%M')

echo "###########################################"
echo " "
echo "Informacion SSOO"
echo "-------------------------------------------"
echo "VGS,LV,Tipo,Tamaño,T.Utilizado,T.Disponible,% de Uso,Montura"
echo "$FSNM"
echo "-------------------------------------------"
echo "Numero de Filesystems: $FSC"
echo "-------------------------------------------"
echo "$NETSTAT"
echo "-------------------------------------------"
echo $UP
echo "-------------------------------------------"
echo "Fecha: $TIME"
echo " "
echo "###########################################"
echo " "
echo "-------------------------------------------"
echo "Reporte previo al IPL"
echo "-------------------------------------------"
echo "###########################################"
echo " "
echo "Programas Producto"
echo "-------------------------------------------"

echo "Inicia validacion PPs: $(date +'%m/%d/%Y %H:%M:%S')"
echo "-------------------------------------------"
if [ -f "$PAITL" ] && [ $PAAG -eq 1 ]; then
	echo "PatrolAgent ------ ACTIVO"
elif [ -f "$PAITL" ] && [ $PAAG -eq 0 ]; then
	echo "PatrolAgent ------ INACTIVO"
else
	echo "PatrolAgent ------ NO SE DETECTA INSTALADO"
fi
if [ -f "$CAITL" ] && [ $CAAG -eq 3 ]; then
	echo "CapacityAgent ---- ACTIVO"
elif [ -f "$CAITL" ] && [ $CAAG -eq 0 ]; then
	echo "CapacityAgent ---- INACTIVO"
else
	echo "CapacityAgent ---- NO SE DETECTA INSTALADO"
fi
if [ -f "$CTMITL" ] && [ $CTMAG -eq 3 ]; then
	echo "Control-MAgent --- ACTIVO"
elif [ -f "$CTMITL" ] && [ $CTMAG -eq 0 ]; then
	echo "Control-MAgent --- INACTIVO"
else
	echo "Control-MAgent --- NO SE DETECTA INSTALADO"
fi
if [ -f "$DMITL" ] && [ $DMAG -eq 3 ]; then
	echo "Dimensions ------- ACTIVO"
elif [ -f "$DMITL" ] && [ $DMAG -eq 0 ]; then
	echo "Dimensions ------- INACTIVO"
else
	echo "Dimensions ------- NO SE DETECTA INSTALADO"
fi
if [ -f "$CDITL" ] && [ $CDAG -eq 2 ]; then
	echo "ConnectDirect ---- ACTIVO"
elif [ -f "$CDITL" ] && [ $CDAG -eq 0 ]; then
	echo "ConnectDirect ---- INACTIVO"
else
	echo "ConnectDirect ---- NO SE DETECTA INSTALADO"
fi
if [ -f "$S1ITL" ] && [ $S1AG -eq 5 ]; then
	echo "SentinelOneAgent - ACTIVO"
elif [ -f "$S1ITL" ] && [ $S1AG -eq 0 ]; then
	echo "SentinelOneAgent - INACTIVO"
else
	echo "SentinelOneAgent - NO SE DETECTA INSTALADO"
fi
echo "###########################################"
echo " "
echo "Aplicaciones"






echo "-------------------------------------------"
echo "Finaliza validacion: $(date +%m/%d/%Y-%H:%M:%S)"
echo "-------------------------------------------"


#ps -eo args | grep WebSphere80  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent"
#ps -eo args | grep WebSphere80  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent" | grep -v ^qzxy
#ps -eo args | grep webseal | grep -v grep | tr "-" "\n" | grep ".conf"$ | cut -d "." -f1 | sort
#ps -eo args | egrep "pdmgrd|pdacld" | grep -v grep | awk '{print $1}' | cut -d "/" -f5
#ps -eo args | grep -v grep | grep -i HTTP | tr "/" "\n" | egrep -i "^HTTP|httpd-" | awk '{print $1}' | cut -d "." -f1 | sort | uniq
#dspmq
#ps -eo args | grep -v admin | sed 's/.conf//g' | grep -iE "pd\\s+\-f" | cut -d' ' -f3 | sort | uniq | cut -d'/' -f3