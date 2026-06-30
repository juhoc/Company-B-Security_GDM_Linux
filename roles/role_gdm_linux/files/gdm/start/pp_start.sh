#!/bin/bash
#--- Inicio alta de PPS

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_previa.txt
echo "Alta Programas Producto" >> /var/opt/ansible/foto_pps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_previa.txt

if grep -qw INACTIVO$ /var/opt/ansible/patrol.asb; then
echo "Comando PatrolAgent start"
fi

if grep -qw INACTIVO$ /var/opt/ansible/capacity.asb; then
echo "Comando Capacity start"
fi

if grep -qw INACTIVO$ /var/opt/ansible/ctm.asb; then
echo "Comando ControM start"
fi

if grep -qw INACTIVO$ /var/opt/ansible/dim.asb; then
echo "Comando Dimensions start"
fi

if grep -qw INACTIVO$ /var/opt/ansible/cd.asb; then
echo "Comando ConnectDirect start"
fi

if grep -qw INACTIVO$ /var/opt/ansible/s1.asb; then
echo "Comando SentinelOne start"
fi
