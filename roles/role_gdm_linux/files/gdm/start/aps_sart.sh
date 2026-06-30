#!/bin/bash
#--- Inicio baja de PPS
echo "-------------------------------------------" > /var/opt/ansible/foto_pps_previa.txt
echo "Bajas Programas Producto" >> /var/opt/ansible/foto_pps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_previa.txt

if grep -qw ACTIVO$ /var/opt/ansible/patrol.asb; then
echo "Comando PatrolAgent stop"
fi

if grep -qw ACTIVO$ /var/opt/ansible/capacity.asb; then
echo "Comando Capacity stop"
fi

if grep -qw ACTIVO$ /var/opt/ansible/ctm.asb; then
echo "Comando ControM stop"
fi

if grep -qw ACTIVO$ /var/opt/ansible/dim.asb; then
echo "Comando Dimensions stop"
fi

if grep -qw ACTIVO$ /var/opt/ansible/cd.asb; then
echo "Comando ConnectDirect stop"
fi

if grep -qw ACTIVO$ /var/opt/ansible/s1.asb; then
echo "Comando SentinelOne stop"
fi
