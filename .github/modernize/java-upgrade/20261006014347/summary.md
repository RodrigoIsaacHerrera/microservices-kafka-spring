# Java Upgrade Summary: microservices-kafka-spring

- **Session ID**: 20261006014347
- **Status**: Completed
- **Branch**: `appmod/java-upgrade-20261006014347`
- **Target**: Java 25 (latest LTS)
- **JDK used**: 25.0.2
- **Build tool**: Maven Wrapper 3.9.16

## Changes

- Set the root Maven `java.version` to 25 and removed Java 17 child overrides.
- Corrected all service parent POM paths so the root Maven reactor resolves its modules.
- Fixed PostgreSQL and MySQL container port mappings and added database health checks.
- Corrected the `storage-services` JDBC scheme and datasource username property.
- Aligned all service JDBC defaults with the Docker-published host ports and enabled `SPRING_DATASOURCE_URL` overrides.

## Validation

- `clean test-compile`: passed for the root reactor on JDK 25.
- `clean test`: passed; 3 tests, 0 failures, 0 errors, 0 skipped.
- `clean verify '-Djacoco.skip=false'`: passed.
- Docker Compose configuration validated; all three database containers reported healthy and their published ports were reachable.
- All three Java services started successfully against their module database containers.
- Direct dependency CVE scan: no known CVEs requiring fixes.

## Limitations and Notes

- Baseline tests were skipped because JDK 17 was not installed.
- No JaCoCo plugin is configured, so no coverage report was generated.
- Database containers are left running and healthy.

## Commits

- `468c503cdea652da26c55b943d31019214e68fe7` — Java 25 target and reactor parent resolution.
- `5106f1d186be1cadafdf2e44ab47dc5287d5ef4d` — module database container connectivity.
- `6ec7001e4749de33e1fc3e5aac90e73b96ab0b00` — direct dependency CVE validation.
- `4785e12ce5c2c10e04d064235b36d7f3ea4bd893` — final validation.
