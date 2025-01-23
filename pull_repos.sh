#!/bin/bash

# Configuration
BASE_PATH="/var/www/html"
GITHUB_USER="LaurentLebarbier"  # Remplacez par votre nom d'utilisateur GitHub
GITHUB_TOKEN=""  # Remplacez par votre token GitHub

# Fonction pour effectuer un pull sur un dépôt local
pull_repo() {
    local dir_path=$1

    cd "$dir_path" || exit 1

    if [ -d .git ]; then
        echo "Mise à jour du dépôt local dans $dir_path..."

        git pull origin $(git rev-parse --abbrev-ref HEAD)

        if [ $? -eq 0 ]; then
            echo "Mise à jour réussie pour $(basename "$dir_path")."
        else
            echo "Erreur lors de la mise à jour pour $(basename "$dir_path")."
        fi
    else
        echo "Aucun dépôt Git trouvé dans $dir_path. Ignoré."
    fi
}

# Parcours des répertoires dans BASE_PATH
for dir in "$BASE_PATH"/*; do
    if [ -d "$dir" ]; then
        pull_repo "$dir"
    fi
done

# Fin du script
echo "Mise à jour de tous les dépôts terminée."
