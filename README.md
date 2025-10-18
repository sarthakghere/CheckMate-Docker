# CheckMate-Docker

This repository contains the **Dockerized version of the CheckMate project**, a Django-based Student Support Cell system.
The setup now includes automated installation and backup scripts for easy deployment and database safety.

---

## 🧩 Prerequisites

Before you begin, ensure you have the following installed on your system:

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/install/)
* (Windows only) Command Prompt or PowerShell to run `.bat` scripts

---

## ⚙️ Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/sarthakghere/CheckMate-Docker.git
cd CheckMate-Docker
```

---

### 2. Configure Environment Variables

Create a `.env` file from the sample:

```bash
cp .env.sample .env
```

Open `.env` and update the following values as per your setup:

| Variable                                 | Description                                                                                                                           |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `SECRET_KEY`                             | Django secret key (generate one via `from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())`) |
| `ALLOWED_HOSTS`                          | Comma-separated list of allowed hosts (e.g. `localhost,127.0.0.1,yourdomain.com`)                                                     |
| `DB_USER`, `DB_PASSWORD`                 | MySQL credentials                                                                                                                     |
| `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD` | Gmail and app password for sending emails                                                                                             |

---

## 🚀 Automated Installation (Recommended)

To automatically fetch Docker images, start containers, apply migrations, and collect static files — run:

```bash
setup.bat
```

This script performs the following:

1. Pulls the latest Docker images for all services.
2. Stops and removes any existing containers.
3. Starts the containers in detached mode.
4. Runs Django `migrate` and `collectstatic` commands.
5. Displays available migrations for verification.

After completion, your application will be running at:

👉 **[http://localhost](http://localhost)**

---

## 🐋 Docker Compose Configuration

Your setup uses prebuilt Docker images for production:

```yaml
services:
  django:
    image: sarthakghere/checkmate-django:latest
    env_file:
      - .env
    volumes:
      - ./mediafiles:/app/mediafiles
      - ./staticfiles:/app/staticfiles
    depends_on:
      - db

  nginx:
    image: sarthakghere/checkmate-nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./staticfiles:/app/staticfiles:ro
      - ./mediafiles:/app/mediafiles:ro
    depends_on:
      - django

  db:
    image: mysql:8
    restart: always
    environment:
      MYSQL_DATABASE: $DB_NAME
      MYSQL_ROOT_PASSWORD: $DB_PASSWORD
    volumes:
      - db_data:/var/lib/mysql

  redis:
    image: redis:7
    container_name: redis
    restart: always
    ports:
      - "6379:6379"
  
  celery:
    image: sarthakghere/checkmate-django:latest
    container_name: celery
    command: celery -A CheckMate worker -l info
    env_file:
      - .env
    depends_on:
      - django
      - redis

  celery-beat:
    image: sarthakghere/checkmate-django:latest
    container_name: celery-beat
    command: celery -A CheckMate beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    env_file:
      - .env
    depends_on:
      - django
      - redis

volumes:
  db_data:
```

---

## 🧠 First-Time Django Setup

After running `setup.bat` and confirming the containers are up, complete the following inside the Django container:

1. **Create Superuser**

   ```bash
   docker exec -it checkmate-docker-django-1 python manage.py createsuperuser
   ```

   Follow the prompts to set email and password.

2. **Access the Admin Panel**
   Visit **[http://localhost/admin](http://localhost/admin)** and log in using the credentials created above.

3. **Add Documents**

   * Go to **Documents** in the admin panel.
   * Click **Add Document** and fill in the required fields.

4. **Add Courses**

   * Go to **Courses** and click **Add Course**.
   * Enter course details (name, code, etc.).

5. **Map Documents to Courses**

   * While adding or editing a course, use the **Required Documents** section to link necessary documents for that course.

Once this initial setup is done, your system is ready to handle student and certificate workflows.

---

## 💾 Database Backup

You can back up your MySQL volume using the provided script:

```bash
mysql_backup.bat
```

This script:

* Creates a compressed `.sql` backup of your MySQL Database.
* Saves it to `C:\CheckMate-Backups\` with a timestamped filename.

Example backup file:

```
C:\CheckMate-Backups\checkmate-%DATE%.sql
```

This ensures your data is safely stored regularly.

---

## 🔍 Checking Container Status

To verify that all containers are running:

```bash
docker-compose ps
```

You should see services like `django`, `nginx`, `db`, `redis`, `celery`, and `celery-beat` in the list.

---

## 🧹 Maintenance Commands

| Command                  | Description                                  |
| ------------------------ | -------------------------------------------- |
| `docker-compose logs -f` | View live logs of all services               |
| `docker-compose down`    | Stop and remove containers                   |
| `docker-compose up -d`   | Start containers in detached mode            |
| `docker system prune`    | Remove unused Docker data (use with caution) |

---

## 🏁 Done!

Your CheckMate Docker environment is now ready to use.
Visit **[http://localhost](http://localhost)** to start using the system.
