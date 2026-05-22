package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll

class ChangeManagementRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning(
            name       = "change-management",
            port       = 8084,
            projectDir = "smig-hrm-change-management",
        )
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:change-management")
}
