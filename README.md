# Simple Laravel Env

Minimal setup generator for a Laravel Docker environment. The script fetches
Laravel, creates a `docker-compose.yml`, and adds Nginx/PHP configs based on
your chosen database and optional Redis.

## System Requirements

- `bash`
- `curl`
- `git`
- Docker Engine
- Docker Compose (either `docker compose` or `docker-compose`)

## Install and Run via `setup.sh` (direct)

Run the script directly (it will download stubs from the repository if they
are not present locally):

```bash
curl -sL https://raw.githubusercontent.com/kul1bit/simple-laravel-env/refs/heads/main/setup.sh | bash
```

You will be prompted for:
- project name
- database choice (MySQL/PostgreSQL/MariaDB/None)
- whether to include Redis

After the script finishes:

```bash
cd my-project
# Update .env values for your project, and if needed sync them in docker-compose.yml
docker compose build
docker compose up -d
```

## Install by Cloning the Project

Clone the repository and run the script from the project root to use local
stubs:

```bash
git clone https://github.com/kul1bit/simple-laravel-env.git
cd simple-laravel-env
bash setup.sh
```

Then follow the same next steps shown by the script:

```bash
cd my-project
# Update .env values for your project, and if needed sync them in docker-compose.yml
docker compose build
docker compose up -d
```