#!/bin/bash

#--- FOTO REPORTE PREVIO
#--- INICIO VALIDACION SALUD OS
TIME=$(date +'%a-%b-%e %H:%M')
IPS=$(ip -o -4 addr | tr " " "," | sed 's/,,,,/,/g;s/inet,//g;s/:,/:/g' | cut -d: -f2 | cut -d'/' -f1)
OSPF=$(cat /etc/*release | grep ^ID= | cut -d= -f2 | tr -d "\"")
UPSN=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -s; fi)
UPPF=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -p; fi)
#CPUMEM=$(top -n 1 -b | head -5)
CPUMEM=$(echo "%CPU Usage,%CPU System,%CPU Nice,%CPU Idle,%CPU iowait,%CPU hardware,%CPU software,%CPU steal";top -n 1 -b | grep "^%Cpu" | awk '{print $2 "," $4 "," $6 "," $8 "," $10 "," $12 "," $14 "," $16}';free -ht| sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g;s/.total/Metrics,Total/g;s/used/Used/g;s/free/Free/g;s/shared/Shared/g;s/buff\/cache/Buff\/Cache/g;s/available/Available/g;s/://g')
STSFW=$(firewall-cmd 2>/dev/null --state)
VALFW=$(if [ "$STSFW" = "running" ]; then echo "$STSFW"; else echo "not running"; fi)
IPTBL=$(iptables -n -L -v)
FSNM=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | wc -l)
#OSRL=$(cat /etc/*release | egrep -w "^ID=|^VERSION_ID|^PRETTY_NAME" | sort)
OSRL=$(cat /etc/*release | egrep -w "^ID=|^VERSION_ID|^PRETTY_NAME" | tr -d "()\"" | cut -d= -f2)

echo "-------------------------------------------" > /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Informacion de salud del SSOO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Fecha: $TIME" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Hostname: $(hostname)" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Direcciones IPs:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "$IPS" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
if [ "$OSPF" = "rhel" ]
then
    echo "Ultimo arranque de Sistema Operativo:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    echo "$UPSN" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    echo "$UPPF" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
else
    echo "Ultimo arranque de Sistema Operativo:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    echo "$UPSN" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
fi
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Uso de CPU y Memoria:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "$CPUMEM" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Estado del firewall:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "$VALFW" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "$IPTBL" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Estado del FileSystems:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "VGS,LV,Tipo,Tamaño,T.Utilizado,T.Disponible,% de Uso,Montura" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "$FSNM" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Numero de Filesystems: $FSC" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Versión de sistema operativo:" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "$OSRL" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt

#--- FOTO REPORTE PREVIO
#--- INICIO VALIDACION PROGRAMAS PRODUCTO
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Informacion Programas Producto" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt

#---PATROLAGENT
PAFSC=$(df -h | awk '{print $6}' | grep \w*patrol$ | wc -l)
PAFSN=$(df -h | awk '{print $6}' | grep \w*patrol$)

if [ -d $PAFSN ]; then
    PAITLN="$(ls 2>/dev/null -1R $PAFSN | grep scripts.d:$ | tr ":" "/")S50PatrolAgent.sh"
    PAITLC=$(ls 2>/dev/null $PAITLN | wc -l)
else
    PAITLN=""
    PAITLC="$(ls 2>/dev/null $PAITLN | wc -l)"
fi
PAAG=$(ps -eo args | grep -wi patrolagent | grep -v grep | wc -l)

if [ $PAFSC -gt 0 ]; then
    if [ $PAAG -eq 1 ] && [ $PAITLC -eq 1 ]; then
        echo "PatrolAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    elif [ $PAAG -eq 0 ] && [ $PAITLC -eq 1 ]; then
        echo "PatrolAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    fi
else
    if [ -d /patrol ]; then
        if [ $PAAG -eq 1 ]; then
            echo "PatrolAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "PatrolAgent se ejecuta en un directorio, no tiene FS /patrol" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            elif [ $PAAG -eq 0 ] && [ $PAITLC -eq 1 ]; then
            echo "PatrolAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "PatrolAgent se ejecuta en un directorio, no tiene FS /patrol" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            fi
    fi
fi

#---CAPACITYAGENT
CAFSC=$(df -h | awk '{print $6}' | grep \w*performance$ | wc -l)
CAFSN=$(df -h | awk '{print $6}' | grep \w*performance$)

if [ -d $CAFSN ]; then
    CAITLN="$(ls 2>/dev/null -1R $CAFSN | grep bgs/bin:$ | tr ":" "/")bgsagent"
    CAITLC=$(ls 2>/dev/null  $CAITLN | wc -l)
else
    CAITLN=""
    CAITLC="$(ls 2>/dev/null  $CAITLN | wc -l)"
fi
CAAG=$(ps -eo args | grep -wi "bgs\w*" | grep -v grep | wc -l)

if [ $CAFSC -gt 0 ]; then
    if [ $CAAG -ge 3 ] && [ $CAITLC -eq 1 ]; then
        echo "CapacityAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    elif [ $CAAG -eq 3 ] && [ $CAITLC -eq 1 ]; then
        echo "CapacityAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    fi
else
    if [ -d /performance ]; then
        if [ $CAAG -ge 3 ]; then
            echo "CapacityAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "CapacityAgent se ejecuta en un directorio, no tiene FS /performance" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            elif [ $CAAG -eq 0 ] && [ $CAITLC -eq 1 ]; then
            echo "CapacityAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "CapacityAgent se ejecuta en un directorio, no tiene FS /performance" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            fi
    fi
fi

#---CONTROL-M
CTMFSC=$(df -h | awk '{print $6}' | grep \w*controlm | wc -l)
CTMFSN=$(df -h | awk '{print $6}' | grep \w*controlm)

if [ -d $CTMFSN ]; then
    CTMITLN="$(ls 2>/dev/null -1R $CTMFSN | grep ctm/scripts:$ | tr ":" "/")start-ag"
    CTMITLC=$(ls 2>/dev/null $CTMITLN | wc -l)
else
    CTMITLN=""
    CTMITLC=$(ls 2>/dev/null  $CTMITLN | wc -l)
fi
CTMAG=$(ps -eo args | grep ctma\w* | grep -v grep | wc -l)

if [ $CTMFSC -gt 0 ]; then
    if [ $CTMAG -ge 3 ] && [ $CTMITLC -eq 1 ]; then
        echo "Contro-MAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    elif [ $CTMAG -eq 3 ] && [ $CTMITLC -eq 1 ]; then
        echo "Contro-MAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    fi
else
    if [ -d /controlm/ag700 ]; then
        if [ $CTMAG -ge 3 ]; then
            echo "Contro-MAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "Contro-MAgent se ejecuta en un directorio, no tiene FS /controlm/ag700" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            elif [ $CTMAG -eq 0 ] && [ $CTMITLC -eq 1 ]; then
            echo "Contro-MAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "Contro-MAgent se ejecuta en un directorio, no tiene FS /controlm/ag700" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            fi
    fi
fi

#---DIMENSIONS
DMFSC=$(df -h | awk '{print $6}' | grep \w*dimensions | wc -l)
DMFSN=$(df -h | awk '{print $6}' | grep \w*dimensions)

if [ -d $DMFSN ]; then
    DMITLN="$(ls 2>/dev/null -1R $DMFSN | grep cm/prog:$ | tr ":" "/")dmstartup"
    DMITLC=$(ls 2>/dev/null $DMITLN | wc -l)
    DMVER=$(ls 2>/dev/null -1R $DMFSN | grep cm/prog:$ | tr ":" "/" | cut -d'/' -f4)
else
    DMITLN=""
    DMITLC=$(echo $DMITLN | wc -l)
fi
DMAG=$(ps -eo args | grep dimension\w* | grep -v grep | wc -l)

if [ $DMFSC -gt 0 ]; then
    if [ $DMAG -ge 3 ] && [ $DMITLC -eq 1 ]; then
        echo "Dimensions$DMVER - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    elif [ $DMAG -eq 0 ] && [ $DMITLC -eq 1 ]; then
        echo "Dimensions$DMVER - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    fi
else
    if [ -d /opt/dimensions ]; then
        if [ $DMAG -ge 3 ]; then
            echo "Dimensions$DMVER - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "Dimensions$DMVER se ejecuta en un directorio, no tiene FS /opt/dimensions" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            elif [ $DMAG -eq 0 ] && [ $DMITLC -eq 1 ]; then
            echo "Dimensions$DMVER - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "Dimensions$DMVER se ejecuta en un directorio, no tiene FS /opt/dimensions" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            fi
    fi
fi

#---CONNECTDIRECT
CDFSC=$(df -h | awk '{print $6}' | grep \w*NDM36 | wc -l)
CDFSN=$(df -h | awk '{print $6}' | grep \w*NDM36)

if [ -d $CDFSN ]; then
    CDITLN="$(ls 2>/dev/null -1R $CDFSN | grep depura:$ | tr ":" "/")startcd.sh"
    CDITLC=$(ls 2>/dev/null  $CDITLN | wc -l)
else
    CDITLN=""
    CDITLC=$(ls 2>/dev/null  $CDITLN | wc -l)
fi
CDAG=$(ps -eo args | egrep -wi "cdpmgr|cdstatm" | grep -v grep | wc -l)

if [ $CDFSC -gt 0 ]; then
    if [ $CDAG -ge 2 ] && [ $CDITLC -eq 1 ]; then
        echo "ConnectDirect - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    elif [ $CDAG -eq 0 ] && [ $CDITLC -eq 1 ]; then
        echo "ConnectDirect - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    fi
else
    if [ -d /NDM36 ]; then
        if [ $CDAG -ge 3 ]; then
            echo "ConnectDirect - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "ConnectDirect se ejecuta en un directorio, no tiene FS /NDM36" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            elif [ $CDAG -eq 3 ] && [ $CDITLC -eq 1 ]; then
            echo "ConnectDirect - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "ConnectDirect se ejecuta en un directorio, no tiene FS /controlm/ag700" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            fi
    fi
fi

#---SENTINELONE
S1FSC=$(df -h | awk '{print $6}' | grep \w*sentinelone | wc -l)
S1FSN=$(df -h | awk '{print $6}' | grep \w*sentinelone)

if [ -d $S1FSN ]; then
    S1ITLN="$(ls 2>/dev/null -1R $S1FSN | grep bin:$ | tr ":" "/")sentinelctl"
    S1ITLC=$(ls 2>/dev/null $S1ITLN | wc -l)
else
    S1ITLN=""
    S1ITLC=$(ls ls 2>/dev/null $S1ITLN | wc -l)
fi
S1AG=$(ps -eo args | grep -wi "s1-\w*" | grep -v grep | wc -l)

if [ $S1FSC -gt 0 ]; then
    if [ $S1AG -ge 5 ] && [ $S1ITLC -eq 1 ]; then
        echo "SentinelOneAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    elif [ $S1AG -eq 0 ] && [ $S1ITLC -eq 1 ]; then
        echo "SentinelOneAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
    fi
else
    if [ -d /opt/sentinelone ]; then
        if [ $S1AG -ge 5 ]; then
            echo "SentinelOneAgent - ACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "SentinelOne se ejecuta en un directorio, no tiene FS /opt/sentinelone" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            elif [ $S1AG -eq 0 ] && [ $S1ITLC -eq 1 ]; then
            echo "SentinelOneAgent - INACTIVO" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            echo "SentinelOne se ejecuta en un directorio, no tiene FS /opt/sentinelone" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
            fi
    fi
fi

#--- FOTO REPORTE PREVIO
#--- INICIO VALIDACION APLICACIONES
#--- WEBSPHERE
echo " " >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt
echo "Informacion Aplicaciones" >> /var/opt/ansible/foto_sso_pp_aps_previa.txt

for i in $(df -h | awk '{print $6}' | egrep "WebSphere80$|WebSphere85$|WebSphere90$" | paste -sd ' ' -)
do
  WSV=$(ls 2>/dev/null -1R $i/AppServer/profiles | grep bin:$ | tr ":" "/")
  WSA=$(ls -1 $(echo "$WSV" | grep AppSrv01) |egrep -i "^start|^stop" | wc -l)
  WSD=$(ls -1 $(echo "$WSV" | grep Dmgr01) |egrep -i "^start|^stop" | wc -l)
  WSI=$(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent" | wc -l)
  WSP=$(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent" | wc -l)
  if [ $WSA -eq 6 ] && [ $WSD -eq 6 ] && [ $WSI -ge 1 ] && [ $WSP -ge 1 ]; then
    echo "-------------------------------------------" 
    echo "Procesos dmge y nodeagent $(echo $i | tr -d '/')" 
    echo "-------------------------------------------"
    for WP in $(ps -eo args | grep $i  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent")
    do
      ps -eo args | grep $WP >/dev/null && echo "$WP ----- ACTIVA"
    done
    echo "-------------------------------------------" 
    echo "Lista de instancias $(echo $i | tr -d '/')" 
    echo "-------------------------------------------" 
    for WI in $(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent")
    do
      ps -eo args | grep $WI >/dev/null && echo "$WI ----- ACTIVA"
    done 
    echo " "
  elif [ $WSA -eq 6 ] && [ $WSD -eq 6 ] && [ $WSI -eq 0 ] && [ $WSP -ge 1 ]; then
    echo "-------------------------------------------" 
    echo "Lista de instancias $(echo $i | tr -d '/')" 
    echo "-------------------------------------------"
    echo "INSTANCIAS ----- INACTIVAS"
    echo "-------------------------------------------"
    echo "Procesos dmge y nodeagent $(echo $i | tr -d '/')" 
    echo "-------------------------------------------"
    for WP in $(ps -eo args | grep $i  | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent")
    do
      ps -eo args | grep $WP >/dev/null && echo "$WP ----- ACTIVA"
    done
    echo " "
  elif [ $WSA -eq 6 ] && [ $WSD -eq 6 ] && [ $WSI -eq 0 ] && [ $WSP -eq 0 ]; then
    echo "-------------------------------------------" 
    echo "Lista de instancias $(echo $i | tr -d '/')" 
    echo "-------------------------------------------"
    echo "INSTANCIAS ----- INACTIVAS"
    echo "-------------------------------------------"
    echo "Procesos dmge y nodeagent $(echo $i | tr -d '/')" 
    echo "-------------------------------------------"
    echo "PROCESOS ----- INACTIVAS"
    echo " "
  fi
done >> /var/opt/ansible/foto_sso_pp_aps_previa.txt

#--- HTTPS
for i in $(df -h | awk '{print $6}' | egrep "HTTPServer80$|HTTPServer85$|HTTPServer90$" | paste -sd ' ' -)
do
  AHR=$(ls 2>/dev/null -1R $i | grep $i/bin:$ | tr ":" "/")
  AHB=$(ls 2>/dev/null -1 $AHR | grep -i "^apachectl$" | wc -l)
  AHS=$(ls 2>/dev/null -1 $i/conf | egrep "^admin\.\w*f$|^httpd\.\w*f$" | wc -l)
  AHD=$(ls 2>/dev/null -1 $i/conf | grep ^httpd\w*. | grep conf$ | grep -v httpd.conf | wc -l)
  AHPSC=$(ps -eo args | grep -v grep | grep $i | grep -E "httpd\\s+\-" | tr "/" "\n" | egrep -i "^HTTPS|httpd\w*" | awk '{print $1}' | sort | uniq | egrep -v "conf|HTTPServer" | wc -l)
  AHPDC=$(ps -eo args | grep -v grep | grep $i | grep -E "httpd\\s+\-" | tr "/" "\n" | egrep -i "^HTTPS|httpd\w*" | awk '{print $1}' | sort | uniq | grep conf | cut -d. -f1 | wc -l)
  AHPSN=$(ps -eo args | grep -v grep | grep $i | grep -E "httpd\\s+\-" | tr "/" "\n" | egrep -i "^HTTPS|httpd\w*" | awk '{print $1}' | sort | uniq | egrep -v "conf|HTTPServer")
  AHPDN=$(ps -eo args | grep -v grep | grep $i | grep -E "httpd\\s+\-" | tr "/" "\n" | egrep -i "^HTTPS|httpd\w*" | awk '{print $1}' | sort | uniq | grep conf | cut -d. -f1 | grep -v httpd$)
  if [ $AHB -eq 1 ] && [ $AHS -eq 2 ] && [ $AHD -eq 0 ]; then
      echo "-------------------------------------------"
      echo "Lista $(echo $i | tr -d '/') standalone"
      echo "-------------------------------------------"
    for https in $AHPSN
    do
      ps -eo args | grep $i >/dev/null && echo "$https ----- ACTIVA" || echo "$https ----- INACTIVO"
    done
      echo " "
    elif [ $AHB -eq 1 ] && [ $AHS -eq 2 ] && [ $AHD -ge 1 ]; then
      echo "-------------------------------------------"
      echo "Lista $(echo $i | tr -d '/') standalone y dedicadas"
      echo "-------------------------------------------"
    for https in $AHPSN
    do
      ps -eo args | grep $i >/dev/null && echo "$https ----- ACTIVA" || echo "$https ----- INACTIVO"
    done
    for httpd in $AHPDN
    do
      ps -eo args | grep $httpd >/dev/null && echo "$httpd ----- ACTIVA" || echo "$httpd ----- INACTIVO"
    done
      echo " "
  fi
done >> /var/opt/ansible/foto_sso_pp_aps_previa.txt

#--- MQS
for i in $(df -h | awk '{print $6}' | grep "^/opt/mqm\w*" | paste -sd ' ' -)
do
  MQR=$(ls 2>/dev/null -1R $i | grep /bin:$ | tr ":" "/" | egrep -v "java\w*|maintenance\w*|gskit\W*|amqp\w*|mqexplorer\w*|mqft\w*|samp\w*")
  MQB=$(ls 2>/dev/null -1 $MQR | egrep -i "^strmqm$|endmqm" | wc -l)
  MQPC=$(ps -eo args | grep -wE "$i/\w*/\w*\\s+\w*" | cut -d' ' -f3 | grep -wE "^QM\w*$" | sort | uniq | wc -l)
  MQPN=$(ps -eo args | grep -wE "$i/\w*/\w*\\s+\w*" | cut -d' ' -f3 | grep -wE "^QM\w*$" | sort | uniq)
  MQV=$(ls 2>/dev/null -1R $i | grep /bin:$ | tr ":" "/" | egrep -v "java\w*|maintenance\w*|gskit\W*|amqp\w*|mqexplorer\w*|mqft\w*|samp\w*" | awk -F '/' '{print $3}')
  
  if [ $MQB -eq 2 ] && [ $MQPC -ge 1 ] && [ "$MQV" = "mqm" ]; then
    echo "-------------------------------------------" 
    echo "Lista sesiones $(echo $i | cut -d "/" -f3 | tr "[:lower:]" "[:upper:]")"
    echo "-------------------------------------------" 
    for MQS in $MQPN
    do
      ps -eo args | grep -wE "$i/\w*/\w*\\s+\w*" | cut -d' ' -f3 | grep ^$MQS >/dev/null && echo "$MQS ----- ACTIVA" || echo "$MQS ----- INACTIVA"
    done
    echo " "
    elif [ $MQB -eq 2 ] && [ $MQPC -ge 1 ]; then
    echo "-------------------------------------------" 
    echo "Lista sesiones $(echo $i | cut -d "/" -f3 | tr "[:lower:]" "[:upper:]")"
    echo "-------------------------------------------"
    for MQS in $MQPN
    do
      ps -eo args | grep -wE "$i/\w*/\w*\\s+\w*" | cut -d' ' -f3 | grep ^$MQS >/dev/null && echo "$MQS ----- ACTIVA" || echo "$MQS ----- INACTIVA"
    done
    echo " "
  fi
done >> /var/opt/ansible/foto_sso_pp_aps_previa.txt

for i in foto_sso_pp_aps_previa.txt
do
    chown 2>/dev/null bvmuxat2:automate /var/opt/ansible/$i
    chmod 2>/dev/null 644 /var/opt/ansible/$i
done