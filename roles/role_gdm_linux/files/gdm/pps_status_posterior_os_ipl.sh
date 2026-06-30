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

for i in foto_pps_posterior.txt patrol.asb capacity.asb ctm.asb dim.asb cd.dim.asb s1.asb
do
	touch /var/opt/ansible/$i
done

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_posterior.txt
echo "Informacion Programas Producto" >> /var/opt/ansible/foto_pps_posterior.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_posterior.txt
if [ -f "$PAITL" ] && [ $PAAG -eq 1 ]; then
	echo "PatrolAgent ------ ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "PatrolAgent ------ ACTIVO" > /var/opt/ansible/patrol.asb
elif [ -f "$PAITL" ] && [ $PAAG -eq 0 ]; then
	echo "PatrolAgent ------ INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "PatrolAgent ------ INACTIVO" > /var/opt/ansible/patrol.asb
else
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" > /var/opt/ansible/patrol.asb
fi
if [ -f "$CAITL" ] && [ $CAAG -eq 3 ]; then
	echo "CapacityAgent ---- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "CapacityAgent ---- ACTIVO" > /var/opt/ansible/capacity.asb
elif [ -f "$CAITL" ] && [ $CAAG -eq 0 ]; then
	echo "CapacityAgent ---- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "CapacityAgent ---- INACTIVO" > /var/opt/ansible/capacity.asb
else
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/capacity.asb
fi
if [ -f "$CTMITL" ] && [ $CTMAG -eq 3 ]; then
	echo "Control-MAgent --- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Control-MAgent --- ACTIVO" > /var/opt/ansible/ctm.asb
elif [ -f "$CTMITL" ] && [ $CTMAG -eq 0 ]; then
	echo "Control-MAgent --- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Control-MAgent --- INACTIVO" > /var/opt/ansible/ctm.asb
else
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" > /var/opt/ansible/ctm.asb
fi
if [ -f "$DMITL" ] && [ $DMAG -eq 3 ]; then
	echo "Dimensions ------- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Dimensions ------- ACTIVO" > /var/opt/ansible/dim.asb
elif [ -f "$DMITL" ] && [ $DMAG -eq 0 ]; then
	echo "Dimensions ------- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Dimensions ------- INACTIVO" > /var/opt/ansible/dim.asb
else
	echo "Dimensions ------- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Dimensions ------- NO SE DETECTA INSTALACION" > /var/opt/ansible/dim.asb
fi
if [ -f "$CDITL" ] && [ $CDAG -eq 2 ]; then
	echo "ConnectDirect ---- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "ConnectDirect ---- ACTIVO" > /var/opt/ansible/cd.dim.asb
elif [ -f "$CDITL" ] && [ $CDAG -eq 0 ]; then
	echo "ConnectDirect ---- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "ConnectDirect ---- INACTIVO" > /var/opt/ansible/cd.dim.asb
else
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/cd.dim.asb
fi
if [ -f "$S1ITL" ] && [ $S1AG -eq 5 ]; then
	echo "SentinelOneAgent - ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "SentinelOneAgent - ACTIVO" > /var/opt/ansible/s1.asb
elif [ -f "$S1ITL" ] && [ $S1AG -eq 0 ]; then
	echo "SentinelOneAgent - INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "SentinelOneAgent - INACTIVO" > /var/opt/ansible/s1.asb
else
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" > /var/opt/ansible/s1.asb
fi

for i in foto_pps_posterior.txt patrol.asb capacity.asb ctm.asb dim.asb cd.dim.asb s1.asb
do
	chown bvmuxat2:automate /var/opt/ansible/$i
	chmod 644 /var/opt/ansible/$i
done
