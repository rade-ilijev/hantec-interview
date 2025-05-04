# WordPress REST API Project

This project sets up a WordPress environment with a Vue 3 frontend and a custom REST API plugin using Docker.

## Prerequisites

- Docker
- Docker Compose
- Git
- PowerShell (for Windows users)

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/rade-ilijev/hantec-interview.git
cd hantec-interview
```

2. Run the setup script:

### Windows Users
```powershell
.\win_setup.ps1
```
The script will:
- Check if Docker containers are running
- Start containers if needed
- Install WordPress if not installed
- Set up the custom API plugin
- Create test posts

### Linux/Mac Users
```bash
# Start the containers
docker-compose up -d

# Wait for containers to be ready
docker-compose exec wordpress bash /var/www/html/setup-wordpress.sh
```

## Accessing the Services

- WordPress Site: http://localhost:8000
- WordPress Admin: http://localhost:8000/wp-admin
- phpMyAdmin: http://localhost:8080

### Default Credentials

**WordPress Admin:**
- Username: admin
- Password: admin123

**Editor User:**
- Username: rade
- Password: rade123

## Project Structure

```
.
├── backend/
│   └── wp-content/
│       └── plugins/
│           └── custom-api/     # Custom REST API plugin
├── frontend/                   # Vue 3 frontend application
├── docker-compose.yml         # Docker configuration
├── setup-wordpress.sh         # WordPress setup script
└── win_setup.ps1             # Windows setup script
```

## REST API Endpoints

The custom API plugin provides the following endpoints:

1. Get Posts
```
GET http://localhost:8000/wp-json/custom/v1/posts
```

2. Get Single Post
```
GET http://localhost:8000/wp-json/custom/v1/posts/{id}
```

3. Delete Post
```
DELETE http://localhost:8000/wp-json/custom/v1/posts/{id}
```

4. Login
```
POST http://localhost:8000/wp-json/custom/v1/login
Content-Type: application/json

{
    "username": "admin",
    "password": "admin123"
}
```

To work on the frontend:
1. Navigate to the frontend directory
2. Run `npm install`
3. Run `npm run dev` for development
4. Run `npm run build` for production
