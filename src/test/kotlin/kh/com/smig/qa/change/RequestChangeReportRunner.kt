package kh.com.smig.qa.change

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class RequestChangeReportRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("change-management")
    }

    @Karate.Test
    fun positive(): Karate = Karate.run("classpath:change-management/report/positive")

    @Karate.Test
    fun negative(): Karate = Karate.run("classpath:change-management/report/negative")
}
