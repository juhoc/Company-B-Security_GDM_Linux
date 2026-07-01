#!/bin/bash
#--- Inicio alta de PPS

echo "-------------------------------------------" > /var/opt/ansible/foto_pps_previa.txt
echo "Alta Programas Producto" >> /var/opt/ansible/foto_pps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_pps_previa.txt

# patrol.asb
if grep -qw ACTIVO$ /var/opt/ansible/patrol.asb 2>/dev/null; then
    if [ -f /patrol/Patrol3/scripts.d/S50PatrolAgent.sh ]; then
        echo "Iniciando PatrolAgent..."
        su - patrol -c "/patrol/Patrol3/scripts.d/S50PatrolAgent.sh start"
    fi
fi

# capacity.asb
if grep -qw ACTIVO$ /var/opt/ansible/capacity.asb 2>/dev/null; then
    if [ -f /etc/bgs/SD/bgssd.exe ]; then
        echo "Iniciando CapacityAgent..."
        su - patrol -c "/etc/bgs/SD/bgssd.exe -d /etc/bgs/SD -s"
        su - patrol -c "/usr/adm/best1_default/bgs/scripts/best1agent_start -b /usr/adm/best1_default"
        su - patrol -c "/usr/adm/best1_default/bgs/scripts/best1collect -Q"
    fi
fi

# ctm.asb
if grep -qw ACTIVO$ /var/opt/ansible/ctm.asb 2>/dev/null; then
    CTM_START=$(find /controlm /ctrlmagt -maxdepth 4 -path "*/ctm/scripts/start-ag" -print -quit 2>/dev/null)
    if [ -n "$CTM_START" ]; then
        echo "Iniciando Control-M Agent..."
        "$CTM_START" -u ag700 -p ALL
    fi
fi

# dim.asb
if grep -qw ACTIVO$ /var/opt/ansible/dim.asb 2>/dev/null; then
    DM_START=$(find /opt/dimensions -maxdepth 5 -name dmstartup -print -quit 2>/dev/null)
    if [ -n "$DM_START" ]; then
        echo "Iniciando Dimensions..."
        "$DM_START"
    fi
fi

# cd.asb
if grep -qw ACTIVO$ /var/opt/ansible/cd.asb 2>/dev/null; then
    if [ -f /NDM36/depura/startcd.sh ]; then
        echo "Iniciando ConnectDirect..."
        su - ndm36 -c "/NDM36/depura/startcd.sh"
    fi
fi

# s1.asb
if grep -qw ACTIVO$ /var/opt/ansible/s1.asb 2>/dev/null; then
    if [ -f /opt/sentinelone/bin/sentinelctl ]; then
        echo "Iniciando SentinelOne..."
        /opt/sentinelone/bin/sentinelctl start
    fi
fi
