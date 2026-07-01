#!/bin/bash

#---PA INICIO
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
        echo "ACTIVO" > /var/opt/ansible/patrol.asb
    fi
else
    if [ -d /patrol ]; then
        if [ "$PAAG" -eq 1 ]; then
            echo "ACTIVO" > /var/opt/ansible/patrol.asb
        fi
    fi
fi
#---PA FIN

#---CA INICIO
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
        echo "ACTIVO" > /var/opt/ansible/capacity.asb
    fi
else
    if [ -d /performance ]; then
        if [ "$CAAG" -ge 3 ]; then
            echo "ACTIVO" > /var/opt/ansible/capacity.asb
        fi
    fi
fi
#---CA FIN

#---CTM INICIO
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
        echo "ACTIVO" > /var/opt/ansible/ctm.asb
    fi
else
    if [ -d /controlm/ag700 ]; then
        if [ "$CTMAG" -ge 3 ]; then
            echo "ACTIVO" > /var/opt/ansible/ctm.asb
        fi
    fi
fi
#---CTM FIN

#---DIM INICIO
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
        echo "${DMVER},ACTIVO" > /var/opt/ansible/dim.asb
    fi
else
    if [ -d /opt/dimensions ]; then
        if [ "$DMAG" -ge 3 ]; then
            echo "${DMVER},ACTIVO" > /var/opt/ansible/dim.asb
        fi
    fi
fi
#---DIM FIN

#---CD INICIO
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
        echo "ACTIVO" > /var/opt/ansible/cd.asb
    fi
else
    if [ -d /NDM36 ]; then
        if [ "$CDAG" -ge 2 ]; then
            echo "ACTIVO" > /var/opt/ansible/cd.asb
        fi
    fi
fi
#---CD FIN

#---S1 INICIO
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
        echo "ACTIVO" > /var/opt/ansible/s1.asb
    fi
else
    if [ -d /opt/sentinelone ]; then
        if [ "$S1AG" -ge 5 ]; then
            echo "ACTIVO" > /var/opt/ansible/s1.asb
        fi
    fi
fi
#---S1 FIN

for i in patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
do
    chown bvmuxat2:automate /var/opt/ansible/"$i" 2>/dev/null
    chmod 644 /var/opt/ansible/"$i" 2>/dev/null
done