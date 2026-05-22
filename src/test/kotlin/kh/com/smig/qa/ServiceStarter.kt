package kh.com.smig.qa

import java.io.File
import java.net.HttpURLConnection
import java.net.URL

object ServiceStarter {

    fun ensureRunning(name: String, port: Int, projectDir: String) {
        val healthUrl = "http://127.0.0.1:$port/actuator/health"
        if (isHealthy(healthUrl)) {
            println("[QA] $name already UP at 127.0.0.1:$port")
            return
        }
        println("[QA] $name not running — starting...")
        val dir = File(System.getProperty("user.dir")).resolveSibling(projectDir)
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

    private fun isHealthy(url: String): Boolean = try {
        val conn = URL(url).openConnection() as HttpURLConnection
        conn.connectTimeout = 2_000
        conn.readTimeout = 2_000
        conn.responseCode == 200
    } catch (e: Exception) {
        false
    }
}
