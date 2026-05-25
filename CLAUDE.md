# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Karate (JUnit5) integration test suite for the SMIG HRM platform. Tests run against live locally-started services — there is no mocking.

- **Stack**: Kotlin 2.2.21, Karate 1.4.1, JUnit 5
- **Services under test**: `change-management` (:8084), `payment` (:8085), `notification` (:8088)

## Common Commands

```bash
# Run all tests
./gradlew test

# Run a specific runner class
./gradlew test --tests "kh.com.smig.qa.payment.ExchangeRateRunner"

# Run a specific feature file (no new runner needed)
./gradlew test --tests "kh.com.smig.qa.payment.ExchangeRateRunner" \
  -Dkarate.options="classpath:payment/exchange_rate/positive/create.feature"

# Run a whole directory
./gradlew test --tests "kh.com.smig.qa.payment.ExchangeRateRunner" \
  -Dkarate.options="classpath:payment/exchange_rate/negative"

# Run against staging
./gradlew test -Dkarate.env=staging
```

After every run, the Karate HTML report path is printed automatically (wired via `finalizedBy` in `build.gradle.kts`) — pass or fail:
```
Karate report: file:/…/build/karate-reports/karate-summary.html
```

**After running any test, always surface this link to the user.**

## Architecture

### Service auto-start

`ServiceStarter.ensureRunning(vararg names)` is called from each runner's `@BeforeAll`. It checks `GET /actuator/health` on the service's port; if not UP it launches `./gradlew run -Pdevelopment` from the sibling project directory and waits up to 90 s. Services are stopped on JVM shutdown. To add a new service, register it in `ServiceStarter.registry`.

### Runner → feature wiring

Each runner class calls `Karate.run(...)` with either:
- A **classpath directory** — runs all `.feature` files recursively (e.g. `classpath:payment/exchange_rate`)
- A **specific classpath path** — runs one file (e.g. `classpath:payment/exchange_rate/positive/create.feature`)
- Multiple paths — `Karate.run("classpath:...", "classpath:...")`
- `.tags("@tagName")` — filters by tag across the given path

### Feature file layout

```
src/test/resources/
  karate-config.js                     # global vars: paymentUrl, changeManagementUrl, notificationUrl, userId
  change-management/
    helper/                            # @ignore helpers: cancel, create, setup-pending
    request-change/
      positive/                        # create, approve, reject happy-path
      negative/                        # create, approve, reject validation / error
  notification/
    helper/                            # @ignore helpers: fetch-template, fetch-variables
    templates/
      positive/                        # list, detail, update happy-path
      negative/                        # list, detail, update validation / error
    variables/
      positive/
      negative/
    event-options/
      positive/
    send/
      positive/                        # e2e send flow
      negative/                        # e2e error cases
  payment/
    exchange_rate/
      positive/
      negative/
    ot-configs/
      positive/
      negative/
    ot-records/
      positive/
      negative/
```

**All resources — existing and new, across all services — must follow the `exchange_rate/` positive/negative split pattern.** When adding or reorganising feature files, always use:
```
<service>/
  <resource>/
    positive/   # happy-path and smoke scenarios
    negative/   # validation and error scenarios
```

### Tags

| Tag | Meaning |
|---|---|
| `@smoke` | Core happy-path, should always pass |
| `@negative` | Error/validation paths |
| `@e2e` | Multi-service flows (e.g. create → CS approve → verify) |
| `@create` / `@payment` / etc. | Domain/operation scoping for filtered runner runs |

### karate-config.js

Provides `paymentUrl`, `changeManagementUrl`, `notificationUrl`, `userId`, `participantId` to all scenarios. Switch environments with `-Dkarate.env=staging`.

### E2E pattern (multi-service flows)

E2E scenarios change `* url` mid-scenario to call a second service. Example in `positive/create-approve.feature`: POST to payment → approve via change-management URL → switch back to payment URL for verification. Always `* karate.pause(1000)` after triggering a CS callback to allow async processing.
