package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll

class RejectRequestChangeRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("change-management", "notification", "payment")
    }

    @Karate.Test
    fun run(): Karate = Karate.run("classpath:change-management/reject-request-change.feature")
}
