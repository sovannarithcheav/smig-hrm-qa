package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll

class NotificationRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning(
            name       = "notification",
            port       = 8088,
            projectDir = "smig-hrm-notification",
        )
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:notification")
}
