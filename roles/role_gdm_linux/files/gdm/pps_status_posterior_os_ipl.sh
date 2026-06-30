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

# Inicializar archivos de estado
for i in foto_pps_posterior.txt patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
do
	touch /var/opt/ansible/$i
done

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_posterior.txt
echo "Informacion Programas Producto" >> /var/opt/ansible/foto_pps_posterior.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_posterior.txt

if [ -f "$PAITL" ] && [ "$PAAG" -ge 1 ]; then
	echo "PatrolAgent ------ ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "PatrolAgent ------ ACTIVO" > /var/opt/ansible/patrol.asb
elif [ -f "$PAITL" ] && [ "$PAAG" -eq 0 ]; then
	echo "PatrolAgent ------ INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "PatrolAgent ------ INACTIVO" > /var/opt/ansible/patrol.asb
else
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "PatrolAgent ------ NO SE DETECTA INSTALACION" > /var/opt/ansible/patrol.asb
fi

if [ -f "$CAITL" ] && [ "$CAAG" -ge 1 ]; then
	echo "CapacityAgent ---- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "CapacityAgent ---- ACTIVO" > /var/opt/ansible/capacity.asb
elif [ -f "$CAITL" ] && [ "$CAAG" -eq 0 ]; then
	echo "CapacityAgent ---- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "CapacityAgent ---- INACTIVO" > /var/opt/ansible/capacity.asb
else
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "CapacityAgent ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/capacity.asb
fi

if [ -f "$CTMITL" ] && [ "$CTMAG" -ge 1 ]; then
	echo "Control-MAgent --- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Control-MAgent --- ACTIVO" > /var/opt/ansible/ctm.asb
elif [ -f "$CTMITL" ] && [ "$CTMAG" -eq 0 ]; then
	echo "Control-MAgent --- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Control-MAgent --- INACTIVO" > /var/opt/ansible/ctm.asb
else
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Control-MAgent --- NO SE DETECTA INSTALACION" > /var/opt/ansible/ctm.asb
fi

if [ -f "$DMITL" ] && [ "$DMAG" -ge 1 ]; then
	echo "Dimensions ------- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Dimensions ------- ACTIVO" > /var/opt/ansible/dim.asb
elif [ -f "$DMITL" ] && [ "$DMAG" -eq 0 ]; then
	echo "Dimensions ------- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Dimensions ------- INACTIVO" > /var/opt/ansible/dim.asb
else
	echo "Dimensions ------- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "Dimensions ------- NO SE DETECTA INSTALACION" > /var/opt/ansible/dim.asb
fi

if [ -f "$CDITL" ] && [ "$CDAG" -ge 1 ]; then
	echo "ConnectDirect ---- ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "ConnectDirect ---- ACTIVO" > /var/opt/ansible/cd.asb
elif [ -f "$CDITL" ] && [ "$CDAG" -eq 0 ]; then
	echo "ConnectDirect ---- INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "ConnectDirect ---- INACTIVO" > /var/opt/ansible/cd.asb
else
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "ConnectDirect ---- NO SE DETECTA INSTALACION" > /var/opt/ansible/cd.asb
fi

if [ -f "$S1ITL" ] && [ "$S1AG" -ge 1 ]; then
	echo "SentinelOneAgent - ACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "SentinelOneAgent - ACTIVO" > /var/opt/ansible/s1.asb
elif [ -f "$S1ITL" ] && [ "$S1AG" -eq 0 ]; then
	echo "SentinelOneAgent - INACTIVO" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "SentinelOneAgent - INACTIVO" > /var/opt/ansible/s1.asb
else
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" >> /var/opt/ansible/foto_pps_posterior.txt
	echo "SentinelOneAgent - NO SE DETECTA INSTALACION" > /var/opt/ansible/s1.asb
fi

for i in foto_pps_posterior.txt patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
do
	chown bvmuxat2:automate /var/opt/ansible/$i
	chmod 644 /var/opt/ansible/$i
done
