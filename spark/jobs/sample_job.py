from pyspark.sql import SparkSession

def main():
    spark = SparkSession.builder \
        .appName("MinIOIntegrationJob") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .getOrCreate()

    # Exemplo de leitura de dados da camada raw
    df_raw = spark.read.json("s3a://raw/sample.json")

    # Exemplo de processamento e escrita na camada processed
    df_processed = df_raw.withColumn("processed_timestamp", F.current_timestamp())
    df_processed.write.mode("overwrite").parquet("s3a://processed/sample/")

    # Exemplo de agregação e escrita na camada curated
    df_curated = df_processed.groupBy("column_to_aggregate").count()
    df_curated.write.mode("overwrite").parquet("s3a://curated/sample_agg/")

    spark.stop()

if __name__ == "__main__":
    main()

