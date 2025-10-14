from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

dag = DAG(
    'minio_etl_dag',
    default_args=default_args,
    schedule_interval='@daily',
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

