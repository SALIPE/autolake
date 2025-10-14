#!/bin/bash

# --- Configurações ---

# IPs das VMs (extraídos do terraform.tfvars)
STORAGE_IP=$(grep -A 5 '"storage"' terraform/terraform.tfvars | grep "ipv4_address" | cut -d '=' -f 2 | tr -d ' ",')
DATA_PLANE_IP=$(grep -A 5 '"data-plane"' terraform/terraform.tfvars | grep "ipv4_address" | cut -d '=' -f 2 | tr -d ' ",')

# Caminho para a chave SSH do Ansible
SSH_KEY_PATH="ansible/keys/ansible_key.pem"

# Usuário para conexão SSH
SSH_USER="ansible"

# Opções de SSH para evitar checagem de host e usar a chave correta
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_KEY_PATH"

# Script de teste do Spark a ser enviado para a VM
SPARK_TEST_SCRIPT="verify_spark_minio.py"

# --- Funções de Verificação ---

# Função para imprimir mensagens de sucesso
print_success() {
    echo -e "\033[0;32m  [SUCCESS] $1\033[0m"
}

# Função para imprimir mensagens de erro
print_error() {
    echo -e "\033[0;31m  [ERROR] $1\033[0m"
    exit 1
}

# Função para verificar o serviço MinIO
verify_minio() {
    echo "[1/3] Verifying MinIO on host $STORAGE_IP..."

    # Verificar se o serviço está ativo
    ssh $SSH_OPTS $SSH_USER@$STORAGE_IP "systemctl is-active minio" | grep -q "active" || print_error "MinIO service is not active."
    echo "  -> MinIO service is active."

    # Verificar se os buckets foram criados
    for bucket in raw processed curated; do
        ssh $SSH_OPTS $SSH_USER@$STORAGE_IP "sudo -u minio-user /usr/local/bin/mc ls local | grep -q '$bucket/'" || print_error "Bucket '$bucket' does not exist."
        echo "  -> '$bucket' bucket exists."
    done

    print_success "MinIO verification passed."
}

# Função para verificar os processos do Spark
verify_spark_processes() {
    echo -e "\n[2/3] Verifying Spark on host $DATA_PLANE_IP..."

    # Verificar processo do Spark Master
    ssh $SSH_OPTS $SSH_USER@$DATA_PLANE_IP "systemctl status spark-master | grep 'running'" || print_error "Spark Master process not found."
    echo "  -> Spark Master process is running."

    # Verificar processo do Spark Worker
    ssh $SSH_OPTS $SSH_USER@$DATA_PLANE_IP "systemctl status spark-worker | grep 'running'" || print_error "Spark Worker process not found."
    echo "  -> Spark Worker process is running."

    print_success "Spark process verification passed."
}

# Função para submeter um job de teste do Spark
verify_spark_job() {
    echo -e "\n[3/3] Submitting a test Spark job to the cluster..."

    # Enviar o script de teste para a VM
    scp $SSH_OPTS $SPARK_TEST_SCRIPT $SSH_USER@$DATA_PLANE_IP:/tmp/

    # Executar o job
    # Executar o job, garantindo que o /etc/profile.d/spark.sh seja lido
    JOB_OUTPUT=$(ssh $SSH_OPTS $SSH_USER@$DATA_PLANE_IP "source /etc/profile.d/spark.sh && spark-submit --master spark://$DATA_PLANE_IP:7077 --packages org.apache.hadoop:hadoop-aws:3.2.1 /tmp/$SPARK_TEST_SCRIPT")

    # Verificar a saída do job
    echo "$JOB_OUTPUT" | grep -q "Spark-MinIO integration test PASSED" || print_error "Spark job failed or did not produce the expected output."
    echo "  -> Spark job executed successfully and returned a result."

    print_success "Spark job submission passed."
}

# --- Execução Principal ---

echo "--- Verification Started ---"

verify_minio
verify_spark_processes
verify_spark_job

echo -e "\n\033[1;32m--- All Verifications Passed Successfully! ---\033[0m"

