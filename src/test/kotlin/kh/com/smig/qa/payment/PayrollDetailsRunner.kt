package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class PayrollDetailsRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("payment")
    }

    @Karate.Test
    fun positive(): Karate = Karate.run("classpath:payment/payroll-details/positive")

    @Karate.Test
    fun negative(): Karate = Karate.run("classpath:payment/payroll-details/negative")
}
