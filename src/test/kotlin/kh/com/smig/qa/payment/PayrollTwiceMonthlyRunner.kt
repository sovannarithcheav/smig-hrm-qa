package kh.com.smig.qa.payment

import com.intuit.karate.junit5.Karate
import kh.com.smig.qa.ServiceStarter
import org.junit.jupiter.api.BeforeAll
import java.sql.DriverManager

class PayrollTwiceMonthlyRunner {

    companion object {
        @JvmStatic
        @BeforeAll
        fun setup() {
            ServiceStarter.ensureRunning("payment", "change-management")
            cleanTestData()
        }

        private fun cleanTestData() {
            val url = "jdbc:postgresql://127.0.0.1:5432/smig?currentSchema=payment"
            DriverManager.getConnection(url, "postgres", "root").use { conn ->
                conn.autoCommit = false
                conn.createStatement().use { st ->
                    st.execute(
                        """
                        DELETE FROM payroll_line_items
                        WHERE payroll_detail_id IN (
                          SELECT pd.id FROM payroll_details pd
                          JOIN payroll_batches pb ON pb.id = pd.payroll_batch_id
                          WHERE pb.period LIKE '2099-%'
                        )
                        """.trimIndent()
                    )
                    st.execute(
                        """
                        DELETE FROM payroll_details
                        WHERE payroll_batch_id IN (
                          SELECT id FROM payroll_batches WHERE period LIKE '2099-%'
                        )
                        """.trimIndent()
                    )
                    st.execute("DELETE FROM payroll_batches WHERE period LIKE '2099-%'")
                    st.execute("DELETE FROM payroll_runs WHERE period LIKE '2099-%'")
                    st.execute("DELETE FROM payroll_run_component_configs")
                    st.execute("DELETE FROM payroll_frequency_configs")
                }
                conn.commit()
            }
        }
    }

    @Karate.Test
    fun all(): Karate = Karate.run("classpath:payment/twice-monthly")
}
