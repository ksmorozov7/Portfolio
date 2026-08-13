from datetime import datetime, timedelta
import random
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

default_args = {
    'owner': 'cinema_analyst',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
        dag_id='cinema_generate_views_v1',  # Новое имя робота для кинотеатра
        default_args=default_args,
        description='Автоматическая генерация просмотров в онлайн-кинотеатре',
        start_date=datetime(2026, 1, 1),
        schedule_interval='@hourly',  # Будет запускаться каждый час
        catchup=False
) as dag:
    def _generate_random_views():
        # Списки ID пользователей и фильмов, которые мы завели в базу
        user_ids = [1, 2, 3, 4]
        movie_ids = [1, 2, 3, 4]
        devices = ['Mobile', 'TV', 'Web']

        pg_hook = PostgresHook(postgres_conn_id='bank_dwh_connection')
        connection = pg_hook.get_conn()
        cursor = connection.cursor()

        # За раз генерируем пачку из 5 случайных просмотров
        for _ in range(5):
            rand_user = random.choice(user_ids)
            rand_movie = random.choice(movie_ids)
            rand_device = random.choice(devices)
            # Случайное время просмотра фильма (от 5 до 180 минут)
            rand_mins = random.randint(5, 180)

            insert_query = """
                INSERT INTO cinema.cinema_views (user_id, movie_id, view_date, watched_mins, device)
                VALUES (%s, %s, %s, %s, %s);
            """
            cursor.execute(insert_query, (rand_user, rand_movie, datetime.now(), rand_mins, rand_device))

        connection.commit()
        cursor.close()
        connection.close()


    generate_views_task = PythonOperator(
        task_id='generate_views_task',
        python_callable=_generate_random_views
    )

    generate_views_task
