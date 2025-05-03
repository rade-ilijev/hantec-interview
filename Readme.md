# WordPress REST API Project

This project sets up a WordPress with Vue 3 frontend environment a custom REST API plugin using Docker.

## Prerequisites

- Docker
- Docker Compose
- Git

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/rade-ilijev/hantec-interview.git
cd hantec-interview
```

2. Start the containers:
```bash
docker-compose up -d
```

3. Run the setup script:
```bash
docker-compose exec wordpress bash /var/www/html/setup-wordpress.sh
```

4. Access WordPress:
- WordPress Site: http://localhost:8000
- WordPress Admin: http://localhost:8000/wp-admin
- phpMyAdmin: http://localhost:8080

Default admin credentials:
- Username: admin
- Password: admin123

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

3. Create Post
```
POST http://localhost:8000/wp-json/custom/v1/posts
Content-Type: application/json

{
    "title": "Post Title",
    "content": "Post Content",
    "status": "publish"
}
```

4. Update Post
```
PUT http://localhost:8000/wp-json/custom/v1/posts/{id}
Content-Type: application/json

{
    "title": "Updated Title",
    "content": "Updated Content"
}
```

5. Delete Post
```
DELETE http://localhost:8000/wp-json/custom/v1/posts/{id}
```

6. Login
```
POST http://localhost:8000/wp-json/custom/v1/login
Content-Type: application/json

{
    "username": "admin",
    "password": "your_password"
}
```

## Testing the API

You can test the API endpoints using tools like curl, Postman, or any HTTP client. Here's an example using curl:

```bash
# Get all posts
curl http://localhost:8000/wp-json/custom/v1/posts

# Create a new post
curl -X POST http://localhost:8000/wp-json/custom/v1/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Post","content":"This is a test post","status":"publish"}'

# Login
curl -X POST http://localhost:8000/wp-json/custom/v1/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```
