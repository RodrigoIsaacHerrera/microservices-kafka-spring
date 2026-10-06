# Runbook: start the project

This repository contains three Spring Boot services and their local databases:

| Service | Local port | Database | Database port |
| --- | ---: | --- | ---: |
| `storage-services` | 8084 | PostgreSQL (`ms_storage`) | 5432 |
| `orders-services` | 8071 | MySQL (`ms_orders`) | 3216 |
| `items-services` | 8074 | PostgreSQL (`ms_items`) | 5433 |

## Prerequisites

- JDK 25, as configured in the root Maven project.
- Docker Desktop (or another Docker Engine with the Compose plugin).
- PowerShell on Windows. The Maven Wrapper is included under each service, so a separate Maven installation is not required.

## Start the databases

From the repository root, start the database containers:

```powershell
docker compose up -d db-storage db-orders db-items
docker compose ps
```

Wait until all three databases report `healthy` before starting the services. If one is not healthy, inspect its logs, for example:

```powershell
docker compose logs db-storage
```

The application datasource defaults use these published host ports. The Compose credentials are for local development only; do not reuse them outside a local environment.

## Build and test all services

From the repository root:

```powershell
.\items-services\mvnw.cmd -f pom.xml clean verify
```

The root POM aggregates `storage-services`, `orders-services`, and `items-services`.

## Run the services

Run each command in a separate PowerShell terminal from the repository root. Start the database containers first.

```powershell
.\storage-services\mvnw.cmd -f storage-services\pom.xml spring-boot:run
```

```powershell
.\orders-services\mvnw.cmd -f orders-services\pom.xml spring-boot:run
```

```powershell
.\items-services\mvnw.cmd -f items-services\pom.xml spring-boot:run
```

Wait for each service's Spring Boot `Started ...` message in its terminal. Stop an individual service with **Ctrl+C**.

## Verify the items service

The items service currently exposes `GET` and `POST` at `/api/items/v1`. For example, from PowerShell:

```powershell
Invoke-RestMethod http://localhost:8074/api/items/v1
```

Create an item:

```powershell
$item = @{
    sku = "demo-001"
    name = "Demo item"
    description = "Local runbook smoke test"
    price = 9.99
    status = $true
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri http://localhost:8074/api/items/v1 `
    -ContentType "application/json" -Body $item
```

The create endpoint returns HTTP `201` with no response body. Run the `GET` request again to confirm the item was stored. The orders and storage services do not currently define HTTP endpoints; confirm those services by their startup logs.

## Stop the project

Stop the service processes with **Ctrl+C** in their terminals, then stop the databases:

```powershell
docker compose stop
```

Use `docker compose down` only when you intend to remove the database containers. The Compose file does not define persistent volumes, so removing those containers also removes their local database data.

## Troubleshooting

- **A port is already in use:** Check the ports in the table above and stop the conflicting process, or change the service port / datasource URL for your local setup.
- **A service cannot connect to its database:** Check `docker compose ps` and the relevant database logs. By default, the applications connect to `localhost` using the Compose-published ports.
- **Use a different database URL:** The datasource URL can be overridden for a service with `SPRING_DATASOURCE_URL` in the environment where its Maven command is run.
- **Build fails before compilation:** Confirm that JDK 25 is installed and active (`java -version`), then retry the Maven Wrapper command.
- **Looking for Kafka:** Despite the repository name, the current Compose configuration starts only PostgreSQL and MySQL databases; it does not start a Kafka broker.
