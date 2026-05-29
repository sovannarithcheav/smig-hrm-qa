package kh.com.smig.qa.notification

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class ReminderRulesRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("notification")
    }

    @Karate.Test
    fun positive(): Karate = Karate.run("classpath:notification/reminder-rules/positive")

    @Karate.Test
    fun negative(): Karate = Karate.run("classpath:notification/reminder-rules/negative")
}
