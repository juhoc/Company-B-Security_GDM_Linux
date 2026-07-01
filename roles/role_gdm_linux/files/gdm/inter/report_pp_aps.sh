#!/bin/bash

#--- FOTO REPORTE INTERMEDIO
#--- INICIO VALIDACION SALUD OS
TIME=$(date +'%a-%b-%e %H:%M')
IPS=$(ip -o -4 addr | tr " " "," | sed 's/,,,,/,/g;s/inet,//g;s/:,/:/g' | cut -d: -f2 | cut -d'/' -f1)
OSPF=$(cat /etc/*release | grep ^ID= | cut -d= -f2 | tr -d "\"")
UPSN=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -s; fi)
UPPF=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -p; fi)
CPUMEM=$(echo "%CPU Usage,%CPU System,%CPU Nice,%CPU Idle,%CPU iowait,%CPU hardware,%CPU software,%CPU steal";top -n 1 -b | grep "^%Cpu" | awk '{print $2 "," $4 "," $6 "," $8 "," $10 "," $12 "," $14 "," $16}';free -ht| sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g;s/.total/Metrics,Total/g;s/used/Used/g;s/free/Free/g;s/shared/Shared/g;s/buff\/cache/Buff\/Cache/g;s/available/Available/g;s/://g')
STSFW=$(firewall-cmd 2>/dev/null --state || echo "not running")
VALFW=$(if [ "$STSFW" = "running" ]; then echo "$STSFW"; else echo "not running"; fi)
IPTBL=$(iptables -n -L -v)
FSNM=$(df -hT | grep -Ev "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -hT | grep -Ev "Filesystem|#|tmpfs|boot" | wc -l)
OSRL=$(cat /etc/*release | grep -Ew "^ID=|^VERSION_ID|^PRETTY_NAME" | tr -d "()\"" | cut -d= -f2)

REPORTE_FILE="foto_sso_pp_aps_intermedia.txt"

echo "-------------------------------------------" > "/var/opt/ansible/$REPORTE_FILE"
echo "Informacion de salud del SSOO" >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Fecha: $TIME" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Hostname: $(hostname)" >> "/var/opt/ansible/$REPORTE_FILE"
echo " " >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Direcciones IPs:" >> "/var/opt/ansible/$REPORTE_FILE"
echo "$IPS" >> "/var/opt/ansible/$REPORTE_FILE"
echo " " >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
if [ "$OSPF" = "rhel" ]
then
    echo "Ultimo arranque de Sistema Operativo:" >> "/var/opt/ansible/$REPORTE_FILE"
    echo "$UPSN" >> "/var/opt/ansible/$REPORTE_FILE"
    echo "$UPPF" >> "/var/opt/ansible/$REPORTE_FILE"
    echo " " >> "/var/opt/ansible/$REPORTE_FILE"
else
    echo "Ultimo arranque de Sistema Operativo:" >> "/var/opt/ansible/$REPORTE_FILE"
    echo "$UPSN" >> "/var/opt/ansible/$REPORTE_FILE"
    echo " " >> "/var/opt/ansible/$REPORTE_FILE"
fi
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Uso de CPU y Memoria:" >> "/var/opt/ansible/$REPORTE_FILE"
echo "$CPUMEM" >> "/var/opt/ansible/$REPORTE_FILE"
echo " " >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Estado del firewall:" >> "/var/opt/ansible/$REPORTE_FILE"
echo "$VALFW" >> "/var/opt/ansible/$REPORTE_FILE"
echo "$IPTBL" >> "/var/opt/ansible/$REPORTE_FILE"
echo " " >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Estado del FileSystems:" >> "/var/opt/ansible/$REPORTE_FILE"
echo "VGS,LV,Tipo,Tamaño,T.Utilizado,T.Disponible,% de Uso,Montura" >> "/var/opt/ansible/$REPORTE_FILE"
echo "$FSNM" >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Numero de Filesystems: $FSC" >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Versión de sistema operativo:" >> "/var/opt/ansible/$REPORTE_FILE"
echo "$OSRL" >> "/var/opt/ansible/$REPORTE_FILE"
echo " " >> "/var/opt/ansible/$REPORTE_FILE"

#--- FOTO REPORTE PREVIO
#--- INICIO VALIDACION PROGRAMAS PRODUCTO
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Informacion Programas Producto" >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"

#---PATROLAGENT
PAFSN=$(df -h | awk '{print $6}' | grep -E "patrol$" | head -n 1)
PAFSC=$(echo "$PAFSN" | grep -c .)

if [ -n "$PAFSN" ] && [ -d "$PAFSN" ]; then
    PAITLN=$(find "$PAFSN" -maxdepth 4 -path "*/scripts.d/S50PatrolAgent.sh" 2>/dev/null | head -n 1)
    PAITLC=$(echo "$PAITLN" | grep -c .)
else
    PAITLN=""
    PAITLC=0
fi
PAAG=$(pgrep -ic "^patrolagent$")

if [ "$PAFSC" -gt 0 ]; then
    if [ "$PAAG" -eq 1 ] && [ "$PAITLC" -eq 1 ]; then
        echo "PatrolAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    elif [ "$PAAG" -eq 0 ] && [ "$PAITLC" -eq 1 ]; then
        echo "PatrolAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    fi
else
    if [ -d /patrol ]; then
        if [ "$PAAG" -eq 1 ]; then
            echo "PatrolAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "PatrolAgent se ejecuta en un directorio, no tiene FS /patrol" >> "/var/opt/ansible/$REPORTE_FILE"
        elif [ "$PAAG" -eq 0 ]; then
            echo "PatrolAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "PatrolAgent se ejecuta en un directorio, no tiene FS /patrol" >> "/var/opt/ansible/$REPORTE_FILE"
        fi
    fi
fi

#---CAPACITYAGENT
CAFSN=$(df -h | awk '{print $6}' | grep -E "performance$" | head -n 1)
CAFSC=$(echo "$CAFSN" | grep -c .)

if [ -n "$CAFSN" ] && [ -d "$CAFSN" ]; then
    CAITLN=$(find "$CAFSN" -maxdepth 4 -name bgsagent 2>/dev/null | head -n 1)
    CAITLC=$(echo "$CAITLN" | grep -c .)
else
    CAITLN=""
    CAITLC=0
fi
CAAG=$(pgrep -ic -f "bgssd|bgsagent|bgscollect")

if [ "$CAFSC" -gt 0 ]; then
    if [ "$CAAG" -ge 3 ] && [ "$CAITLC" -eq 1 ]; then
        echo "CapacityAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    elif [ "$CAAG" -eq 0 ] && [ "$CAITLC" -eq 1 ]; then
        echo "CapacityAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    fi
else
    if [ -d /performance ]; then
        if [ "$CAAG" -ge 3 ]; then
            echo "CapacityAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "CapacityAgent se ejecuta en un directorio, no tiene FS /performance" >> "/var/opt/ansible/$REPORTE_FILE"
        elif [ "$CAAG" -eq 0 ]; then
            echo "CapacityAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "CapacityAgent se ejecuta en un directorio, no tiene FS /performance" >> "/var/opt/ansible/$REPORTE_FILE"
        fi
    fi
fi

#---CONTROL-M
CTMFSN=$(df -h | awk '{print $6}' | grep -E "controlm$" | head -n 1)
CTMFSC=$(echo "$CTMFSN" | grep -c .)

if [ -n "$CTMFSN" ] && [ -d "$CTMFSN" ]; then
    CTMITLN=$(find "$CTMFSN" -maxdepth 4 -path "*/ctm/scripts/start-ag" 2>/dev/null | head -n 1)
    CTMITLC=$(echo "$CTMITLN" | grep -c .)
else
    CTMITLN=""
    CTMITLC=0
fi
CTMAG=$(pgrep -ic -f "^ctma")

if [ "$CTMFSC" -gt 0 ]; then
    if [ "$CTMAG" -ge 3 ] && [ "$CTMITLC" -eq 1 ]; then
        echo "Contro-MAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    elif [ "$CTMAG" -eq 0 ] && [ "$CTMITLC" -eq 1 ]; then
        echo "Contro-MAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    fi
else
    if [ -d /controlm/ag700 ]; then
        if [ "$CTMAG" -ge 3 ]; then
            echo "Contro-MAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "Contro-MAgent se ejecuta en un directorio, no tiene FS /controlm/ag700" >> "/var/opt/ansible/$REPORTE_FILE"
        elif [ "$CTMAG" -eq 0 ]; then
            echo "Contro-MAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "Contro-MAgent se ejecuta en un directorio, no tiene FS /controlm/ag700" >> "/var/opt/ansible/$REPORTE_FILE"
        fi
    fi
fi

#---DIMENSIONS
DMFSN=$(df -h | awk '{print $6}' | grep -E "dimensions$" | head -n 1)
DMFSC=$(echo "$DMFSN" | grep -c .)

if [ -n "$DMFSN" ] && [ -d "$DMFSN" ]; then
    DMITLN=$(find "$DMFSN" -maxdepth 5 -name dmstartup 2>/dev/null | head -n 1)
    DMITLC=$(echo "$DMITLN" | grep -c .)
    DMVER=$(echo "$DMITLN" | awk -F'/' '{print $(NF-2)}')
else
    DMITLN=""
    DMITLC=0
    DMVER=""
fi
DMAG=$(pgrep -ic "^dimensions$")

if [ "$DMFSC" -gt 0 ]; then
    if [ "$DMAG" -ge 3 ] && [ "$DMITLC" -eq 1 ]; then
        echo "Dimensions$DMVER - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    elif [ "$DMAG" -eq 0 ] && [ "$DMITLC" -eq 1 ]; then
        echo "Dimensions$DMVER - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    fi
else
    if [ -d /opt/dimensions ]; then
        if [ "$DMAG" -ge 3 ]; then
            echo "Dimensions$DMVER - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "Dimensions$DMVER se ejecuta en un directorio, no tiene FS /opt/dimensions" >> "/var/opt/ansible/$REPORTE_FILE"
        elif [ "$DMAG" -eq 0 ]; then
            echo "Dimensions$DMVER - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "Dimensions$DMVER se ejecuta en un directorio, no tiene FS /opt/dimensions" >> "/var/opt/ansible/$REPORTE_FILE"
        fi
    fi
fi

#---CONNECTDIRECT
CDFSN=$(df -h | awk '{print $6}' | grep -E "NDM36$" | head -n 1)
CDFSC=$(echo "$CDFSN" | grep -c .)

if [ -n "$CDFSN" ] && [ -d "$CDFSN" ]; then
    CDITLN=$(find "$CDFSN" -maxdepth 4 -name startcd.sh 2>/dev/null | head -n 1)
    CDITLC=$(echo "$CDITLN" | grep -c .)
else
    CDITLN=""
    CDITLC=0
fi
CDAG=$(pgrep -ic -f "^cdpmgr|^cdstatm")

if [ "$CDFSC" -gt 0 ]; then
    if [ "$CDAG" -ge 2 ] && [ "$CDITLC" -eq 1 ]; then
        echo "ConnectDirect - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    elif [ "$CDAG" -eq 0 ] && [ "$CDITLC" -eq 1 ]; then
        echo "ConnectDirect - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    fi
else
    if [ -d /NDM36 ]; then
        if [ "$CDAG" -ge 2 ]; then
            echo "ConnectDirect - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "ConnectDirect se ejecuta en un directorio, no tiene FS /NDM36" >> "/var/opt/ansible/$REPORTE_FILE"
        elif [ "$CDAG" -eq 0 ]; then
            echo "ConnectDirect - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "ConnectDirect se ejecuta en un directorio, no tiene FS /NDM36" >> "/var/opt/ansible/$REPORTE_FILE"
        fi
    fi
fi

#---SENTINELONE
S1FSN=$(df -h | awk '{print $6}' | grep -E "sentinelone$" | head -n 1)
S1FSC=$(echo "$S1FSN" | grep -c .)

if [ -n "$S1FSN" ] && [ -d "$S1FSN" ]; then
    S1ITLN=$(find "$S1FSN" -maxdepth 4 -name sentinelctl 2>/dev/null | head -n 1)
    S1ITLC=$(echo "$S1ITLN" | grep -c .)
else
    S1ITLN=""
    S1ITLC=0
fi
S1AG=$(pgrep -ic -f "^s1-")

if [ "$S1FSC" -gt 0 ]; then
    if [ "$S1AG" -ge 5 ] && [ "$S1ITLC" -eq 1 ]; then
        echo "SentinelOneAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    elif [ "$S1AG" -eq 0 ] && [ "$S1ITLC" -eq 1 ]; then
        echo "SentinelOneAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
    fi
else
    if [ -d /opt/sentinelone ]; then
        if [ "$S1AG" -ge 5 ]; then
            echo "SentinelOneAgent - ACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "SentinelOne se ejecuta en un directorio, no tiene FS /opt/sentinelone" >> "/var/opt/ansible/$REPORTE_FILE"
        elif [ "$S1AG" -eq 0 ]; then
            echo "SentinelOneAgent - INACTIVO" >> "/var/opt/ansible/$REPORTE_FILE"
            echo "SentinelOne se ejecuta en un directorio, no tiene FS /opt/sentinelone" >> "/var/opt/ansible/$REPORTE_FILE"
        fi
    fi
fi

#--- FOTO REPORTE PREVIO
#--- INICIO VALIDACION APLICACIONES
echo " " >> "/var/opt/ansible/$REPORTE_FILE"
echo "-------------------------------------------" >> "/var/opt/ansible/$REPORTE_FILE"
echo "Informacion Aplicaciones" >> "/var/opt/ansible/$REPORTE_FILE"

#--- WEBSPHERE
for i in $(df -h | awk '{print $6}' | grep -E "WebSphere80$|WebSphere85$|WebSphere90$" | sort)
do
  WSA=$(find "$i/AppServer/profiles" -maxdepth 4 -path "*AppSrv01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
  WSD=$(find "$i/AppServer/profiles" -maxdepth 4 -path "*Dmgr01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
  WSI=$(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -Evc "dmgr|nodeagent")
  WSP=$(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -Ec "dmgr|nodeagent")
  
  if [ "$WSA" -eq 6 ] && [ "$WSD" -eq 6 ] && [ "$WSI" -ge 1 ] && [ "$WSP" -ge 1 ]; then
    echo "-------------------------------------------" 
    echo "Procesos dmge y nodeagent $(echo "$i" | tr -d '/')" 
    echo "-------------------------------------------"
    for WP in $(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -E "dmgr|nodeagent")
    do
      ps -eo args | grep -qi "$WP" && echo "$WP ----- ACTIVA"
    done
    echo "-------------------------------------------" 
    echo "Lista de instancias $(echo "$i" | tr -d '/')" 
    echo "-------------------------------------------" 
    for WI in $(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -Ev "dmgr|nodeagent")
    do
      ps -eo args | grep -qi "$WI" && echo "$WI ----- ACTIVA"
    done 
    echo " "
  elif [ "$WSA" -eq 6 ] && [ "$WSD" -eq 6 ] && [ "$WSI" -eq 0 ] && [ "$WSP" -ge 1 ]; then
    echo "-------------------------------------------" 
    echo "Lista de instancias $(echo "$i" | tr -d '/')" 
    echo "-------------------------------------------"
    echo "INSTANCIAS ----- INACTIVAS"
    echo "-------------------------------------------"
    echo "Procesos dmge y nodeagent $(echo "$i" | tr -d '/')" 
    echo "-------------------------------------------"
    for WP in $(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -E "dmgr|nodeagent")
    do
      ps -eo args | grep -qi "$WP" && echo "$WP ----- ACTIVA"
    done
    echo " "
  elif [ "$WSA" -eq 6 ] && [ "$WSD" -eq 6 ] && [ "$WSI" -eq 0 ] && [ "$WSP" -eq 0 ]; then
    echo "-------------------------------------------" 
    echo "Lista de instancias $(echo "$i" | tr -d '/')" 
    echo "-------------------------------------------"
    echo "INSTANCIAS ----- INACTIVAS"
    echo "-------------------------------------------"
    echo "Procesos dmge y nodeagent $(echo "$i" | tr -d '/')" 
    echo "-------------------------------------------"
    echo "PROCESOS ----- INACTIVAS"
    echo " "
  fi
done >> "/var/opt/ansible/$REPORTE_FILE"

#--- HTTPS
for i in $(df -h | awk '{print $6}' | grep -E "HTTPServer80$|HTTPServer85$|HTTPServer90$" | sort)
do
  AHR=$(find "$i" -maxdepth 3 -type d -name bin 2>/dev/null | head -n 1)
  if [ -n "$AHR" ]; then
    AHR="${AHR%/}/"
    AHB=$(find "$AHR" -maxdepth 1 -type f -name apachectl 2>/dev/null | wc -l)
    AHS=$(find "$i/conf" -maxdepth 1 -type f \( -name "admin.conf" -o -name "httpd.conf" \) 2>/dev/null | wc -l)
    AHD=$(find "$i/conf" -maxdepth 1 -type f -name "httpd*.conf" ! -name "httpd.conf" 2>/dev/null | wc -l)
    
    AHPSC=$(ps -eo args | grep -v grep | grep "$i" | grep -E "httpd[[:space:]]+-" | tr "/" "\n" | grep -Ei "^HTTPS|httpd" | awk '{print $1}' | sort -u | grep -Evc "conf|HTTPServer")
    AHPSN=$(ps -eo args | grep -v grep | grep "$i" | grep -E "httpd[[:space:]]+-" | tr "/" "\n" | grep -Ei "^HTTPS|httpd" | awk '{print $1}' | sort -u | grep -Ev "conf|HTTPServer")
    AHPDN=$(ps -eo args | grep -v grep | grep "$i" | grep -E "httpd[[:space:]]+-" | tr "/" "\n" | grep -Ei "^HTTPS|httpd" | awk '{print $1}' | sort -u | grep conf | cut -d. -f1 | grep -v httpd$)
    
    if [ "$AHB" -eq 1 ] && [ "$AHS" -eq 2 ] && [ "$AHD" -eq 0 ]; then
      echo "-------------------------------------------"
      echo "Lista $(echo "$i" | tr -d '/') standalone"
      echo "-------------------------------------------"
      for https in $AHPSN
      do
        ps -eo args | grep -qi "$i" && echo "$https ----- ACTIVA" || echo "$https ----- INACTIVO"
      done
      echo " "
    elif [ "$AHB" -eq 1 ] && [ "$AHS" -eq 2 ] && [ "$AHD" -ge 1 ]; then
      echo "-------------------------------------------"
      echo "Lista $(echo "$i" | tr -d '/') standalone y dedicadas"
      echo "-------------------------------------------"
      for https in $AHPSN
      do
        ps -eo args | grep -qi "$i" && echo "$https ----- ACTIVA" || echo "$https ----- INACTIVO"
      done
      for httpd in $AHPDN
      do
        ps -eo args | grep -qi "$httpd" && echo "$httpd ----- ACTIVA" || echo "$httpd ----- INACTIVO"
      done
      echo " "
    fi
  fi
done >> "/var/opt/ansible/$REPORTE_FILE"

#--- MQS
for i in $(df -h | awk '{print $6}' | grep "^/opt/mqm" | sort)
do
  MQR=$(find "$i" -maxdepth 3 -type d -name bin 2>/dev/null | grep -Ev "java|maintenance|gskit|amqp|mqexplorer|mqft|samp" | head -n 1)
  if [ -n "$MQR" ]; then
    MQR="${MQR%/}/"
    MQB=$(find "$MQR" -maxdepth 1 -type f \( -name strmqm -o -name endmqm \) 2>/dev/null | wc -l)
    MQPC=$(ps -eo args | grep -E "$i/[a-zA-Z0-9_]+/[a-zA-Z0-9_]+" | cut -d' ' -f3 | grep -E "^QM" | sort -u | wc -l)
    MQPN=$(ps -eo args | grep -E "$i/[a-zA-Z0-9_]+/[a-zA-Z0-9_]+" | cut -d' ' -f3 | grep -E "^QM" | sort -u)
    MQV=$(echo "$MQR" | awk -F '/' '{print $3}')
    
    if [ "$MQB" -eq 2 ] && [ "$MQPC" -ge 1 ]; then
      echo "-------------------------------------------" 
      echo "Lista sesiones $(echo "$i" | cut -d "/" -f3 | tr "[:lower:]" "[:upper:]")"
      echo "-------------------------------------------" 
      for MQS in $MQPN
      do
        ps -eo args | grep -E "$i/[a-zA-Z0-9_]+/[a-zA-Z0-9_]+" | cut -d' ' -f3 | grep -q "^$MQS" && echo "$MQS ----- ACTIVA" || echo "$MQS ----- INACTIVA"
      done
      echo " "
    fi
  fi
done >> "/var/opt/ansible/$REPORTE_FILE"

chown bvmuxat2:automate "/var/opt/ansible/$REPORTE_FILE" 2>/dev/null
chmod 644 "/var/opt/ansible/$REPORTE_FILE" 2>/dev/null