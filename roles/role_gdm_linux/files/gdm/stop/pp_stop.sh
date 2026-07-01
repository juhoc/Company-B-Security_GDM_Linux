#!/bin/bash
#--- Inicio baja de PPS

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_previa.txt
echo "Bajas Programas Producto" >> /var/opt/ansible/foto_pps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_previa.txt

# patrol.asb
if grep -qw ACTIVO$ /var/opt/ansible/patrol.asb 2>/dev/null; then
    if [ -f /patrol/Patrol3/scripts.d/S50PatrolAgent.sh ]; then
        echo "Deteniendo PatrolAgent..."
        su - patrol -c "/patrol/Patrol3/scripts.d/S50PatrolAgent.sh stop"
    fi
fi

# capacity.asb
if grep -qw ACTIVO$ /var/opt/ansible/capacity.asb 2>/dev/null; then
    if [ -f /usr/adm/best1_default/bgs/scripts/best1agent_stop ]; then
        echo "Deteniendo CapacityAgent..."
        su - patrol -c "/usr/adm/best1_default/bgs/scripts/best1agent_stop -b /usr/adm/best1_default"
        su - patrol -c "/etc/bgs/SD/bgssd.exe -d /etc/bgs/SD -k"
        su - patrol -c "/usr/adm/best1_default/bgs/bin/MrStat -b /usr/adm/best1_default -k"
    fi
fi

# ctm.asb
if grep -qw ACTIVO$ /var/opt/ansible/ctm.asb 2>/dev/null; then
    CTM_STOP=$(find /controlm /ctrlmagt -maxdepth 4 -path "*/ctm/scripts/shut-ag" -print -quit 2>/dev/null)
    if [ -n "$CTM_STOP" ]; then
        echo "Deteniendo Control-M Agent..."
        "$CTM_STOP" -u ag700 -p ALL
    fi
fi

# dim.asb
if grep -qw ACTIVO$ /var/opt/ansible/dim.asb 2>/dev/null; then
    DM_STOP=$(find /opt/dimensions -maxdepth 5 -name dmshutdown -print -quit 2>/dev/null)
    if [ -n "$DM_STOP" ]; then
        echo "Deteniendo Dimensions..."
        "$DM_STOP"
    fi
fi

# cd.asb
if grep -qw ACTIVO$ /var/opt/ansible/cd.asb 2>/dev/null; then
    if [ -f /NDM36/depura/stopcd.sh ]; then
        echo "Deteniendo ConnectDirect..."
        su - ndm36 -c "/NDM36/depura/stopcd.sh"
    fi
fi

# s1.asb
if grep -qw ACTIVO$ /var/opt/ansible/s1.asb 2>/dev/null; then
    if [ -f /opt/sentinelone/bin/sentinelctl ]; then
        echo "Deteniendo SentinelOne..."
        /opt/sentinelone/bin/sentinelctl stop
    fi
fi
