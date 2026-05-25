plugins {
    kotlin("jvm") version "2.2.21"
}

group = "kh.com.smig.qa"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("com.intuit.karate:karate-junit5:1.4.1")
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
}

kotlin {
    jvmToolchain(21)
}

val printKarateReport by tasks.registering {
    doLast {
        val report = file("build/karate-reports/karate-summary.html")
        if (report.exists()) {
            println("\n  Karate report: ${report.toURI()}\n")
        }
    }
}

tasks.test {
    useJUnitPlatform()
    // pass -Dkarate.env=staging to switch environment
    systemProperty("karate.env", System.getProperty("karate.env") ?: "dev")
    // pass -Dkarate.options="--tags @smoke" to filter by tag
    systemProperty("karate.options", System.getProperty("karate.options") ?: "")
    outputs.upToDateWhen { false }

    testLogging {
        events("passed", "skipped", "failed")
    }

    finalizedBy(printKarateReport)
}
