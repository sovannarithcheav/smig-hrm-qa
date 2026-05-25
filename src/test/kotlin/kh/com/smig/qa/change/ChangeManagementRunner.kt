package kh.com.smig.qa.change

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test

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

    @Test
    fun all() {
        val results = Karate.run("classpath:change-management").parallel(1)
        assertEquals(0, results.failCount, results.errorMessages)
    }
}
