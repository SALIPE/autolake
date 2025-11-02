from datetime import datetime

from airflow.operators.bash import BashOperator

from airflow import DAG

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

dag = DAG(
    dag_id="sample_dag",
    default_args=default_args,
    description="Exemplo simples de DAG",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
)


spark_submit_command = """
spark-submit --master spark://spark-master:7077 \
    --packages org.apache.hadoop:hadoop-aws:3.2.1 \
    /path/to/your/spark_job.py
"""

task1 = BashOperator(
    task_id='run_spark_minio_job',
    bash_command=spark_submit_command,
    dag=dag,
)

