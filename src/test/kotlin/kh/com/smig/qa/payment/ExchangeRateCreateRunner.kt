package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class ExchangeRateCreateRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning(
            "payment",
            "change-management",
        )
    }

    @Karate.Test
    fun run(): Karate = Karate.run(
        "classpath:payment/exchange_rate/positive/create.feature",
        "classpath:payment/exchange_rate/negative/create.feature",
    )
}
