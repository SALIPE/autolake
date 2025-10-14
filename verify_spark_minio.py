from pyspark.sql import SparkSession
from pyspark.sql.functions import col

def main():

    spark = (
        SparkSession.builder
        .appName("MinIO Integration Test")
        .config("spark.hadoop.fs.s3a.endpoint", "http://192.168.122.233:9000")
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin")
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin")
        .config("spark.hadoop.fs.s3a.path.style.access", "true")
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false")
        .getOrCreate()
    )



    try:
        # Criar um DataFrame de teste
        data = [("test_user", 1)]
        columns = ["name", "id"]
        df = spark.createDataFrame(data, columns)

        # Escrever no bucket 'raw'
        df.write.mode("overwrite").json("s3a://raw/spark_test/")

        # Ler do bucket 'raw'
        df_read = spark.read.json("s3a://raw/spark_test/")

        # Verificar se os dados foram lidos corretamente
        if df_read.count() == 1 and df_read.collect()[0]["name"] == "test_user":
            print("Spark-MinIO integration test PASSED")
        else:
            print("Spark-MinIO integration test FAILED")

    except Exception as e:
        print(f"An error occurred: {e}")
        print("Spark-MinIO integration test FAILED")

    finally:
        spark.stop()

if __name__ == "__main__":
    main()

