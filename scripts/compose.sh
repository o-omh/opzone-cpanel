run_docker_compose() {
    COMPOSE_FILE="${1:-docker-compose.yml}"

    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker n'est pas installé."
        return 1
    fi

    if ! command -v docker compose >/dev/null 2>&1; then
        echo "Docker Compose n'est pas disponible."
        return 1
    fi

    if [ ! -f "$COMPOSE_FILE" ]; then
        echo "Fichier compose introuvable : $COMPOSE_FILE"
        return 1
    fi

    echo "Lancement de docker compose avec : $COMPOSE_FILE"

    docker compose -f "$COMPOSE_FILE" up -d
    if [ $? -ne 0 ]; then
        echo "Échec du démarrage docker compose"
        return 1
    fi

    echo "Attente de l'état des conteneurs..."

    sleep 3

    # Vérifie que tous les conteneurs sont "Up"
    NOT_RUNNING=$(docker compose -f "$COMPOSE_FILE" ps --format json | grep -v '"State":"running"' || true)

    if [ -n "$NOT_RUNNING" ]; then
        echo "Certains conteneurs ne sont pas en état RUNNING :"
        docker compose -f "$COMPOSE_FILE" ps
        return 1
    fi

    echo "Tous les conteneurs sont démarrés."
    docker compose -f "$COMPOSE_FILE" ps

    return 0
}