-- ТЕСТ: Построение непрерывных ежедневных остатков по счетам
WITH date_grid AS (
    -- 1. Генерируем непрерывный календарь дат за нужный период
    SELECT generate_series('2026-08-01'::date, '2026-08-15'::date, '1 day'::interval)::date AS report_date
),
daily_turns AS (
    -- 2. Считаем чистый оборот (приход минус уход) по каждому счету за каждые сутки
    SELECT
        COALESCE(from_account_id, to_account_id) AS account_id,
        transaction_date::date AS trans_date,
        SUM(CASE
            WHEN to_account_id IS NOT NULL THEN amount -- Нам пришло
            ELSE -amount -- От нас ушло
        END) AS day_turn
    FROM dds.fact_transactions
    GROUP BY COALESCE(from_account_id, to_account_id), transaction_date::date
),
joined_grid AS (
    -- 3. Связываем сетку дат со счетами и их оборотами, заполняя пустые дни нулями
    SELECT
        g.report_date,
        a.account_id,
        COALESCE(t.day_turn, 0) AS day_turn
    FROM date_grid g
    CROSS JOIN dds.hub_accounts a
    LEFT JOIN daily_turns t ON g.report_date = t.trans_date AND a.account_id = t.account_id
)
-- 4. Главная магия Middle-уровня: протягиваем баланс вперед через нарастающий итог
SELECT
    report_date,
    account_id,
    day_turn,
    SUM(day_turn) OVER (
        PARTITION BY account_id
        ORDER BY report_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS account_balance
FROM joined_grid
ORDER BY account_id, report_date;
