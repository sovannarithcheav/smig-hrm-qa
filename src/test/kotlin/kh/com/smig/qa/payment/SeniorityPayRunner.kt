package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class SeniorityPayRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("payment", "change-management")
    }

    @Karate.Test
    fun positive(): Karate = Karate.run("classpath:payment/seniority-pays/positive")

    @Karate.Test
    fun negative(): Karate = Karate.run("classpath:payment/seniority-pays/negative")
}
