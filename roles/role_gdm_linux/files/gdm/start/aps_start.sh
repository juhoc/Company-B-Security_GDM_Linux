#!/bin/bash
#--- Inicio alta de APS

echo "-------------------------------------------" > /var/opt/ansible/foto_aps_previa.txt
echo "Alta Aplicaciones" >> /var/opt/ansible/foto_aps_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_aps_previa.txt

# HTTP Servers
for f in /var/opt/ansible/httpserver*.asb; do
    [ -f "$f" ] || continue
    is_was60=false
    if [[ "$f" =~ (85|90) ]]; then
        is_was60=true
    fi
    while read -r https; do
        [ -n "$https" ] || continue
        if [ "$is_was60" = true ]; then
            echo "Iniciando HTTPServer (was60): $https"
            su - was60 -c "$https start"
        else
            echo "Iniciando HTTPServer: $https"
            "$https" start
        fi
    done < "$f"
done

# WebSphere
for f in /var/opt/ansible/websphere*.asb; do
    [ -f "$f" ] || continue
    if [[ "$f" =~ websphere80 ]]; then
        waspath="/WebSphere80/"
        run_as_was60=false
    elif [[ "$f" =~ websphere85 ]]; then
        waspath="/WebSphere85/"
        run_as_was60=true
    elif [[ "$f" =~ websphere90 ]]; then
        waspath="/WebSphere90/"
        run_as_was60=true
    fi
    
    CLUSTER_R=$(ls -1R "$waspath" 2>/dev/null | grep clusters:$ | grep "App\w*/pro\w*/Dmg\w*/con\w*/cel\w*/$(uname -n)" | tr ":" "/")
    if [ -n "$CLUSTER_R" ]; then
        CLUSTER_I=$(ls -1 "$CLUSTER_R" 2>/dev/null)
        for cluwasi in $CLUSTER_I; do
            if [ "$run_as_was60" = true ]; then
                echo "Iniciando WebSphere Cluster (was60): $cluwasi"
                su - was60 -c "cd ${waspath}AppServer/profiles/Dmgr01/bin && ./wsadmin.sh -lang jython -f ./alta_Cluster.py $cluwasi"
            else
                echo "Iniciando WebSphere Cluster: $cluwasi"
                (cd "${waspath}AppServer/profiles/Dmgr01/bin" && ./wsadmin.sh -lang jython -f ./alta_Cluster.py "$cluwasi")
            fi
        done
    fi
done

# MQ
for suffix in "" "8" "9" "90" "93"; do
    asb_file="/var/opt/ansible/mqm${suffix}.asb"
    cmd_file="/var/opt/ansible/mqm${suffix}a.asb"
    if [ -f "$asb_file" ] && [ -f "$cmd_file" ]; then
        cmd=$(cat "$cmd_file")
        while read -r i; do
            [ -n "$i" ] || continue
            echo "Iniciando Canal/Cola MQ (mqm): $i con comando $cmd"
            su - mqm -c "$cmd $i"
        done < "$asb_file"
    fi
done
