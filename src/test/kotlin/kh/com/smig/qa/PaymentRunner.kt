package kh.com.smig.qa

import com.intuit.karate.junit5.Karate

class PaymentRunner {

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:payment")
}
