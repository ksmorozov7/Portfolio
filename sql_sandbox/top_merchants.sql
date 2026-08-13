-- Витрина: Топ магазинов по объему трат и среднему чеку
CREATE OR REPLACE VIEW dm_top_merchants AS
SELECT
    t.merchant_name AS merchant,
    t.category AS spend_category,
    COUNT(t.transaction_id) AS total_orders_cnt,
    ABS(SUM(t.amount)) AS total_spend_rub,
    ROUND(ABS(AVG(t.amount)), 2) AS avg_receipt_rub
FROM transactions t
WHERE t.amount < 0 -- Анализируем только траты, исключаем зарплату
GROUP BY t.merchant_name, t.category
ORDER BY total_spend_rub DESC; -- Сортируем от самых дорогих к мелким
