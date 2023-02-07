#!/bin/bash
#test init - devo ancora spostare le variabili nel .env 
basedir=$(pwd)
if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
fi

printf "\n\n"

strFilePsk=$basedir/99-common-file/key/secret.key
StrFileEnvProxy=/opt/99-common-file/zabbix-proxy.env
strFileEnvAgent=/opt/99-common-file/zabbix-agent.env
strHostname=$(hostname)
StrSecret=$(openssl rand -hex 32)

if [ -f "$strFilePsk" ]; then
    printf "Attenzione! sistema gia inizializzato.\n\n"
    printf "Di seeguito la chiave psk da inserrire in Zabbix Server.\n"
    printf "==============================\n"
    cat "$strFilePsk"
    printf "==============================\n"
    printf "\n"

    read -p "Vuoi inserirne una diversa? (n) " StrRead
    if [ "$StrRead" != "n" ] && [ "$StrRead" != "" ]; then
        rm -rf /opt/99-common-file/key/secret.key
        echo "$StrRead" > /opt/99-common-file/key/secret.key
    fi

else
    StrSecret=$(openssl rand -hex 32)
    printf "Di seeguito la chiave psk da inserrire in Zabbix Server.\n"
    printf "==============================\n"
    printf "%s" "$StrSecret" && printf "\n"
    printf "==============================\n"
    printf "\n"
    echo "$StrSecret" > /opt/99-common-file/key/secret.key

    #acquisizione indirizzo server zabbix remoto
    read -p "Indirizzo server zabbix? (zabbix.service-lab.com) " StrRead
    if [ "$StrRead" = "" ]; then
        StrRead="zabbix.service-lab.com"
    fi

    sed -i "s/ZBX_SERVER_HOST=.*/ZBX_SERVER_HOST=$StrRead #inrdirizzo zabbix server remoto/" "$StrFileEnvProxy"

    #acquisizione nome per entry sia su zabbix server che interne al container di defualt hostname host
    read -p "nome del proxy zabbix? ($strHostname)" StrRead
    if [ "$StrRead" = "" ]; then
        StrRead=$strHostname
    fi

    sed -i "s/ZBX_HOSTNAME=.*/ZBX_HOSTNAME=$StrRead #nome su zabbix server creare l'host/" "$StrFileEnvProxy"
    sed -i "s/ZBX_TLSPSKIDENTITY=.*/ZBX_TLSPSKIDENTITY=$StrRead/ #Nome su zabbix server per il proxy" "$StrFileEnvProxy"
    sed -i "s/ZBX_HOSTNAME=.*/ZBX_HOSTNAME=$StrRead #nome su zabbix server creare l'host deve corrispondere al hostname del proxy/" "$strFileEnvAgent"
fi
~      