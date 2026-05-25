package kh.com.smig.qa.notification

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test

class NotificationRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        // notification/templates/positive/update.feature calls change-management for request-change approval
        fun setup() = ServiceStarter.ensureRunning("notification", "change-management", "payment")
    }

    @Test
    fun all() {
        val results = Karate.run("classpath:notification").parallel(1)
        assertEquals(0, results.failCount, results.errorMessages)
    }
}
