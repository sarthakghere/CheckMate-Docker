# CheckMate-Docker

This repository contains the Dockerized version of the CheckMate project.

## Prerequisites

Before you begin, ensure you have the following installed:

*   [Docker](https://www.docker.com/get-started)
*   [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/sarthakghere/CheckMate-Docker.git
    cd CheckMate-Docker
    ```

2.  **Configure the environment:**

    Create a `.env` file from the sample file:

    ```bash
    cp .env.sample .env
    ```

    Open the `.env` file and update the following variables:

    *   `SECRET_KEY`: A strong, unique secret key for your Django application. You can generate one using the following commands in a Python shell:
        ```python
        from django.core.management.utils import get_random_secret_key
        print(get_random_secret_key())
        ```
    *   `ALLOWED_HOSTS`: A comma-separated list of hosts that can serve the site. For example: `localhost,127.0.0.1,yourdomain.com`.
    *   `DB_USER`: The username for the MySQL database.
    *   `DB_PASSWORD`: The password for the MySQL database.
    *   `EMAIL_HOST_USER`: Your Gmail address for sending emails.
    *   `EMAIL_HOST_PASSWORD`: Your Gmail app password.

3.  **Download and Load the Docker images:**

    Download the `checkmate-amd64.tar` or `checkmate-arm64.tar` file from the [GitHub releases page](https://github.com/sarthakghere/CheckMate-Docker/releases) of this repository.

    Then, load the appropriate image for your system's architecture:

    *   **For amd64 systems:**
        ```bash
        docker load < checkmate-amd64.tar
        ```

    *   **For arm64 systems:**
        ```bash
        docker load < checkmate-arm64.tar
        ```

4.  **Build and run the application:**

    Choose the appropriate Docker Compose file for your system's architecture:

    *   **For amd64 systems:**

        ```bash
        docker-compose -f docker-compose-amd64.yaml up --build
        ```

    *   **For arm64 systems:**

        ```bash
        docker-compose -f docker-compose-arm64.yaml up --build
        ```

    The application will be available at `http://localhost`.

5.  **Initial Django Setup**
    After starting the application, you'll need to run the following commands in a separate terminal to initialize the Django application.

    *   **Apply migrations:**
        ```bash
        docker-compose -f <your-compose-file>.yaml exec django python manage.py migrate
        ```
        Replace `<your-compose-file>.yaml` with `docker-compose-amd64.yaml` or `docker-compose-arm64.yaml` depending on your system.

    *   **Create a superuser:**
        ```bash
        docker-compose -f <your-compose-file>.yaml exec django python manage.py createsuperuser
        ```
        You will be prompted to create a username and password for the Django admin interface.

    *   **Collect static files:**
        ```bash
        docker-compose -f <your-compose-file>.yaml exec django python manage.py collectstatic --noinput
        ```

## Application Usage

### Admin Panel

1.  **Access the admin panel:**

    Navigate to `http://localhost/admin` and log in with the superuser credentials you created during the initial setup.

2.  **Add Documents:**

    *   In the admin panel, locate the "Documents" table and click on "Add".
    *   Fill in the required fields and save the document.

3.  **Add Courses:**

    *   In the admin panel, locate the "Courses" table and click on "Add".
    *   Fill in the required fields.

4.  **Map Documents to Courses:**

    *   While adding or editing a course, in the "Required Documents" section, select the documents that are required for that course.

### Adding Students in Bulk

You can add students in bulk by uploading an Excel file.

1.  In the admin panel, go to the "Students" section and click on "Add in Bulk".
2.  Upload an Excel file with the student data. Please follow the defined format for the Excel file.

    **Note:** The specific format for the Excel file is not documented here. Please refer to the application's documentation or source code for the exact format.

### Checking Container Status

To check the status of all running containers, use the following command:

```bash
docker-compose -f <your-compose-file>.yaml ps
```

Replace `<your-compose-file>.yaml` with `docker-compose-amd64.yaml` or `docker-compose-arm64.yaml` depending on your system.

## Services

The following services are defined in the Docker Compose files:

*   **`django`**: The Django web application.
*   **`nginx`**: The nginx web server, which acts as a reverse proxy for the Django application.
*   **`db`**: The MySQL database.
*   **`redis`**: The Redis server, used as a message broker for Celery.
*   **`celery`**: The Celery worker, which runs background tasks.

## Database

The MySQL database data is stored in a Docker volume named `db_data`.

### Backing up the database

A batch script is provided to back up the database on Windows. To use it, run the following command:

```bash
mysql_backup.bat
```

This will create a backup file in `C:\backups\` with a filename like `mydb-YYYY-MM-DD.sql`.

**Note:** You may need to create the `C:\backups` directory if it doesn't exist. The script uses the container name `db` as defined in the Docker Compose files.
