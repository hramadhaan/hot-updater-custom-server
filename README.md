# Elysia with Bun runtime

## Getting Started
To get started with this template, simply paste this command into your terminal:
```bash
bun create elysia ./elysia-example
```

## Development
To start the development server run:
```bash
bun run dev
```

Open http://localhost:3000/ with your browser to see the result.

## Using Docker Locally

### Build and run
```bash
docker compose -f docker-compose.dev.yml up --build
```

### Build and recreate container
```bash
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up --detach --force-recreate
```