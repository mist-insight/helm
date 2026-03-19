# Prepare

## Base

```
# update helm
git pull

# create namespace
kubectl apply -f prepare/01_namespace.yml
```

## RabbitMQ

```
kubectl apply -f https://github.com/rabbitmq/cluster-operator/releases/download/v2.19.1/cluster-operator.yml
kubectl get all -o wide -n rabbitmq-system
kubectl apply -f prepare/02_rabbitmq.yml
#sleep 5 min - wait green ( pods + stateful sets ) 

chmod 700 prepare/03_rabbitmq-setup.sh
./prepare/03_rabbitmq-setup.sh <RABBITMQ_PASSWORD>
```

## Opensearch

```
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
set OPENSEARCH_INITIAL_ADMIN_PASSWORD to prepare/04_opensearch.yml
helm install opensearch opensearch/opensearch -n mist-insight -f prepare/04_opensearch.yml

# check
kubectl get pods -n mist-insight
kubectl logs -f opensearch-cluster-master-0 -n mist-insight
kubectl exec -it opensearch-cluster-master-0 -n mist-insight -- /bin/bash
curl -XGET https://localhost:9200 -u 'admin:<custom-admin-password>' --insecure
```

## Patch ingress-nginx-controller

```
kubectl patch deployment ingress-nginx-controller --patch "$(cat prepare/00_ingress-nginx-controller-patch.yaml)" -n ingress-nginx
```

## create registry secret

```
kubectl create secret docker-registry registry-secret -n mist-insight --docker-server=<ADDRESS> --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<EMAIL>
```

# Install/Upgrade

```
# check
helm install --dry-run --debug mist-insight .

# first install
helm install mist-insight .

# update
helm upgrade mist-insight .
```
