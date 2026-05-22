package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class ChangeManagementRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun ensureServiceRunning() {
            if (isHealthy()) {
                println("[QA] change-management already UP at localhost:8084")
                return
            }
            println("[QA] change-management not running — starting...")
            val dir = File(System.getProperty("user.dir")).resolveSibling("smig-hrm-change-management")
            val process = ProcessBuilder("./gradlew", "run", "-Pdevelopment")
                .directory(dir)
                .redirectErrorStream(true)
                .start()

            // Stop the process when the full test JVM exits (not just this test class)
            Runtime.getRuntime().addShutdownHook(Thread {
                println("[QA] shutdown: stopping managed change-management process")
                process.destroy()
            })

            val deadline = System.currentTimeMillis() + 90_000L
            while (System.currentTimeMillis() < deadline) {
                Thread.sleep(3_000)
                if (isHealthy()) {
                    println("[QA] change-management is UP")
                    return
                }
            }
            process.destroy()
            error("[QA] change-management failed to start within 90s")
        }

        private fun isHealthy(): Boolean = try {
            val conn = URL("http://localhost:8084/actuator/health").openConnection() as HttpURLConnection
            conn.connectTimeout = 2_000
            conn.readTimeout = 2_000
            conn.responseCode == 200
        } catch (e: Exception) {
            false
        }
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:change-management")
}
