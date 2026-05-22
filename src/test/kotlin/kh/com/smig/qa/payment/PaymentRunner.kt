package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class PaymentRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        // payment calls change-management to create request changes for OT records
        fun setup() = ServiceStarter.ensureRunning(
            "payment",
            "change-management",
        )
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:payment")
}
