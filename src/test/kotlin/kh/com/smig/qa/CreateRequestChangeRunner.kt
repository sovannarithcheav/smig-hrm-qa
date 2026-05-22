package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll

class CreateRequestChangeRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("change-management", "notification", "payment")
    }

    @Karate.Test
    fun run(): Karate = Karate.run("classpath:change-management/create-request-change.feature")
}
