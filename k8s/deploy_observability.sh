#!/bin/bash

# Nome do namespace para a stack de observabilidade
NAMESPACE=observability

echo "🚀 Criando o namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "📂 Aplicando os manifests de configuração..."

# Atualizando ConfigMap do Loki
echo "📂 Atualizando ConfigMap do Loki..."
kubectl delete configmap loki-config -n $NAMESPACE --ignore-not-found
kubectl create configmap loki-config --from-file=loki/loki-config.yaml -n $NAMESPACE
kubectl create configmap otel-config --from-file=otel/config.yaml -n $NAMESPACE


# Aplicando os ConfigMaps
kubectl apply -f otel/otel-configmap.yaml -n $NAMESPACE
kubectl apply -f prometheus/prometheus-configmap.yaml -n $NAMESPACE
kubectl apply -f loki/loki-configmap.yaml -n $NAMESPACE
kubectl apply -f promtail/promtail-configmap.yaml -n $NAMESPACE
kubectl apply -f grafana/grafana-configmap.yaml -n $NAMESPACE

echo "🚢 Implantando os serviços..."

# Aplicando Deployments e DaemonSets
kubectl apply -f otel/otel-deployment.yaml -n $NAMESPACE
kubectl apply -f prometheus/prometheus-deployment.yaml -n $NAMESPACE
kubectl apply -f loki/loki-deployment.yaml -n $NAMESPACE
kubectl apply -f promtail/promtail-daemonset.yaml -n $NAMESPACE
kubectl apply -f grafana/grafana-deployment.yaml -n $NAMESPACE

# Criando serviços
kubectl apply -f otel/otel-service.yaml -n $NAMESPACE
kubectl apply -f prometheus/prometheus-service.yaml -n $NAMESPACE
kubectl apply -f loki/loki-service.yaml -n $NAMESPACE
kubectl apply -f grafana/grafana-service.yaml -n $NAMESPACE

# Criando volumes persistentes
kubectl apply -f grafana/grafana-pvc.yaml -n $NAMESPACE # em producao usa o pvc
#kubectl apply -f grafana/grafana-pv.yaml -n $NAMESPACE

echo "✅ Stack de observabilidade implantada com sucesso!"

echo "⌛ Aguardando os pods iniciarem..."
kubectl get pods -n $NAMESPACE

echo "🌍 Serviços disponíveis:"
kubectl get svc -n $NAMESPACE

echo "🎯 Para acessar o Grafana, use: kubectl port-forward svc/grafana 3000:3000 -n $NAMESPACE"
