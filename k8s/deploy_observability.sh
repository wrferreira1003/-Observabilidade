#!/bin/bash

# Nome do namespace para a stack de observabilidade
NAMESPACE=observability

echo "🚀 Criando o namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "📂 Removendo recursos antigos para evitar conflitos..."

# Remover pods antigos para evitar falhas na reimplantação
kubectl delete pod -n $NAMESPACE --all --grace-period=0 --force --ignore-not-found

# Removendo os ConfigMaps antigos antes de criar novos
echo "📂 Removendo ConfigMaps antigos..."
kubectl delete configmap loki-config -n $NAMESPACE --ignore-not-found
kubectl delete configmap otel-config -n $NAMESPACE --ignore-not-found
kubectl delete configmap prometheus-config -n $NAMESPACE --ignore-not-found
kubectl delete configmap grafana-config -n $NAMESPACE --ignore-not-found
kubectl delete configmap promtail-config -n $NAMESPACE --ignore-not-found

echo "📂 Atualizando ConfigMaps..."
kubectl apply -f loki/loki-configmap.yaml -n $NAMESPACE
kubectl apply -f otel/otel-configmap.yaml -n $NAMESPACE
kubectl apply -f prometheus/prometheus-configmap.yaml -n $NAMESPACE
kubectl apply -f grafana/grafana-configmap.yaml -n $NAMESPACE
kubectl apply -f promtail/promtail-configmap.yaml -n $NAMESPACE

echo "📂 Criando volumes persistentes..."
kubectl apply -f grafana/grafana-pvc.yaml -n $NAMESPACE
kubectl apply -f loki/loki-pvc.yaml -n $NAMESPACE

echo "🚢 Removendo Deployments antigos..."
kubectl delete deployment otel-collector loki prometheus grafana -n $NAMESPACE --ignore-not-found
kubectl delete daemonset promtail -n $NAMESPACE --ignore-not-found

echo "🚢 Implantando novos serviços..."
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

echo "✅ Stack de observabilidade implantada com sucesso!"

echo "⌛ Aguardando os pods iniciarem..."
kubectl get pods -n $NAMESPACE

echo "🌍 Serviços disponíveis:"
kubectl get svc -n $NAMESPACE

echo "🎯 Para acessar o Grafana, use: kubectl port-forward svc/grafana 3000:3000 -n $NAMESPACE"


