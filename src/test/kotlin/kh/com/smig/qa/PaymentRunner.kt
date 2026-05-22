package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll

class PaymentRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning(
            name       = "payment",
            port       = 8085,
            projectDir = "smig-hrm-payment-service",
        )
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:payment")
}
