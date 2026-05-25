package kh.com.smig.qa.change

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class ApproveRequestChangeRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("change-management", "notification", "payment")
    }

    @Karate.Test
    fun run(): Karate = Karate.run(
        "classpath:change-management/request-change/positive/approve.feature",
        "classpath:change-management/request-change/negative/approve.feature",
    )
}
