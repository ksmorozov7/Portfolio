from datetime import datetime, timedelta
import random
from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

# 1. Базовые настройки нашего расписания
default_args = {
    'owner': 'data_steward',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

# 2. Объявляем сам DAG
with DAG(
        dag_id='bank_generate_transactions_v1',  # Уникальное имя, которое появится в браузере
        default_args=default_args,
        description='Автоматическая генерация банковских транзакций',
        start_date=datetime(2026, 1, 1),
        schedule_interval='@hourly',  # Скрипт будет запускаться автоматически каждый час
        catchup=False
) as dag:
    # Задача А: Проверяем структуру базы данных (если таблиц нет — создаст, если есть — пойдет дальше)
    check_table_exists = PostgresOperator(
        task_id='check_table_exists',
        postgres_conn_id='bank_dwh_connection',  # Имя подключения, которое мы настроим в следующем шаге
        sql="""
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id SERIAL PRIMARY KEY,
                account_id VARCHAR(20),
                transaction_date TIMESTAMP,
                category VARCHAR(50),
                amount NUMERIC(15, 2),
                merchant_name VARCHAR(100)
            );
        """
    )


    # Функция на Python, которая придумывает случайную покупку
    def _generate_random_transaction():
        accounts = [
            '40817810000000000001',
            '40817810000000000002',
            '40817810000000000004',
            '45501810000000000005'
        ]
        categories = ['Supermarkets', 'Cafes', 'Auto', 'Transfers']
        merchants = ['Magnit', 'Pyaterochka', 'VkusVill', 'Yandex Taxi', 'Starbucks', 'Lukoil']

        random_account = random.choice(accounts)
        random_category = random.choice(categories)
        random_merchant = random.choice(merchants)
        # Генерируем случайную трату от -100 до -5000 рублей
        random_amount = round(random.uniform(-100, -5000), 2)
        current_time = datetime.now()

        # Подключаемся к нашей базе данных через внутренний механизм Airflow
        pg_hook = PostgresHook(postgres_conn_id='bank_dwh_connection')
        connection = pg_hook.get_conn()
        cursor = connection.cursor()

        # Вставляем сгенерированные данные в таблицу
        insert_query = """
            INSERT INTO transactions (account_id, transaction_date, category, amount, merchant_name)
            VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(insert_query, (random_account, current_time, random_category, random_amount, random_merchant))
        connection.commit()
        cursor.close()
        connection.close()


    # Задача Б: Запуск нашей Python-функции
    generate_transaction_task = PythonOperator(
        task_id='generate_transaction_task',
        python_callable=_generate_random_transaction
    )

    # Задаем строгую последовательность: Сначала проверяем таблицу, затем вставляем данные
    check_table_exists >> generate_transaction_task
