package kh.com.smig.qa

import com.intuit.karate.junit5.Karate

class ChangeManagementRunner {

    @Karate.Test
    fun all(): Karate = Karate.run("change-management").relativeTo(javaClass)
}
