# User Documentation

## TL;DR

Access WordPress at **https://aait-bou.42.fr** | Admin panel at **/wp-admin** | Start with `make` | Stop with `make down`

---

## Services Overview

This infrastructure provides a complete WordPress website stack:

| Service   | Description                                    | Port   |
|-----------|------------------------------------------------|--------|
| **NGINX** | HTTPS web server (reverse proxy with TLSv1.3) | 443    |
| **WordPress** | Content Management System (CMS)            | 9000 (internal) |
| **MariaDB** | Database server storing WordPress data       | 3306 (internal) |

All services run as Docker containers and communicate through an internal network.

---

## Starting the Project

1. **Open a terminal** in the project root directory (`inception/`).

2. **Start all services:**
   ```bash
   make
   ```
   This command builds the Docker images (if needed) and starts all containers in the background.

3. **Wait for initialization** — First run may take a few minutes while:
   - Docker images are built
   - WordPress is downloaded and configured
   - Database is initialized

---

## Stopping the Project

| Command       | Effect                                              |
|---------------|-----------------------------------------------------|
| `make down`   | Stop all containers and remove them (data persists) |
| `make clean`  | Stop containers and clean up Docker system          |
| `make fclean` | Stop containers and **delete all data**             |

> ⚠️ **Warning:** `make fclean` will permanently delete your WordPress content and database!

---

## Accessing the Website

### Main Website

1. Open your browser
2. Navigate to: **https://aait-bou.42.fr**
3. Accept the self-signed certificate warning:
   - Chrome: Click "Advanced" → "Proceed to aait-bou.42.fr"
   - Firefox: Click "Advanced" → "Accept the Risk and Continue"

> **Note:** If the domain doesn't resolve, ensure this line is in `/etc/hosts`:
> ```
> 127.0.0.1 aait-bou.42.fr
> ```

### WordPress Admin Panel

1. Navigate to: **https://aait-bou.42.fr/wp-admin**
2. Log in with administrator credentials (see Credentials section below)

From the admin panel, you can:
- Create and edit posts/pages
- Manage users
- Install themes and plugins
- Configure site settings

---

## Credentials

### Default Administrator Account

| Field     | Value                |
|-----------|----------------------|
| Username  | `aait-bou`           |
| Password  | `aait-boupass`       |
| Email     | `ali@test.com`       |
| Role      | Administrator        |

### Default Author Account

| Field     | Value                     |
|-----------|---------------------------|
| Username  | `wpuser`                  |
| Password  | `userpass`                |
| Email     | `wpuser@aait-bou.42.fr`   |
| Role      | Author                    |

### Database Credentials

| Field          | Value       |
|----------------|-------------|
| Database Name  | `wordpress` |
| Username       | `wpuser`    |
| Password       | `userpass`  |

### Credential Location

All credentials are stored in: `srcs/.env`

To change credentials:
1. Stop the project: `make down`
2. Edit `srcs/.env` with new values
3. Clean data: `make fclean`
4. Restart: `make`

> ⚠️ Changing credentials requires a full rebuild to take effect.

---

## Checking Service Status

### Quick Status Check

```bash
docker ps
```

Expected output shows 3 running containers:
```
CONTAINER ID   IMAGE           STATUS         PORTS                  NAMES
xxx            srcs-nginx      Up X minutes   0.0.0.0:443->443/tcp   nginx
xxx            srcs-wordpress  Up X minutes   9000/tcp               wordpress
xxx            srcs-mariadb    Up X minutes   3306/tcp               mariadb
```

### Detailed Health Checks

**Check NGINX:**
```bash
docker logs nginx
```
Should show: "start worker process"

**Check WordPress:**
```bash
docker logs wordpress
```
Should show: "WordPress started on port 9000"

**Check MariaDB:**
```bash
docker logs mariadb
```
Should show: "Database and user ready"

### Test Database Connection

```bash
docker exec mariadb mariadb -u wpuser -puserpass -e "SHOW DATABASES;"
```
Should display the `wordpress` database.

### Test WordPress PHP

```bash
docker exec wordpress wp core version --allow-root
```
Should display the WordPress version number.

---

## Troubleshooting

| Issue                        | Solution                                        |
|------------------------------|------------------------------------------------|
| "Site can't be reached"      | Check if containers are running with `docker ps` |
| Certificate warning          | Normal for self-signed certs — accept and continue |
| "Error establishing database"| Wait a minute and refresh; MariaDB may still be starting |
| Domain not resolving         | Add `127.0.0.1 aait-bou.42.fr` to `/etc/hosts` |
| Containers won't start       | Run `make fclean && make` for a clean rebuild  |

---

## Data Locations

| Data Type       | Location on Host            |
|-----------------|----------------------------|
| WordPress files | `/home/aait-bou/data/`     |
| MariaDB data    | `/home/aait-bou/mysql/`    |

These directories persist even when containers are stopped or removed (unless using `make fclean`).
