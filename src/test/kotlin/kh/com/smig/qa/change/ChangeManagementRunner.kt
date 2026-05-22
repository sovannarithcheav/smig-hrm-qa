package kh.com.smig.qa.change

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class ChangeManagementRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        // change-management calls back to notification and payment as configured callback services
        fun setup() = ServiceStarter.ensureRunning(
            "change-management",
            "notification",
            "payment",
        )
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:change-management")
}
