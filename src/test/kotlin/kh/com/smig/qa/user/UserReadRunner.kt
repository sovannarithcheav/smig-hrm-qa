package kh.com.smig.qa.user

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll

class UserReadRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() = ServiceStarter.ensureRunning("user")
    }

    // Excludes @write features — those need change-management too and live in UserWriteRunner.
    @Karate.Test
    fun run(): Karate = Karate.run("classpath:user").tags("~@write").relativeTo(javaClass)
}
