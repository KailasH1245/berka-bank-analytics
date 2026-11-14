-- 1. Loan Portfolio Health & Default Rate Breakdown
SELECT 
    status,
    status_desc,
    COUNT(*) AS total_loans,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_loans,
    SUM(amount) AS total_principal,
    ROUND(AVG(amount), 2) AS avg_loan_amount,
    ROUND(AVG(CAST(duration AS FLOAT)), 1) AS avg_duration_months
FROM loan
GROUP BY status, status_desc
ORDER BY total_loans DESC;


-- 2. Pre-Loan Behavioral Signals
WITH PreLoanStats AS (
    SELECT 
        l.loan_id,
        l.account_id,
        l.is_default,
        l.amount AS loan_amount,
        COUNT(t.trans_id) AS pre_loan_tx_count,
        AVG(t.balance) AS avg_pre_loan_balance,
        MIN(t.balance) AS min_pre_loan_balance,
        SUM(CASE WHEN t.k_symbol = 'Sanction Interest' THEN 1 ELSE 0 END) AS sanction_fee_count
    FROM loan l
    LEFT JOIN trans t 
        ON l.account_id = t.account_id 
        AND t.trans_date < l.loan_date
    GROUP BY l.loan_id, l.account_id, l.is_default, l.amount
)
SELECT 
    CASE WHEN is_default = 1 THEN 'Defaulted (B/D)' ELSE 'Good Standing (A/C)' END AS loan_outcome,
    COUNT(*) AS loan_count,
    ROUND(AVG(loan_amount), 2) AS avg_loan_size,
    ROUND(AVG(avg_pre_loan_balance), 2) AS avg_account_balance,
    ROUND(AVG(min_pre_loan_balance), 2) AS avg_lowest_balance,
    SUM(sanction_fee_count) AS total_sanction_penalties
FROM PreLoanStats
GROUP BY is_default;

-- 3. Regional & District Credit Risk Ranking
SELECT TOP 10
    d.district_name,
    d.region,
    d.avg_salary,
    d.unemployment_96,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.amount) AS total_loan_volume,
    SUM(CAST(l.is_default AS INT)) AS defaulted_loans,
    ROUND(SUM(CAST(l.is_default AS INT)) * 100.0 / COUNT(l.loan_id), 2) AS default_rate_pct,
    DENSE_RANK() OVER (ORDER BY SUM(l.amount) DESC) AS volume_rank
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN district d ON a.district_id = d.district_id
GROUP BY d.district_name, d.region, d.avg_salary, d.unemployment_96
HAVING COUNT(l.loan_id) >= 5
ORDER BY default_rate_pct DESC, total_loan_volume DESC;

-- 4. Customer Demographics & Credit Card Tier vs. Default Risk
SELECT 
    CASE 
        WHEN c.age_1998 < 30 THEN 'Under 30'
        WHEN c.age_1998 BETWEEN 30 AND 44 THEN '30-44'
        WHEN c.age_1998 BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60+'
    END AS age_group,
    COALESCE(cd.type, 'No Card') AS card_tier,
    COUNT(DISTINCT c.client_id) AS total_owners,
    COUNT(DISTINCT l.loan_id) AS loans_taken,
    SUM(CAST(COALESCE(l.is_default, 0) AS INT)) AS defaults
FROM client c
JOIN disp dp ON c.client_id = dp.client_id AND dp.type = 'Owner'
LEFT JOIN card cd ON dp.disp_id = cd.disp_id
LEFT JOIN loan l ON dp.account_id = l.account_id
GROUP BY 
    CASE 
        WHEN c.age_1998 < 30 THEN 'Under 30'
        WHEN c.age_1998 BETWEEN 30 AND 44 THEN '30-44'
        WHEN c.age_1998 BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60+'
    END,
    COALESCE(cd.type, 'No Card')
ORDER BY age_group, loans_taken DESC;

-- 5. Year-over-Year Cash Inflow vs. Outflow Trend
WITH YearlyFlow AS (
    SELECT 
        YEAR(trans_date) AS tx_year,
        SUM(CASE WHEN type = 'Credit' THEN amount ELSE 0 END) AS total_inflow,
        SUM(CASE WHEN type <> 'Credit' THEN amount ELSE 0 END) AS total_outflow,
        COUNT(*) AS tx_volume
    FROM trans
    GROUP BY YEAR(trans_date)
)
SELECT 
    tx_year,
    tx_volume,
    total_inflow,
    total_outflow,
    total_inflow - total_outflow AS net_cash_flow,
    ROUND(
        (total_inflow - LAG(total_inflow) OVER (ORDER BY tx_year)) * 100.0 / 
        NULLIF(LAG(total_inflow) OVER (ORDER BY tx_year), 0), 
    2) AS inflow_yoy_growth_pct
FROM YearlyFlow
ORDER BY tx_year;