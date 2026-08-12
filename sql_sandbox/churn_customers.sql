-- ТЕСТ: Анализ оттока клиентов банка (Middle-уровень)
WITH client_last_transaction AS (
    -- 1. Находим дату самой последней операции для каждого аккаунта
    SELECT
        COALESCE(from_account_id, to_account_id) AS account_id,
        MAX(transaction_date) AS last_transaction_date
    FROM dds.fact_transactions
    GROUP BY COALESCE(from_account_id, to_account_id)
)
-- 2. Считаем дни без активности и фильтруем тех, у кого этот период > 30 дней
SELECT
    clt.account_id,
    clt.last_transaction_date::date AS последняя_операция,
    (CURRENT_DATE - clt.last_transaction_date::date) AS дней_без_активности,
    CASE
        WHEN (CURRENT_DATE - clt.last_transaction_date::date) > 30 THEN 'Отток'
        ELSE 'Активный'
    END AS статус_клиента
FROM client_last_transaction clt
WHERE (CURRENT_DATE - clt.last_transaction_date::date) > 30
ORDER BY дней_без_активности DESC;
