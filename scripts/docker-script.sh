#!/bin/sh

verify_docker_installation() {
    echo "Vérification de l'installation de docker ..."

    if command -v docker >/dev/null 2>&1; then
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