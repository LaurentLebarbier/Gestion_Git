#!/bin/sh

#######################################
# Written by @Laurent Lebarbier from https://www.laurentlebarbier.fr
#######################################

# Variables
KEY_NAME="$HOME/.ssh/github_key"
GITHUB_USER="LaurentLebarbier"  # Remplacez par votre nom d'utilisateur GitHub
GITHUB_TOKEN=""  # Remplacez par votre jeton d'accès personnel GitHub
KEY_PATH="$HOME/.ssh/$KEY_NAME"

# Générer une clé SSH si elle n'existe pas
if [ -f "$KEY_PATH" ]; then
    echo "Une clé SSH existe déjà à cet emplacement : $KEY_PATH"
else
    echo "Génération d'une nouvelle clé SSH..."
    ssh-keygen -t ed25519 -f "$KEY_PATH" -C "$GITHUB_USER@github" -N ""
fi

# Ajouter la clé SSH à l'agent ssh
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# Récupérer le contenu de la clé publique
SSH_KEY_CONTENT=$(cat "$KEY_PATH.pub")

# Ajouter la clé à GitHub via l'API
echo "Ajout de la clé SSH à GitHub..."
curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/keys \
    -d "{\"title\": \"$KEY_NAME\", \"key\": \"$SSH_KEY_CONTENT\"}"

if [ $? -eq 0 ]; then
    echo "Clé SSH ajoutée avec succès à votre compte GitHub !"
else
    echo "Erreur lors de l'ajout de la clé SSH à GitHub."
fi