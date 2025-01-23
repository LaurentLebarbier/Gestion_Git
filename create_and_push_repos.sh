#!/bin/bash

# Configuration
BASE_PATH="/var/www/html"
GITHUB_USER="LaurentLebarbier"  # Remplacez par votre nom d'utilisateur GitHub
GITHUB_TOKEN=""  # Remplacez par votre token GitHub
DEFAULT_BRANCH="main"  # Branche par défaut

# Fonction pour créer un dépôt sur GitHub via l'API
create_github_repo() {
    local repo_name=$1
    local repo_desc="Dépôt pour $repo_name"

    echo "Création du dépôt $repo_name sur GitHub..."

    curl -u "$GITHUB_USER:$GITHUB_TOKEN" \
        -X POST https://api.github.com/user/repos \
        -d "{\"name\": \"$repo_name\", \"description\": \"$repo_desc\", \"private\": false}"

    if [ $? -eq 0 ]; then
        echo "Dépôt $repo_name créé avec succès."
    else
        echo "Erreur lors de la création du dépôt $repo_name."
        exit 1
    fi
}

# Fonction pour initialiser un dépôt Git local
initialize_local_repo() {
    local dir_path=$1

    cd "$dir_path" || exit 1

    if [ ! -d .git ]; then
        echo "Initialisation du dépôt Git local dans $dir_path..."
        git init

        # Ajouter un fichier initial si le répertoire est vide
        if [ -z "$(ls -A .)" ]; then
            echo "Ajout d'un fichier placeholder .gitkeep..."
            touch .gitkeep
            git add .gitkeep
        else
            git add .
        fi

        git commit -m "Initial commit"
        git branch -M "$DEFAULT_BRANCH"
        git remote add origin "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$(basename "$dir_path").git"
    else
        echo "Le dépôt Git local existe déjà dans $dir_path."
    fi
}

# Fonction pour synchroniser les modifications avec GitHub
sync_with_github() {
    local dir_path=$1

    cd "$dir_path" || exit 1

    echo "Synchronisation des modifications pour $(basename "$dir_path")..."

    # Exclure les workflows
    if [ -d ".github" ]; then
        echo "Exclusion des workflows .github pour éviter les erreurs de permission..."
        git rm -r --cached .github 2>/dev/null
    fi

    git add .
    if git commit -m "Mise à jour automatique"; then
        git push -u origin "$DEFAULT_BRANCH"

        if [ $? -eq 0 ]; then
            echo "Synchronisation réussie pour $(basename "$dir_path")."
        else
            echo "Erreur lors de la synchronisation pour $(basename "$dir_path")."
        fi
    else
        echo "Aucune modification à synchroniser pour $(basename "$dir_path")."
        # Forcer le push si le dépôt est vide sur GitHub
        git push -u origin "$DEFAULT_BRANCH"
    fi
}

# Parcours des répertoires dans BASE_PATH
for dir in "$BASE_PATH"/*; do
    if [ -d "$dir" ]; then
        repo_name=$(basename "$dir")

        # Vérifier si le dépôt existe sur GitHub
        echo "Vérification de l'existence du dépôt $repo_name sur GitHub..."
        repo_exists=$(curl -u "$GITHUB_USER:$GITHUB_TOKEN" -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/$GITHUB_USER/$repo_name)

        if [ "$repo_exists" -eq 404 ]; then
            create_github_repo "$repo_name"
        else
            echo "Le dépôt $repo_name existe déjà sur GitHub."
        fi

        # Initialiser le dépôt local et synchroniser
        initialize_local_repo "$dir"
        sync_with_github "$dir"
    fi
done

# Fin du script
echo "Script terminé."
