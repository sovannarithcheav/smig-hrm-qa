package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class NssfReportRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("payment")
    }

    @Karate.Test
    fun positive(): Karate = Karate.run("classpath:payment/nssf-reports/positive")

    @Karate.Test
    fun negative(): Karate = Karate.run("classpath:payment/nssf-reports/negative")
}
