package kh.com.smig.qa

import java.io.File
import java.net.HttpURLConnection
import java.net.URL

object ServiceStarter {

    private data class ServiceDef(val port: Int, val projectDir: String)

    private val registry = mapOf(
        "change-management" to ServiceDef(8084, "smig-hrm-change-management"),
        "payment"           to ServiceDef(8085, "smig-hrm-payment-service"),
        "notification"      to ServiceDef(8088, "smig-hrm-notification"),
        "user"              to ServiceDef(8081, "smig-hrm-user-service"),
    )

    /** Start all listed services in parallel, waiting for every one to be UP. */
    fun ensureRunning(vararg names: String) {
        val threads = names.map { name ->
            val def = registry[name] ?: error("[QA] Unknown service '$name' — add it to ServiceStarter.registry")
            Thread({ startIfNeeded(name, def) }, "qa-start-$name").also { it.start() }
        }
        threads.forEach { it.join() }
    }

    private fun startIfNeeded(name: String, def: ServiceDef) {
        val healthUrl = "http://127.0.0.1:${def.port}/actuator/health"
        if (isHealthy(healthUrl)) {
            println("[QA] $name already UP at 127.0.0.1:${def.port}")
            return
        }
        println("[QA] $name not running — starting...")
        val dir = File(System.getProperty("user.dir")).resolveSibling(def.projectDir)
        val process = ProcessBuilder("./gradlew", "run", "-Pdevelopment")
            .directory(dir)
            .redirectErrorStream(true)
            .start()

        Runtime.getRuntime().addShutdownHook(Thread {
            println("[QA] shutdown: stopping $name")
            process.destroy()
        })

        val deadline = System.currentTimeMillis() + 90_000L
        while (System.currentTimeMillis() < deadline) {
            Thread.sleep(3_000)
            if (isHealthy(healthUrl)) {
                println("[QA] $name is UP")
                return
            }
        }
        process.destroy()
        error("[QA] $name failed to start within 90s")
    }

    private fun isHealthy(url: String): Boolean {
        var conn: HttpURLConnection? = null
        return try {
            conn = URL(url).openConnection() as HttpURLConnection
            conn.connectTimeout = 2_000
            conn.readTimeout = 2_000
            conn.responseCode == 200
        } catch (e: Exception) {
            false
        } finally {
            conn?.disconnect()
        }
    }
}
