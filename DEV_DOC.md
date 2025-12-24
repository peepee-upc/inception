# Developer Documentation

## TL;DR

Prerequisites: Docker + Docker Compose | Configure `srcs/.env` | Build with `make` | Data persists in `/home/<user>/data` and `/home/<user>/mysql`

---

## Environment Setup from Scratch

### Prerequisites

| Requirement        | Version       | Installation                              |
|--------------------|---------------|-------------------------------------------|
| Docker Engine      | 20.x+         | `sudo apt install docker.io`              |
| Docker Compose     | v2.x+         | Included with Docker Engine               |
| Linux OS           | Debian/Ubuntu | Recommended host OS                       |
| sudo privileges    | Required      | For data directory creation               |

### Verify Installation

```bash
docker --version
docker compose version
```

### Add User to Docker Group (Optional)

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

---

## Configuration Files

### Project Structure

```
inception/
├── Makefile                          # Build and management commands
├── README.md                         # Project overview
├── USER_DOC.md                       # End-user documentation
├── DEV_DOC.md                        # This file
└── srcs/
    ├── .env                          # Environment variables (credentials)
    ├── docker-compose.yml            # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image build
        │   └── tools/
        │       └── db_setup.sh       # Database initialization script
        ├── nginx/
        │   ├── Dockerfile            # NGINX image build
        │   ├── conf/
        │   │   └── nginx.conf        # NGINX server configuration
        │   └── tools/
        │       └── generate_cert.sh  # SSL certificate generation
        └── wordpress/
            ├── Dockerfile            # WordPress image build
            └── tools/
                └── setup.sh          # WordPress installation script
```

### Environment Variables (.env)

Location: `srcs/.env`

```dotenv
# Domain and site settings
DOMAINE_NAME=aait-bou.42.fr
SITE_TITLE=InceptionSite

# WordPress admin credentials
ADMIN_USER=aait-bou
ADMIN_PASSWORD=aait-boupass
ADMIN_EMAIL=ali@test.com

# Database credentials
SQL_USER=wpuser
SQL_PASSWORD=userpass
SQL_DATABASE=wordpress
SQL_ROOT_PASSWORD=rootpass
```

**To modify:**
1. Edit the `.env` file with desired values
2. Run `make fclean && make` for changes to take effect

### Creating Data Directories

Before first run, create persistent storage directories:

```bash
mkdir -p /home/$(whoami)/data /home/$(whoami)/mysql
```

> **Note:** The `docker-compose.yml` expects these paths. If you use a different username, update the `device` paths in the volumes section.

### Host File Configuration

Add the domain to your hosts file:

```bash
echo "127.0.0.1 aait-bou.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and Launching

### Using the Makefile

| Command       | Description                                           |
|---------------|-------------------------------------------------------|
| `make`        | Build images and start all containers (detached)      |
| `make down`   | Stop containers, remove images and volumes            |
| `make clean`  | Run `down` + prune Docker system                      |
| `make fclean` | Run `clean` + delete host data directories            |
| `make re`     | Full rebuild: `fclean` followed by `all`              |

### Makefile Breakdown

```makefile
all:
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

clean: down
	docker system prune -a -f

