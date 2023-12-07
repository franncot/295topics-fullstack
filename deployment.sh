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

if [ -d "$REPO/.git" ]; then
     echo -e "${green}${bold}El repositorio FullStack topics ya existe, realizando git pull...${reset}"
     cd $REPO
     git pull >/dev/null 2>&1
     echo -e "${green}${bold}Pull completado - Listo ☑ ${reset}"
else
     echo -e "${red}${bold}Clonando el repositorio, por favor espera... ☒ ${reset}"
     git clone https://github.com/franncot/$REPO.git >/dev/null 2>&1
     echo -e "${green}${bold}Repo Clonado -  Listo ☑ ${reset}"
fi

#Update
sudo apt update >/dev/null 2>&1

#Installing docker newest version
for component in "${components[@]}"; do
    if dpkg -s docker-ce >/dev/null 2>&1; then
        echo -e "${green}${bold}$component instalado ☑ ${reset}"
        echo
    else
        echo -e "${red}${bold}$component no instalado ☒ instalación en progreso...${reset}"
        echo
        sudo ./$REPO/docker.sh >/dev/null 2>&1
        echo -e "${green}${bold}$component instalación completa ☑ ${reset}"
        echo
		
    fi
done

#istal curl for testing
sudo apt install curl >/dev/null 2>&1

# Function to check if the application is running
check_application() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/topics)
    if [ "$response" -eq 200 ]; then
        echo -e "${green}${bold}Full stack application started and ready for test - Listo  ☑ ${reset}"
        exit 0
    else
        echo -e "${red}${bold}Application not started. Starting Docker Compose...☒ instalación en progreso...${reset}"
        cd  $REPO >/dev/null 2>&1docker cont
        docker compose --env-file .env.dev up -d --build
        sleep 5
        echo -e "${green}${bold}Please try to access the application at  with curl -i -X http://localhost:5000/api/topics  - Listo  ☑ ${reset}"
    fi
}
check_application