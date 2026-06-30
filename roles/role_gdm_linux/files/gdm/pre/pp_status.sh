#!/bin/bash

#---PA INICIO
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
        echo "ACTIVO" > /var/opt/ansible/patrol.asb
    fi
else
    if [ -d /patrol ]; then
        if [ $PAAG -eq 1 ]; then
            echo "ACTIVO" > /var/opt/ansible/patrol.asb
        fi
    fi
fi
#---PA FIN

#---CA INICIO
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
        echo "ACTIVO" > /var/opt/ansible/capacity.asb
    fi
else
    if [ -d /performance ]; then
        if [ $CAAG -ge 3 ]; then
            echo "ACTIVO" > /var/opt/ansible/capacity.asb
        fi
    fi
fi
#---CA FIN

#---CTM INICIO
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
        echo "ACTIVO" > /var/opt/ansible/ctm.asb
    fi
else
    if [ -d /controlm/ag700 ]; then
        if [ $CTMAG -ge 3 ]; then
            echo "ACTIVO" > /var/opt/ansible/ctm.asb
        fi
    fi
fi
#---CTM FIN

#---DIM FIN
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
        echo "$DMVER,ACTIVO" > /var/opt/ansible/dim.asb
    fi
else
    if [ -d /opt/dimensions ]; then
        if [ $DMAG -ge 3 ]; then
            echo "$DMVER,ACTIVO" > /var/opt/ansible/dim.asb
        fi
    fi
fi
#---DIM INICIO

#---CD INICIO
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
        echo "ACTIVO" > /var/opt/ansible/cd.asb
    fi
else
    if [ -d /NDM36 ]; then
        if [ $CDAG -ge 3 ]; then
            echo "ACTIVO" > /var/opt/ansible/cd.asb
        fi
    fi
fi
#---CD INICIO

#---S1 INICIO
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
        echo "ACTIVO" > /var/opt/ansible/s1.asb
    fi
else
    if [ -d /opt/sentinelone ]; then
        if [ $S1AG -ge 5 ]; then
            echo "ACTIVO" > /var/opt/ansible/s1.asb
        fi
    fi
fi
#---S1 FIN

for i in patrol.asb capacity.asb ctm.asb dim.asb cd.asb s1.asb
do
    chown 2>/dev/null bvmuxat2:automate /var/opt/ansible/$i
    chmod 2>/dev/null 644 /var/opt/ansible/$i
done