*This project has been created as part of the 42 curriculum by aait-bou.*

# Inception

## TL;DR

A Docker-based infrastructure deploying WordPress with MariaDB and NGINX using custom Dockerfiles, TLSv1.3, Docker networks, and named volumes for data persistence.

---

## Description

**Inception** is a system administration project that sets up a small infrastructure composed of multiple Docker containers running different services:

- **NGINX** — Reverse proxy with TLSv1.3 encryption
- **WordPress** — PHP-based CMS with php-fpm
- **MariaDB** — Relational database for WordPress data

All services run inside custom-built Docker containers based on **Debian Bullseye**, orchestrated via **Docker Compose**, and communicate through an internal Docker bridge network.

### Goal

The goal is to learn containerization principles, multi-service orchestration, and secure deployment practices by building everything from scratch without using pre-made Docker images (except the base OS).

---

## Project Description

### Use of Docker

This project uses Docker to containerize each service in isolated environments. Each container is built from a custom `Dockerfile` based on Debian Bullseye:

| Service   | Base Image        | Purpose                                |
|-----------|-------------------|----------------------------------------|
| nginx     | debian:bullseye   | HTTPS reverse proxy (TLSv1.3)          |
| wordpress | debian:bullseye   | WordPress CMS with PHP-FPM on port 9000|
| mariadb   | debian:bullseye   | MySQL-compatible database server       |

### Sources Included

- `srcs/docker-compose.yml` — Orchestration file defining all services
- `srcs/requirements/nginx/` — NGINX Dockerfile, config, and SSL script
- `srcs/requirements/wordpress/` — WordPress Dockerfile and setup script
- `srcs/requirements/mariadb/` — MariaDB Dockerfile and database init script
- `srcs/.env` — Environment variables for configuration
- `Makefile` — Build and management commands

### Main Design Choices

1. **Custom Dockerfiles** — No pre-built CMS images; everything is built from Debian base
2. **TLSv1.3 only** — Self-signed certificates generated at container startup
3. **PHP-FPM** — WordPress uses php-fpm listening on port 9000, connected via FastCGI
4. **WP-CLI** — WordPress installation and user creation automated via CLI
5. **Bridge Network** — All containers communicate through a Docker bridge network named `inception`

---

## Technical Comparisons

### Virtual Machines vs Docker

| Aspect             | Virtual Machine                              | Docker Container                           |
|--------------------|----------------------------------------------|--------------------------------------------|
| Isolation          | Full OS-level (hypervisor)                   | Process-level (shared kernel)              |
| Resource Usage     | Heavy (each VM has its own OS)               | Lightweight (shares host kernel)           |
| Startup Time       | Minutes                                      | Seconds                                    |
| Portability        | Requires hypervisor                          | Runs anywhere Docker is installed          |
| Use Case           | Full OS emulation, legacy systems            | Microservices, CI/CD, rapid deployment     |

**Project Choice:** Docker is used for its lightweight, fast, and portable nature ideal for service isolation.

### Secrets vs Environment Variables

| Aspect             | Environment Variables                        | Docker Secrets                             |
|--------------------|----------------------------------------------|--------------------------------------------|
| Storage            | Plaintext in `.env` or shell                 | Encrypted, stored in tmpfs                 |
| Security           | Visible via `docker inspect` or `env`        | Only accessible inside container           |
| Swarm Dependency   | No                                           | Requires Docker Swarm mode                 |
| Ease of Use        | Simple, widely supported                     | More complex setup                         |

**Project Choice:** Environment variables via `.env` file for simplicity. For production, Docker Secrets with Swarm would be recommended.

### Docker Network vs Host Network

| Aspect             | Docker Network (Bridge)                      | Host Network                               |
|--------------------|----------------------------------------------|--------------------------------------------|
| Isolation          | Containers isolated with internal DNS        | Container shares host network stack        |
| Port Mapping       | Explicit port publishing required            | Direct port access                         |
| Security           | Better isolation between services            | Less isolation                             |
| Service Discovery  | Container names resolve to IPs               | No built-in discovery                      |

**Project Choice:** Bridge network (`inception`) for isolation and service name resolution (e.g., `mariadb:3306`).

### Docker Volumes vs Bind Mounts

| Aspect             | Docker Volumes                               | Bind Mounts                                |
|--------------------|----------------------------------------------|--------------------------------------------|
| Management         | Managed by Docker                            | Managed by user/host                       |
| Portability        | Works across platforms                       | Depends on host path structure             |
| Performance        | Optimized for Docker                         | Native filesystem performance              |
| Use Case           | Database storage, persistent data            | Development, config files                  |

**Project Choice:** Named volumes with bind mount driver options pointing to `/home/aait-bou/data` and `/home/aait-bou/mysql` for WordPress and MariaDB data persistence.

---

## Instructions

### Prerequisites

- Docker Engine (20.x or later)
- Docker Compose (v2.x or later)
- Linux host (Debian/Ubuntu recommended)
- Sudo privileges

### Installation & Execution

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Create data directories:**
   ```bash
   mkdir -p /home/$(whoami)/data /home/$(whoami)/mysql
   ```

3. **Configure environment (optional):**
   Edit `srcs/.env` to customize credentials and domain name.

4. **Add domain to hosts file:**
   ```bash
   echo "127.0.0.1 aait-bou.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Build and start the stack:**
   ```bash
   make
   ```

6. **Access the website:**
   Open https://aait-bou.42.fr in your browser (accept the self-signed certificate warning).

### Makefile Commands

| Command      | Description                                      |
|--------------|--------------------------------------------------|
| `make`       | Build and start all containers                   |
| `make down`  | Stop and remove containers, images, and volumes  |
| `make clean` | Run `down` and prune Docker system               |
| `make fclean`| Run `clean` and delete persistent data folders   |
| `make re`    | Full rebuild (`fclean` + `all`)                  |

---

## Resources

### Documentation & References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [OpenSSL Manual](https://www.openssl.org/docs/)
- [42 Inception Subject](https://projects.intra.42.fr/)

### AI Usage

AI tools (GitHub Copilot/ChatGPT) were used to assist with:

- **Syntax validation** — Dockerfile and docker-compose.yml syntax review
- **Troubleshooting** — Debugging container networking and volume mounting issues

All code logic, configuration, and architectural decisions were made by the project author.

---

## License

This project is part of the 42 school curriculum and is for educational purposes only.
