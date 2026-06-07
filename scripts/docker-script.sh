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