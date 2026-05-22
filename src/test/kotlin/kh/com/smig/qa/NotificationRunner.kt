package kh.com.smig.qa

import com.intuit.karate.junit5.Karate

class NotificationRunner {

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:notification")
}
