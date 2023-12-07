#!/bin/bash

#Variables de colores
red="\e[0;91m"
green="\e[0;92m"
bold="\e[1m"
reset="\e[0m"
REPO="295topics-fullstack"

#Priviledges
if [ "$EUID" -ne 0 ]; then
    echo -e "${red}${bold}Este script requiere priviledgios de administrador para ser ejecutado. Por favor usa Sudo o Root. ☒ ${reset}"
    exit 1
fi

#Only one update
sudo apt update >/dev/null 2>&1

#uninstalling old versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

for component in "${components[@]}"; do
    if dpkg -s docker >/dev/null 2>&1; then
        echo -e "${green}${bold}$component instalado ☑ ${reset}"
        echo
    else
        echo -e "${red}${bold}$component no instalado ☒ instalación en progreso...${reset}"
        echo
        sudo ./docker.sh >/dev/null 2>&1
        echo -e "${green}${bold}$component instalación completa ☑ ${reset}"
        echo
		
    fi
done

if [ -d "$REPO/.git" ]; then
     echo -e "${green}${bold}El repositorio DevOpsTravel ya existe, realizando git pull...${reset}"
     cd $REPO
     git pull >/dev/null 2>&1
     echo -e "${green}${bold}Pull completado, datos copiados a la carpeta html  Listo ☑ ${reset}"
else
     echo -e "${red}${bold}Clonando el repositorio, por favor espera... ☒ ${reset}"
     git clone https://github.com/franncot/$REPO.git >/dev/null 2>&1
     echo -e "${green}${bold}Repo Clonado -  Listo ☑ ${reset}"
fi

containers=("frontend" "backend" "mongodb" "mongo-express")
running_containers=$(docker ps -qf "name=(${containers[*]})")

start_compose=false

for container in "${containers[@]}"; do
    if ! echo "$running_containers" | grep -q "$container"; then
        echo "Container '$container' is not running."
		cd  $REPO
        docker-compose --env-file .env.dev up -d --build
    fi
done
