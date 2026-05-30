package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll
import java.sql.DriverManager

class PayrollFrequencyConfigRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() {
            ServiceStarter.ensureRunning("payment", "change-management")
            cleanFrequencyConfigs()
        }

        private fun cleanFrequencyConfigs() {
            val url = "jdbc:postgresql://127.0.0.1:5432/smig?currentSchema=payment"
            DriverManager.getConnection(url, "postgres", "root").use { conn ->
                conn.autoCommit = false
                conn.createStatement().use { st ->
                    st.execute("DELETE FROM payroll_run_component_configs")
                    st.execute("DELETE FROM payroll_frequency_configs")
                }
                conn.commit()
            }
        }
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:payment/payroll-frequency-configs")
}
