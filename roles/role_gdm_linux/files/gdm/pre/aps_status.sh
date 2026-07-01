#!/bin/bash

#--- FOTO PROCESOS ACTIVOS vs INACTIVOS PRIVIOS
#--- WEBSPHERE
for i in $(df -h | awk '{print $6}' | grep -E "WebSphere80$|WebSphere85$|WebSphere90$" | sort)
do
  WSV=$(echo "$i" | tr -d '/' | tr "[:upper:]" "[:lower:]")
  
  WSA=$(find "$i/AppServer/profiles" -maxdepth 4 -path "*AppSrv01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
  WSD=$(find "$i/AppServer/profiles" -maxdepth 4 -path "*Dmgr01/bin" -type f \( -name "start*" -o -name "stop*" \) 2>/dev/null | wc -l)
  
  WSP=$(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -Ec "dmgr|nodeagent")
  WSPN=$(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -E "dmgr|nodeagent")
  
  WSI=$(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -Evc "dmgr|nodeagent")
  WSIN=$(ps -eo args | grep -F "$i" | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort -u | grep -Ev "dmgr|nodeagent")
  
  if [ "$WSA" -eq 6 ] && [ "$WSD" -eq 6 ] && [ "$WSP" -ge 1 ] && [ "$WSI" -ge 1 ]; then
    echo "$WSPN" > /var/opt/ansible/"$WSV".asb
    echo "$WSIN" >> /var/opt/ansible/"$WSV".asb
  fi
done

#--- HTTPS-S
for i in $(df -h | awk '{print $6}' | grep -E "HTTPServer80$|HTTPServer85$|HTTPServer90$" | sort)
do
    AHR=$(find "$i" -maxdepth 3 -type d -name bin 2>/dev/null | head -n 1)
    if [ -n "$AHR" ]; then
        AHR="${AHR%/}/"
        AHBSN=$(find "$AHR" -maxdepth 1 -type f -name apachectl 2>/dev/null | sed 's#.*/##')
        AHBSC=$(echo "$AHBSN" | grep -c .)
        AHPSC=$(ps -eo args | grep -v grep | grep -Fc "$i")
        AHV=$(echo "$i"s | tr -d '/' | tr "[:upper:]" "[:lower:]")
        
        if [ "$AHV" = "httpserver90s" ] && [ "$AHPSC" -gt 0 ] && [ "$AHBSC" -gt 0 ]; then
            echo "$AHR$AHBSN" > "/var/opt/ansible/$AHV.asb"
        elif { [ "$AHV" = "httpserver80s" ] || [ "$AHV" = "httpserver85s" ]; } && [ "$AHPSC" -gt 0 ] && [ "$AHBSC" -gt 0 ]; then
            echo "$AHR$AHBSN" > "/var/opt/ansible/$AHV.asb"
            echo "${AHR}adminctl" >> "/var/opt/ansible/$AHV.asb"
        fi
    fi
done

#--- HTTPS-D
for i in $(df -h | awk '{print $6}' | grep -E "HTTPServer80$|HTTPServer85$|HTTPServer90$" | sort)
do
  AHRD=$(find "$i" -maxdepth 3 -type d -name bin 2>/dev/null | grep -Ev "gsk|java|properties" | head -n 1)
  if [ -n "$AHRD" ]; then
    AHRD="${AHRD%/}/"
    AHNBD=$(find "$AHRD" -maxdepth 1 -type f -name "apachectl*" ! -name "apachectl" 2>/dev/null | grep -Ev "crq|inc|req|bak|bck|orig|levant" | sed 's#.*/##')
    AHV=$(echo "$i"d | tr -d '/' | tr "[:upper:]" "[:lower:]")
    APACHE_DEDICADO_ACTIVO=false
    
    for DEDICADA in $(echo "$AHNBD" | sed 's/apachectl//;s/^C[-]*//g;s/^apachectl[-]*//;s/\-//;s/_//')
    do
      if [ -n "$DEDICADA" ] && [ "$(ps -eo args | grep -v grep | grep "$i" | grep -c "$DEDICADA")" -ge 1 ]; then
        if [ "$APACHE_DEDICADO_ACTIVO" = false ]; then
          APACHE_DEDICADO_ACTIVO=true
          > "/var/opt/ansible/$AHV.asb"
        fi
        SPECIFIC_CTL=$(find "$AHRD" -maxdepth 1 -type f -name "*$DEDICADA*" ! -name "apachectl" 2>/dev/null | grep -Ev "crq|inc|req|bak|bck|orig|olevant" | head -n 1)
        if [ -n "$SPECIFIC_CTL" ]; then
          echo "$SPECIFIC_CTL" >> "/var/opt/ansible/$AHV.asb"
        fi
      fi
    done
    
    if [ "$APACHE_DEDICADO_ACTIVO" = false ]; then
      rm -f "/var/opt/ansible/$AHV.asb" 2>/dev/null
    fi
  fi
done

#--- MQS
for i in $(df -h | awk '{print $6}' | grep "^/opt/mqm" | sort)
do
  MQR=$(find "$i" -maxdepth 3 -type d -name bin 2>/dev/null | grep -Ev "java|maintenance|gskit|amqp|mqexplorer|mqft|samp|mqxr" | head -n 1)
  if [ -n "$MQR" ]; then
    MQR="${MQR%/}/"
    MQBSTR=$(find "$MQR" -maxdepth 1 -type f -name strmqm 2>/dev/null | sed 's#.*/##')
    MQRBSTR="${MQR}${MQBSTR}"
    MQBSTP=$(find "$MQR" -maxdepth 1 -type f -name endmqm 2>/dev/null | sed 's#.*/##')
    MQRBSTP="${MQR}${MQBSTP}"
    
    MQB=$(find "$MQR" -maxdepth 1 -type f \( -name strmqm -o -name endmqm \) 2>/dev/null | wc -l)
    MQPC=$(ps -eo args | grep -E "$i/[a-zA-Z0-9_]+/[a-zA-Z0-9_]+" | cut -d' ' -f3 | grep -E "^QM" | sort -u | wc -l)
    MQPN=$(ps -eo args | grep -E "$i/[a-zA-Z0-9_]+/[a-zA-Z0-9_]+" | cut -d' ' -f3 | grep -E "^QM" | sort -u)
    MQV=$(echo "$MQR" | awk -F '/' '{print $3}')
    
    if [ "$MQB" -eq 2 ] && [ "$MQPC" -ge 1 ]; then
      echo "$MQRBSTR" > /var/opt/ansible/"${MQV}"a.asb
      echo "$MQRBSTP" > /var/opt/ansible/"${MQV}"b.asb
      echo "$MQPN" > /var/opt/ansible/"$MQV".asb
    fi
  fi
done

for ftpre in foto_sso_pp_aps_previa.txt *.asb
do
  chown bvmuxat2:automate /var/opt/ansible/"$ftpre" 2>/dev/null
  chmod 644 /var/opt/ansible/"$ftpre" 2>/dev/null
done
