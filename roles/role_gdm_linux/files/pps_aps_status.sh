#!/bin/bash
#--- Inicio validacion PPS
# Variables de validacion
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

#FileSystems
FSNM=$(df -HT | grep -Ev "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -HT | grep -Ev "Filesystem|#|tmpfs|boot" | wc -l)
NETSTAT=$(netstat -rn | grep -vi kernel | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g')

# Uptime robusto e independiente de locale
if [ -f /proc/uptime ]; then
    read -r up_seconds _ < /proc/uptime
    up_seconds=${up_seconds%.*}
    days=$((up_seconds / 86400))
    hours=$(( (up_seconds % 86400) / 3600 ))
    mins=$(( (up_seconds % 3600) / 60 ))
    if [ "$days" -gt 0 ]; then
        UP="Activo: $days Dia(s), $hours hora(s), $mins minuto(s)"
    else
        UP="Activo: $hours hora(s), $mins minuto(s)"
    fi
else
    UP="Activo: $(uptime 2>/dev/null | cut -d' ' -f3-5)"
fi

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
echo "$UP"
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
if [ -f "$PAITL" ] && [ "$PAAG" -ge 1 ]; then
	echo "PatrolAgent ------ ACTIVO"
elif [ -f "$PAITL" ] && [ "$PAAG" -eq 0 ]; then
	echo "PatrolAgent ------ INACTIVO"
else
	echo "PatrolAgent ------ NO SE DETECTA INSTALADO"
fi
if [ -f "$CAITL" ] && [ "$CAAG" -ge 1 ]; then
	echo "CapacityAgent ---- ACTIVO"
elif [ -f "$CAITL" ] && [ "$CAAG" -eq 0 ]; then
	echo "CapacityAgent ---- INACTIVO"
else
	echo "CapacityAgent ---- NO SE DETECTA INSTALADO"
fi
if [ -f "$CTMITL" ] && [ "$CTMAG" -ge 1 ]; then
	echo "Control-MAgent --- ACTIVO"
elif [ -f "$CTMITL" ] && [ "$CTMAG" -eq 0 ]; then
	echo "Control-MAgent --- INACTIVO"
else
	echo "Control-MAgent --- NO SE DETECTA INSTALADO"
fi
if [ -f "$DMITL" ] && [ "$DMAG" -ge 1 ]; then
	echo "Dimensions ------- ACTIVO"
elif [ -f "$DMITL" ] && [ "$DMAG" -eq 0 ]; then
	echo "Dimensions ------- INACTIVO"
else
	echo "Dimensions ------- NO SE DETECTA INSTALADO"
fi
if [ -f "$CDITL" ] && [ "$CDAG" -ge 1 ]; then
	echo "ConnectDirect ---- ACTIVO"
elif [ -f "$CDITL" ] && [ "$CDAG" -eq 0 ]; then
	echo "ConnectDirect ---- INACTIVO"
else
	echo "ConnectDirect ---- NO SE DETECTA INSTALADO"
fi
if [ -f "$S1ITL" ] && [ "$S1AG" -ge 1 ]; then
	echo "SentinelOneAgent - ACTIVO"
elif [ -f "$S1ITL" ] && [ "$S1AG" -eq 0 ]; then
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