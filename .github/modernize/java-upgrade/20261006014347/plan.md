# Upgrade Plan: microservices-kafka-spring (20261006014347)

- **Generated**: 2026-10-05 22:43:51 -03:00
- **HEAD Branch**: main
- **HEAD Commit ID**: N/A (not provided by version-control status)

## Available Tools

**JDKs**
- JDK 17: not available (baseline will be skipped)
- JDK 25: **<TO_BE_INSTALLED>** (required for all upgrade verification)

**Build Tools**
- Maven Wrapper: 3.9.16 (available in each module; use the wrapper against the reactor root POM)

## Guidelines

- Upgrade the Java runtime target to Java 25, the latest LTS.
- Repair database container configuration per service module and ensure application datasource URLs reach the matching Docker database.
- Run in auto-execution mode.

> Note: You can add any specific guidelines or constraints for the upgrade process here if needed, bullet points are preferred.

## Options

- Working branch: appmod/java-upgrade-20261006014347
- Run tests before and after the upgrade: true

## Upgrade Goals

- Java runtime: 25

## Technology Stack

| Technology/Dependency | Current | Min Compatible Version | Why Incompatible |
| --------------------- | ------- | ---------------------- | ---------------- |
| Java | 17 (all four POMs) | 25 | User requested |
| Spring Boot | 4.1.1 | 4.1.1 | No version change requested; retain current parent |
| Maven Wrapper | 3.9.16 | 3.9.16 | Already suitable; wrappers are in each service module |
| PostgreSQL (storage) | 17.6 | 17.6 | Correct database family; correct container port and datasource settings |
| MySQL (orders) | 8.0.34 | 8.0.34 | Correct database family; container listens on 3306 |
| PostgreSQL (items) | 15.2 | 15.2 | Correct database family; container listens on 5432 |

## Derived Upgrades

- Set the parent project's `java.version` to 25 and remove child overrides so all three services inherit one Java target.
- No Spring Boot, Maven, Kotlin, or dependency upgrades are required for the Java target.
- Correct Compose host-to-container mappings and configure module datasource defaults to use those host ports. Keep JDBC URLs overrideable for deployments that run the application in Docker, where the Compose service name and container port are used.
- Add database health checks so Docker Compose can report when each module's database is ready.

## Impact Analysis

### Dependency Changes

| File | Dependency | Current | Action | Target | Reason |
|------|-----------|---------|--------|--------|--------|
| `pom.xml` | `java.version` | 17 | upgrade | 25 | Requested Java LTS runtime |
| `storage-services/pom.xml` | `java.version` | 17 | remove | inherited 25 | Avoid child override conflicting with root target |
| `orders-services/pom.xml` | `java.version` | 17 | remove | inherited 25 | Avoid child override conflicting with root target |
| `items-services/pom.xml` | `java.version` | 17 | remove | inherited 25 | Avoid child override conflicting with root target |

### Source Code Changes

No Java source changes are expected.

### Configuration Changes

| File | Property/Setting | Current | Required Change | Reason |
|------|------------------|---------|-----------------|--------|
| `storage-services/pom.xml`, `orders-services/pom.xml`, `items-services/pom.xml` | parent `relativePath` | Empty (`<relativePath/>`) | Point to `../pom.xml` | Maven cannot resolve these reactor child parents because the root POM is not installed |
| `storage-services/src/main/resources/application.properties` | datasource URL | Misspelled PostgreSQL JDBC scheme; localhost:5432 | Correct JDBC URL, default to localhost:5432, allow environment override | Allow the service to connect to its PostgreSQL container from the host |
| `storage-services/src/main/resources/application.properties` | datasource username | `spring.datasource.user` | Use `spring.datasource.username` | Correct Spring Boot datasource property |
| `orders-services/src/main/resources/application.properties` | datasource URL | localhost:3206 | Default to localhost:3216 and allow environment override | Match the Compose published port |
| `orders-services/src/main/resources/application.properties` | datasource username | `spring.datasource.user` | Use `spring.datasource.username` | Correct Spring Boot datasource property |
| `items-services/src/main/resources/application.properties` | datasource URL | Docker-only `db-items:5432` | Default to localhost:5433 and allow environment override | Make host-run service use the published port; container deployments can override |

### CI/CD Changes

No CI/CD files or Java version pins were found requiring updates.

### Risks & Warnings

- **Java 25 compatibility is verified at build time only**: the baseline JDK 17 is unavailable. **Mitigation**: install JDK 25 and run the full reactor compile and tests after the upgrade.
- **Database connectivity is environment-dependent**: host processes must use published ports; containers sharing the Compose network must use database service names and native container ports. **Mitigation**: configure datasource URLs through `SPRING_DATASOURCE_URL` overrides and validate Compose DB health and ports when Docker is available.
- **Existing database credentials are development credentials**. **Mitigation**: preserve current local behavior and do not repeat or commit any new secrets.

## Upgrade Steps

- Step 1: Setup Environment
  - **Rationale**: Java 25 is required to validate the requested runtime target.
  - **Changes to Make**: Install JDK 25; use the existing Maven Wrapper 3.9.16.
  - **Verification**: List installed JDKs; JDK 25 is available.

- Step 2: Setup Baseline
  - **Rationale**: Capture the current build/test baseline when the project's JDK is available.
  - **Changes to Make**: None.
  - **Verification**: Skip because JDK 17 is not installed; no baseline build or tests can run.

- Step 3: Upgrade Java Target
  - **Rationale**: Set a single project-wide Java target for all reactor modules.
  - **Changes to Make**: Apply the Java property changes in Dependency Changes and correct the child parent `relativePath` entries listed in Configuration Changes so the reactor can build from its root.
  - **Verification**: From the repository root, run `.\items-services\mvnw.cmd -f pom.xml clean test-compile -q` using JDK 25; all modules and test sources compile.

- Step 4: Repair Module Database Container Connectivity
  - **Rationale**: Correct invalid container port mappings and ensure each module resolves to its matching database.
  - **Changes to Make**: Update all datasource configuration entries in Configuration Changes; map PostgreSQL containers to internal port 5432 and MySQL to internal port 3306; add database health checks in `docker-compose.yaml`.
  - **Verification**: Validate Compose configuration and, if Docker engine is available, start databases and verify health checks and published ports.

- Step 5: CVE Validation
  - **Rationale**: Check the project's direct dependency versions for known vulnerabilities.
  - **Changes to Make**: Scan resolved direct dependencies; fix any findings with available patches and preserve compatible dependency management.
  - **Verification**: Build and re-scan after any dependency changes.

- Step 6: Final Validation
  - **Rationale**: Confirm Java 25 and all service module changes work together.
  - **Changes to Make**: Resolve all upgrade-related failures and validate clean build, tests, and container database connectivity.
  - **Verification**: With JDK 25, run `.\items-services\mvnw.cmd -f pom.xml clean test-compile -q` and `.\items-services\mvnw.cmd -f pom.xml clean test -q`; all tests pass. Validate Compose health when the Docker engine is available.
