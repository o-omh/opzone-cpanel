#!/bin/sh

verify_docker_installation() {
    echo "Vérification de l'installation de docker ..."

    if command -v docker >/dev/null 2>&1; then
        docker --version
        return 0
    fi

    echo "Docker n'est pas installé."
    return 1
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "Docker est déjà installé :"
        docker --version
        return 0
    fi

    if [ "$(id -u)" -ne 0 ]; then
        echo "Veuillez exécuter cette fonction en tant que root."
        return 1
    fi

    [ -f /etc/os-release ] || {
        echo "Impossible d'identifier le système."
        return 1
    }

    . /etc/os-release
    echo "Système détecté : $PRETTY_NAME"

    case "$ID" in
        ubuntu|debian|centos|rhel|rocky|almalinux)
            curl -fsSL https://get.docker.com | sh
            ;;
        fedora)
            dnf -y install dnf-plugins-core
            curl -fsSL https://get.docker.com | sh
            ;;
        alpine)
            apk update
            apk add docker docker-cli
            rc-update add docker default
            service docker start
            ;;
        *)
            echo "Distribution non prise en charge automatiquement."
            return 1
            ;;
    esac

    if command -v docker >/dev/null 2>&1; then
        echo "Docker installé avec succès :"
        docker --version

        if command -v systemctl >/dev/null 2>&1; then
            systemctl enable --now docker
        fi
    else
        echo "Échec de l'installation de Docker."
        return 1
    fi
}