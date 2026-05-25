package kh.com.smig.qa.notification

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class UpdateTemplateRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("change-management", "notification")
    }

    @Karate.Test
    fun run(): Karate = Karate.run(
        "classpath:notification/templates/positive/update.feature",
        "classpath:notification/templates/negative/update.feature",
    )
}
