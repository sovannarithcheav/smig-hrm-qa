package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class OtConfigsRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("payment")
    }

    @Karate.Test
    fun run(): Karate = Karate.run("classpath:payment/ot-configs")
}
