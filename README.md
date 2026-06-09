# smig-hrm-qa

End-to-end **integration test suite** for the SMIG HRM platform, written in
[Karate](https://github.com/karatelabs/karate) (JUnit 5). Tests run against **live, locally-started
services** — there is no mocking. Each runner boots the backend(s) it needs, exercises the real HTTP
contract (auth, validation, request-change approval, async callbacks), and tears them down on exit.

- **Group**: `kh.com.smig.qa`
- **Stack**: Kotlin 2.2.21, Karate 1.4.1, JUnit 5, Gradle (Kotlin DSL)
- **Services under test**: `user` (:8081), `change-management` (:8084), `payment` (:8085),
  `notification` (:8088)

## Common commands

```bash
./gradlew test                                                   # whole suite
./gradlew test --tests "kh.com.smig.qa.user.UserReadRunner"      # one runner class
./gradlew test --tests "<Runner>" \
  -Dkarate.options="classpath:user/users/list.feature"           # one feature file
./gradlew test -Dkarate.options="--tags @smoke"                  # by tag (comma = AND, no spaces)
./gradlew test -Dkarate.env=staging                              # switch env (default: dev)
```

After every run — pass or fail — the HTML report path is printed (wired via `finalizedBy`):

```
Karate report: file:/…/build/karate-reports/karate-summary.html
```

**Always surface that link after a run.**

## How it works

### Service auto-start

Each runner's `@BeforeAll` calls `ServiceStarter.ensureRunning(<name>…)`, which checks
`GET /actuator/health` on the service port and, if it is not UP, launches `./gradlew run -Pdevelopment`
in the sibling project directory (waits ≤90 s). Services are stopped on JVM shutdown. Register new
services in `ServiceStarter.registry`.

> **Gotcha:** if a service is already UP, ServiceStarter reuses it and will **not** pick up new code.
> Restart that service manually after editing it.

### Feature layout

```
src/test/resources/
  karate-config.js                 # global vars + per-env URLs (paymentUrl, userUrl, …)
  <service>/<resource>/positive/   # happy-path & smoke scenarios
  <service>/<resource>/negative/   # validation & error scenarios
  <service>/helper/                # @ignore helpers, invoked via callonce / karate.call()
```

All resources — existing and new — follow the `positive/` ÷ `negative/` split.

### Tags

Every feature carries three tag layers, sliceable with `--tags`:

```
@<domain> @<resource> @<polarity>   [optional: @smoke @e2e @create …]
```

Karate parses `karate.options` by whitespace, so multi-tag **AND** expressions use commas with no
spaces (e.g. `--tags @exchange_rate,@positive`); `not` negates.

### E2E (multi-service) flows

E2E scenarios change `* url` mid-scenario to call a second service (e.g. POST to payment → approve
via change-management → switch back to verify). Always `* karate.pause(1000)` after triggering a CS
callback to let async processing settle.

## See also

- `CLAUDE.md` — fuller runner/feature/tag reference for this repo.
- `../CLAUDE.md` — workspace architecture and the services these tests exercise.
