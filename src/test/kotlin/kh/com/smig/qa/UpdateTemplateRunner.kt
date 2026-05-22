package kh.com.smig.qa

import com.intuit.karate.junit5.Karate
import org.junit.jupiter.api.BeforeAll

class UpdateTemplateRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("change-management", "notification")
    }

    @Karate.Test
    fun run(): Karate = Karate.run("classpath:notification/update-template.feature")
}