fclean: clean
	sudo rm -rf /home/$(USER)/data/* /home/$(USER)/mysql/*

re: fclean all
```

### Direct Docker Compose Commands

From the project root:

```bash
# Build and start (foreground with logs)
docker compose -f srcs/docker-compose.yml up --build

# Build and start (detached)
docker compose -f srcs/docker-compose.yml up -d --build

# Stop without removing
docker compose -f srcs/docker-compose.yml stop

# Stop and remove containers only
docker compose -f srcs/docker-compose.yml down

# Rebuild a specific service
docker compose -f srcs/docker-compose.yml up -d --build nginx
```

---

## Container Management Commands

### View Running Containers

```bash
docker ps
```

### View All Containers (including stopped)

```bash
docker ps -a
```

### View Container Logs

```bash
# All logs
docker logs <container_name>

# Follow logs in real-time
docker logs -f <container_name>

# Last 50 lines
docker logs --tail 50 <container_name>
```

Examples:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Execute Commands Inside Containers

```bash
# Interactive shell
docker exec -it <container_name> /bin/bash

# Run a single command
docker exec <container_name> <command>
```

Examples:
```bash
# Access MariaDB CLI
docker exec -it mariadb mariadb -u wpuser -puserpass wordpress

# Check WordPress version
docker exec wordpress wp core version --allow-root

# Check NGINX configuration
docker exec nginx nginx -t
```

### Restart a Service

```bash
docker restart <container_name>
```

### Inspect Container Details

```bash
docker inspect <container_name>
```

---

## Volume Management

### List Volumes

```bash
docker volume ls
```

Expected volumes:
- `srcs_wp_data` — WordPress files
- `srcs_mariadb` — MariaDB database files

### Inspect Volume

```bash
docker volume inspect srcs_wp_data
docker volume inspect srcs_mariadb
```

### Volume Configuration (docker-compose.yml)

```yaml
volumes:
  wp_data:
    driver_opts:
      type: none
      o: bind
      device: '/home/aait-bou/data'
  mariadb:
    driver_opts:
      type: none
      o: bind
      device: '/home/aait-bou/mysql'
```

This configuration uses bind mounts through Docker volumes, allowing:
- Docker volume semantics (named volumes)
- Data stored in specific host directories
- Easy backup and inspection of raw files

### Remove Volumes

```bash
# Remove all project volumes
docker compose -f srcs/docker-compose.yml down --volumes

# Remove specific volume
docker volume rm srcs_wp_data
docker volume rm srcs_mariadb
```

---

## Data Storage and Persistence

### Storage Locations

| Data Type          | Container Path       | Host Path                    |
|--------------------|---------------------|------------------------------|
| WordPress files    | `/var/www/html`     | `/home/aait-bou/data/`       |
| MariaDB databases  | `/var/lib/mysql`    | `/home/aait-bou/mysql/`      |

### What Persists

✅ **Persists across container restarts:**
- WordPress core files, themes, plugins
- Uploaded media files
- Database tables and records
- WordPress configuration (`wp-config.php`)

### What Gets Regenerated

🔄 **Regenerated on container start:**
- SSL certificates (generated fresh each time)
- PHP-FPM runtime files
- MariaDB socket and PID files

### Backup Data

```bash
# Backup WordPress files
tar -czvf wordpress-backup.tar.gz /home/aait-bou/data/

# Backup database
docker exec mariadb mysqldump -u wpuser -puserpass wordpress > db-backup.sql

# Backup both
tar -czvf full-backup.tar.gz /home/aait-bou/data/ /home/aait-bou/mysql/
```

### Restore Data

```bash
# Restore WordPress files
tar -xzvf wordpress-backup.tar.gz -C /

# Restore database
docker exec -i mariadb mariadb -u wpuser -puserpass wordpress < db-backup.sql
```

---

## Network Configuration

### Network Details

```bash
docker network ls
docker network inspect srcs_inception
```

### Service Communication

| Service   | Internal Hostname | Port  | Access                    |
|-----------|-------------------|-------|---------------------------|
| nginx     | `nginx`           | 443   | External (published)      |
| wordpress | `wordpress`       | 9000  | Internal only (FastCGI)   |
| mariadb   | `mariadb`         | 3306  | Internal only             |

Services communicate using container names as hostnames:
- WordPress connects to MariaDB via `mariadb:3306`
- NGINX forwards PHP requests to `wordpress:9000`

---

## Debugging Tips

### Check Build Logs

```bash
docker compose -f srcs/docker-compose.yml build --no-cache 2>&1 | tee build.log
```

### Common Issues

| Issue                     | Debug Command                                    | Solution                    |
|---------------------------|--------------------------------------------------|-----------------------------|
| Container won't start     | `docker logs <container>`                        | Check startup script errors |
| Database connection fails | `docker exec wordpress ping mariadb`             | Wait for MariaDB init       |
| 502 Bad Gateway           | `docker logs nginx`                              | Ensure wordpress is running |
| Permission denied         | `ls -la /home/$USER/data`                        | Fix directory permissions   |

### Verify Service Health

```bash
# Check all services are running
docker compose -f srcs/docker-compose.yml ps

# Test MariaDB
docker exec mariadb mariadb-admin ping -u root

# Test PHP-FPM
docker exec wordpress ps aux | grep php-fpm

# Test NGINX config
docker exec nginx nginx -t
```

---

## Extending the Project

### Adding a New Service

1. Create directory: `srcs/requirements/<service>/`
2. Add `Dockerfile` and any config/scripts
3. Add service definition to `docker-compose.yml`
4. Add any new environment variables to `.env`

### Modifying Existing Services

1. Edit the relevant `Dockerfile` or config files
2. Rebuild: `docker compose -f srcs/docker-compose.yml up -d --build <service>`

### Custom NGINX Configuration

Edit `srcs/requirements/nginx/conf/nginx.conf` and rebuild:
```bash
docker compose -f srcs/docker-compose.yml up -d --build nginx
```
