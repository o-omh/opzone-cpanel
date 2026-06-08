#!/bin/sh

set -e

if [ ! -f ".env" ]; then
	echo "⚠️⚠️⚠️ Fichier d'environement: '.env' absent."
	echo "🚫 Installation annulée."
    exit 1
fi

./scripts/docker.sh install

set -a
source .env
set +a

if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
	echo ""
	echo "🛠️ Création du réseau docker global"
    docker network create "$NETWORK_NAME"
fi

if ! docker volume inspect "$CERT_VOLUME" > /dev/null 2>&1; then
	echo ""
	echo "🛠️ Création du volume des certificats ssl"
    docker volume create "$CERT_VOLUME"
fi

if ! docker volume inspect "$ROOT_VOLUME" > /dev/null 2>&1; then
	echo ""
	echo "🛠️ Création du volume racine des sites"
    docker volume create "$ROOT_VOLUME"
fi

echo ""
echo "🚀 Lancement de l'installation du serveur..."

./scripts/compose.sh compose-wait

echo ""
echo "✅ Installation terminée !!!"