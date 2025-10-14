#!/bin/bash
#
ANSIBLE_PLAYBOOK="../ansible/playbook.yaml"
ANSIBLE_INVENTORY="../ansible/inventory.ini"

terraform plan
terraform apply -auto-approve

ansible-playbook $ANSIBLE_PLAYBOOK -i $ANSIBLE_INVENTORY
