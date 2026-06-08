#!/bin/sh

verify_docker_installation() {
    echo "Vérification de l'installation de docker ..."

    if command -v docker > /dev/null 2>&1; then
        docker --version
        exit 0
    fi

    echo "Docker n'est pas installé."
    return 1
}

install_docker() {
    verify_docker_installation;

    if [ ! -f /etc/os-release ]; then
        echo "Impossible d'identifier le système."
        return 1
    fi

    . /etc/os-release
    echo "Système détecté : $PRETTY_NAME"

    case "$ID" in
        ubuntu|debian)
            apt-get update
            apt-get install -y ca-certificates curl gnupg lsb-release
            curl -fsSL https://get.docker.com | sh
            ;;
        centos|rhel|rocky|almalinux)
            curl -fsSL https://get.docker.com | sh
            ;;
        fedora)
            dnf -y install dnf-plugins-core
            curl -fsSL https://get.docker.com | sh
            ;;
        alpine)
            apk update
            apk add docker docker-cli
            ;;
        *)
            echo "Distribution non prise en charge automatiquement."
            return 1
            ;;
    esac
}

start_docker_service() {
    echo "Démarrage du service Docker..."

    if ! command -v docker > /dev/null 2>&1; then
        echo "Docker n'est pas installé."
        return 1
    fi

    if command -v systemctl > /dev/null 2>&1; then
        systemctl enable docker
        systemctl start docker
    elif command -v rc-update > /dev/null 2>&1; then
    	rc-update add docker default
        service docker start
    else
        echo "Démarrage manuel requis."
    fi
}

show_help() {
    cat <<EOF
Usage: $0 <commande>

Commandes disponibles :
  install   Installer Docker
  verify    Vérifier l'installation de Docker
  start     Démarrer et activer le service Docker
  all       Installer, vérifier puis démarrer Docker
  help      Afficher cette aide

Exemples :
  $0 install
  $0 verify
  $0 start
  $0 all
EOF
}

case "${1:-help}" in
    install)
        install_docker
        ;;

    verify)
        verify_docker_installation
        ;;

    start)
        start_docker_service
        ;;

    all)
        install_docker || exit 1
        verify_docker_installation || exit 1
        start_docker_service || exit 1

        echo "Installation terminée."
        docker --version
        ;;

    help|-h|--help)
        show_help
        ;;

    *)
        echo "Commande inconnue : $1"
        echo
        show_help
        exit 1
        ;;
esac