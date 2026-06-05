package kh.com.smig.qa.user

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class UserWriteRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("user", "change-management")
    }

    @Karate.Test
    fun run(): Karate = Karate.run("classpath:user/write").relativeTo(javaClass)
}
