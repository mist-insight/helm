#!/bin/bash
echo "============================ "
echo " ./03_rabbitmq-setup.sh "
echo "======= RabbitMQ configuration "

RABBITMQ_PASSWORD=""
printf "Enter RabbitMQ Password (see ): " ; read RABBITMQ_PASSWORD ; echo
if [ -z "$RABBITMQ_PASSWORD" ]; then
    exit 1
fi

# добавление vhost
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl add_vhost mist_srvs_vhost
kubectl exec -it rabbitmq-server-1 -n mist-insight -- rabbitmqctl add_vhost mist_srvs_vhost
kubectl exec -it rabbitmq-server-2 -n mist-insight -- rabbitmqctl add_vhost mist_srvs_vhost

# создание пользователей
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl add_user mistech_srvs_conn $RABBITMQ_PASSWORD
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl add_user mistech_admin $RABBITMQ_PASSWORD
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl set_user_tags mistech_admin administrator
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl delete_user guest

# права пользователю на vhost
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl set_permissions -p mist_srvs_vhost mistech_srvs_conn ".*" ".*" ".*"
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmqctl set_permissions -p mist_srvs_vhost mistech_admin ".*" ".*" ".*"

# включить плагины
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmq-plugins enable rabbitmq_management
kubectl exec -it rabbitmq-server-0 -n mist-insight -- rabbitmq-plugins enable rabbitmq_stomp

# список активных plugins
kubectl exec -it rabbitmq-server-2 -n mist-insight -- rabbitmq-plugins list

# expose port
kubectl patch configmap tcp-services -n ingress-nginx --patch '{"data":{"5672":"mist-insight/rabbitmq:5672"}}'
