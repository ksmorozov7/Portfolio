CREATE OR REPLACE VIEW dm_merchant_analytics AS
SELECT
    t.merchant_name AS merchant,
    t.category AS spend_category,
    COUNT(t.transaction_id) AS total_orders_cnt,
    ABS(SUM(t.amount)) AS total_spend_rub,
    ROUND(ABS(AVG(t.amount)), 2) AS avg_receipt_rub
FROM transactions t
WHERE t.amount < 0
GROUP BY t.merchant_name, t.category;
