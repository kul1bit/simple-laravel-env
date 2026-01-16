#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://raw.githubusercontent.com/kul1bit/simple-laravel-env/refs/heads/main"


make_file() {
    local input_filename=$1
    local output_filename=$2

    local_file="./stubs/$input_filename"

    if [ -f $local_file ]; then
        cp $local_file "$PROJECT_NAME/$output_filename"
    else
        curl -sL "$REPO_URL/stubs/$input_filename" -o "$PROJECT_NAME/$output_filename"
    fi
}

fill_compose_file() {
    local input_filename=$1

    local_file="./stubs/services/$input_filename"

    if [ -f $local_file ]; then
        echo "Fill $local_file"
        cat $local_file >> "$PROJECT_NAME/docker-compose.yml"
    else
        curl -sL "$REPO_URL/stubs/services/$input_filename" >> "$PROJECT_NAME/docker-compose.yml"
    fi
}



echo -e "${BLUE}=== Laravel Docker Setup ===${NC}\n"

# Check curl
if ! command -v curl --version &>/dev/null; then
    echo -e "${RED}Error: curl is not installed or not in PATH.${NC}\n"
    exit 1
fi
# Check git
if ! command -v git --version &>/dev/null; then
    echo -e "${RED}Error: git is not installed or not in PATH.${NC}\n"
    exit 1
fi


read -r -p "Project name [my-project]: " PROJECT_NAME </dev/tty

PROJECT_NAME=${PROJECT_NAME:-my-project}


# Database
echo -e "\n${GREEN}Database:${NC}"
echo "1) MySQL"
echo "2) PostgreSQL"
echo "3) MariaDB"
echo "4) None"

read -r -p "Choose [1]: " DB_CHOICE </dev/tty

DB_CHOICE=${DB_CHOICE:-1}


# Redis
read -r -p "Add Redis? (y/n) [n]: " REDIS </dev/tty

REDIS=${REDIS:-n}

# Get laravel
echo -e "\n${BLUE}Get latest laravel version${NC}"

git clone https://github.com/laravel/laravel.git "./$PROJECT_NAME"
rm -rf "./$PROJECT_NAME/.github"
rm -rf "./$PROJECT_NAME/.git"

cp "./$PROJECT_NAME/.env.example" "./$PROJECT_NAME/.env"


# Make project directory
echo -e "\n${GREEN}Generating configuration...${NC}"
mkdir -p "$PROJECT_NAME/docker/nginx" "$PROJECT_NAME/docker/php" "$PROJECT_NAME/docker/db"

make_file "docker-compose.base.yml" "docker-compose.yml"
make_file "nginx.conf" "docker/nginx/nginx.conf"
make_file "php.Dockerfile" "docker/php/Dockerfile"

if [ "$DB_CHOICE" = "1" ]; then
    fill_compose_file "mysql.yml"
elif [ "$DB_CHOICE" = "2" ]; then
    fill_compose_file "postgres.yml"
elif [ "$DB_CHOICE" = "3" ]; then
    fill_compose_file "postgres.yml"
fi


if [ "$REDIS" = "y" ]; then
    fill_compose_file "redis.yml"
fi


cat >> "$PROJECT_NAME/docker-compose.yml" << 'EOF'

networks:
  laravel:
    driver: bridge

volumes:
EOF

# Add volumes
if [[ "$DB_CHOICE" = "1" || "$DB_CHOISE" = "3" ]]; then
    echo "  mysql_data:" >> "$PROJECT_NAME/docker-compose.yml"
fi
[ "$DB_CHOICE" = "2" ] && echo "  postgres_data:" >> "$PROJECT_NAME/docker-compose.yml"
[ "$REDIS" = "y" ] && echo "  redis_data:" >> "$PROJECT_NAME/docker-compose.yml"

echo -e "\n${GREEN}✓ Setup complete!${NC}"
echo -e "${BLUE}\nNext steps:"
echo -e "  cd $PROJECT_NAME"
echo -e "  docker-compose run --rm php composer create-project laravel/laravel ."
echo -e "  docker-compose up -d${NC}"
