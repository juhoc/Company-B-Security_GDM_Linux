#!/bin/bash

#--- FOTO PROCESOS ACTIVOS vs INACTIVOS PRIVIOS
#--- WEBSPHERE
for i in $(df -h | awk '{print $6}' | egrep "WebSphere80$|WebSphere85$|WebSphere90$" | paste -sd ' ' -)
do
  WSRB=$(ls 2>/dev/null -1R $i/AppServer/profiles | grep bin:$ | tr ":" "/")
  WSA=$(ls -1 $(echo "$WSRB" | grep AppSrv01) |egrep -i "^start|^stop" | wc -l)
  WSD=$(ls -1 $(echo "$WSRB" | grep Dmgr01) |egrep -i "^start|^stop" | wc -l)
  WSP=$(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent" | wc -l)
  WSPN=$(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep "dmgr|nodeagent")
  WSI=$(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent" | wc -l)
  WSIN=$(ps -eo args | grep $i | awk '/com.ibm.ws.runtime.WsServer/{print $NF}' | sort | uniq | egrep -v "dmgr|nodeagent")
  WSV=$(echo "$i" | tr -d '/' | tr "[:upper:]" "[:lower:]")
  if [ "$WSV" = "websphere80" ] && [ $WSA -eq 6 ] && [ $WSD -eq 6 ] && [ $WSP -ge 1 ] && [ $WSI -ge 1 ]; then
    echo "$WSPN" > /var/opt/ansible/$WSV.asb
    echo "$WSIN" >> /var/opt/ansible/$WSV.asb
  elif [ "$WSV" = "websphere85" ] && [ $WSA -eq 6 ] && [ $WSD -eq 6 ] && [ $WSP -ge 1 ] && [ $WSI -ge 1 ]; then
    echo "$WSPN" > /var/opt/ansible/$WSV.asb
    echo "$WSIN" >> /var/opt/ansible/$WSV.asb
  elif [ "$WSV" = "websphere90" ] && [ $WSA -eq 6 ] && [ $WSD -eq 6 ] && [ $WSP -ge 1 ] && [ $WSI -ge 1 ]; then
    echo "$WSPN" > /var/opt/ansible/$WSV.asb
    echo "$WSIN" >> /var/opt/ansible/$WSV.asb
  fi
done

#--- HTTPS-S
for i in $(df -h | awk '{print $6}' | egrep "HTTPServer80$|HTTPServer85$|HTTPServer90$" | paste -sd ' ')
do
    AHR=$( ls 2>/dev/null -1R $i | grep "$i/bin:$" | tr ":" "/")
    AHBSN=$( ls 2>/dev/null -1 "$AHR" | grep -i "^apachectl$")
    AHBSC=$(echo "$AHBSN" | wc -l)
    AHPSC=$(ps -eo args | grep -v grep | grep "$i" | wc -l)
    AHV=$(echo "$i"s | tr -d '/' | tr "[:upper:]" "[:lower:]")
    if [ "$AHV" = httpserver90s ] && [ $AHPSC -gt 0 ] && [ $AHBSC -gt 0 ]; then
        echo "$AHR$AHBSN" > "/var/opt/ansible/$AHV.asb"
    elif [ "$AHV" = "httpserver80s" ] || [ "$AHV" = "httpserver85s" ] && [ $AHPSC -gt 0 ] && [ $AHBSC -gt 0 ]; then
        echo "$AHR$AHBSN" > "/var/opt/ansible/$AHV.asb"
        echo "$AHR"adminctl >> "/var/opt/ansible/$AHV.asb"
    fi
done

#--- HTTPS-D
for i in $(df -h | awk '{print $6}' | egrep "HTTPServer80$|HTTPServer85$|HTTPServer90$" | paste -sd ' ' -)
do
  AHRD=$(ls 2>/dev/null -1R $i | grep $i/bin:$ | tr ":" "/" | egrep -v "gsk\w*|java|properties\w*")
  AHNBD=$(ls 2>/dev/null -1 $AHRD | grep apachectl\w* | grep -vi "^apachectl$" | egrep -vi "crq|inc|req|\w*bak|\w*bck|orig\w*|\w*levant\w*")
  AHCBD=$(ls 2>/dev/null -1 $AHRD | grep apachectl\w* | grep -vi "^apachectl$" | egrep -vi "crq|inc|req|\w*bak|\w*bck|orig\w*|\w*levant\w*" | wc -l)
  AHNCD=$(ls 2>/dev/null -1 $AHRD | grep apachectl\w* | grep -vi "^apachectl$" | egrep -vi "crq|inc|req|\w*bak|\w*bck|orig\w*|\w*levant\w*" | sed 's/apachectl//g')
  AHV=$(echo "$i"d | tr -d '/' | tr "[:upper:]" "[:lower:]")
  APACHE_DEDICADO_ACTIVO=false
  for DEDICADA in $(echo "$AHNBD" | sed 's/apachectl//;s/^C[-]*//g;s/^apachectl[-]*//;s/\-//;s/_//' | paste -sd ' ')
  do
    if [ $(ps -eo args | grep -v grep | grep $i | grep $DEDICADA | wc -l | tr -d "\n") -ge 1 ]; then
      if [ "$APACHE_DEDICADO_ACTIVO" = false ]; then
        APACHE_DEDICADO_ACTIVO=true
        >/var/opt/ansible/$AHV.asb
      fi
      echo "$AHRD$(ls -1 $AHRD | grep $DEDICADA | egrep -vi "crq|inc|req|\w*bak|\w*bck|orig\w*|\w*olevant\w*")" | grep ^/ >> /var/opt/ansible/$AHV.asb
    fi
  done
  if [ "$APACHE_DEDICADO_ACTIVO" = false ]; then
    rm -f /var/opt/ansible/$AHV.asb 2>/dev/null
  fi
done

#--- MQS
for i in $(df -h | awk '{print $6}' | grep "^/opt/mqm\w*" | paste -sd ' ' -)
do
  MQR=$(ls 2>/dev/null -1R $i | grep /bin:$ | tr ":" "/" | egrep -v "java\w*|maintenance\w*|gskit\W*|amqp\w*|mqexplorer\w*|mqft\w*|samp\w*|mqxr\w*")
  MQBSTR=$(ls -1 $MQR | grep ^strmqm$)
  MQRBSTR=$(echo $MQR$MQBSTR)
  MQBSTP=$(ls -1 $MQR | grep ^endmqm$)
  MQRBSTP=$(echo $MQR$MQBSTP)
  MQB=$(ls 2>/dev/null -1 $MQR | egrep -i "^strmqm$|endmqm" | wc -l)
  MQPC=$(ps -eo args | grep -wE "$i/\w*/\w*\\s+\w*" | cut -d' ' -f3 | grep -wE "^QM\w*$" | sort | uniq | wc -l)
  MQPN=$(ps -eo args | grep -wE "$i/\w*/\w*\\s+\w*" | cut -d' ' -f3 | grep -wE "^QM\w*$" | sort | uniq)
  MQV=$(ls 2>/dev/null -1R $i | grep /bin:$ | tr ":" "/" | egrep -v "java\w*|maintenance\w*|gskit\W*|amqp\w*|mqexplorer\w*|mqft\w*|samp\w*|mqxr\w*" | awk -F '/' '{print $3}')
  
  if [ $MQB -eq 2 ] && [ $MQPC -ge 1 ] && [ "$MQV" = mqm ]; then
    echo $MQRBSTR > /var/opt/ansible/"$MQV"a.asb
    echo $MQRBSTP> /var/opt/ansible/"$MQV"b.asb
    echo $MQPN > /var/opt/ansible/$MQV.asb
  elif [ $MQB -eq 2 ] && [ $MQPC -ge 1 ]; then
    echo $MQRBSTR > /var/opt/ansible/"$MQV"a.asb
    echo $MQRBSTP > /var/opt/ansible/"$MQV"b.asb
    echo $MQPN > /var/opt/ansible/$MQV.asb
  fi
done

for ftpre in foto_sso_pp_aps_previa.txt *.asb
do
  chown 2>/dev/null bvmuxat2:automate /var/opt/ansible/$ftpre
  chmod 2>/dev/null 644 /var/opt/ansible/$ftpre
done

