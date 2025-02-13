# 🌍 Infraestrutura de Observabilidade no Kubernetes

## 🎯 Objetivo

Montamos uma stack de observabilidade dentro do Kubernetes usando os seguintes serviços:

Prometheus → Coleta métricas das aplicações e do cluster
Grafana → Visualiza e analisa métricas e logs
Loki → Armazena e consulta logs centralizados
Promtail → Envia logs das aplicações para o Loki
OTel Collector → Coleta e exporta traces/métricas para Prometheus e Loki

Esses serviços trabalham juntos para monitorar e trazer visibilidade sobre a aplicações.

## 🚀 Componentes e Interações

1️⃣ Prometheus (Monitoramento de Métricas)
📌 Função: Coleta métricas de serviços dentro do cluster.

🔗 Como as aplicações se conectam?

As aplicações precisam expor métricas via endpoint HTTP no formato Prometheus Exporter (/metrics).
O Prometheus acessa essas métricas de acordo com a configuração do ConfigMap (prometheus-config).

🛠 Configuração:

O ConfigMap define que o Prometheus coleta métricas de:

- Ele mesmo (localhost:9090)
- Grafana (grafana:3000)
- Loki (loki:3100)
- OTel Collector (otel-collector:8889)

🔄 Fluxo:

- Aplicações expõem métricas no endpoint /metrics
- O Prometheus coleta esses dados periodicamente
- Os dados são armazenados no banco interno do Prometheus
- O Grafana consulta e exibe essas métricas

2️⃣ Grafana (Visualização de Métricas e Logs)
📌 Função: Interface para visualização de métricas e logs.

🔗 Como se conecta?

Ele acessa o Prometheus para métricas (prometheus:9090)
Ele acessa o Loki para logs (loki:3100)

🛠 Configuração:

Configuramos um ConfigMap (grafana-config) com as configurações do Grafana.
Criamos um PVC (grafana-pvc) para armazenar dashboards e configurações.

🔄 Fluxo:

- O usuário acessa o Grafana (grafana:3000)
- O Grafana busca métricas no Prometheus e logs no Loki
- Os dashboards exibem os dados para análise

3️⃣ Loki (Armazenamento de Logs)
📌 Função: Centraliza e armazena os logs coletados dos serviços.

🔗 Como se conecta?

Recebe logs do Promtail
Envia logs para o Grafana para visualização

🛠 Configuração:

Criamos um ConfigMap (loki-config) com a configuração do Loki.
Definimos o backend de armazenamento como filesystem (/var/loki).
Criamos um PVC (loki-pvc) para persistência.

🔄 Fluxo:

- Promtail coleta logs dos pods e envia para o Loki
- O Loki indexa e armazena os logs
- O Grafana consulta e exibe logs em tempo real

4️⃣ Promtail (Coleta de Logs)
📌 Função: Coleta logs dos pods e os envia para o Loki.

🔗 Como se conecta?

- Lê logs dos arquivos no diretório /var/log/
- Envia logs para o Loki (loki:3100)

🛠 Configuração:

Criamos um ConfigMap (promtail-config) com a configuração do Promtail.
Criamos um DaemonSet, garantindo que o Promtail rode em todos os nodes.

🔄 Fluxo:

- O Promtail roda em todos os nodes do cluster
- Ele lê os logs dos containers (/var/log/\*)
- Envia esses logs para o Loki
- O Grafana pode exibir os logs em dashboards

5️⃣ OTel Collector (Traces e Métricas)
📌 Função: Captura traces distribuídos e métricas, enviando-os para o Prometheus e Loki.

🔗 Como se conecta?

- Recebe traces/métricas das aplicações via OTLP
- Envia métricas para o Prometheus
- Envia traces para o Loki (opcional)

🛠 Configuração:

Criamos um ConfigMap (otel-config) com a configuração do OpenTelemetry.
Ele recebe métricas de aplicações instrumentadas e as repassa para o Prometheus.
🔄 Fluxo

- Aplicações instrumentadas com OpenTelemetry enviam métricas e traces para o OTel Collector (otel-collector:4317/4318)
- O OTel Collector processa os dados e os encaminha para:
- Prometheus (métricas)
- Loki (logs/traces, se configurado)

## 🔄 Resumo das Conexões

| **Componente**     | **Recebe Dados de**           | **Envia Dados para**        | **Protocolos** |
| ------------------ | ----------------------------- | --------------------------- | -------------- |
| **Prometheus**     | Aplicações (via `/metrics`)   | Grafana                     | HTTP (scrape)  |
| **Grafana**        | Prometheus, Loki              | Interface Web               | HTTP (REST)    |
| **Loki**           | Promtail, OTel Collector      | Grafana                     | HTTP (logs)    |
| **Promtail**       | Arquivos de log               | Loki                        | HTTP (logs)    |
| **OTel Collector** | Aplicações (tracing/métricas) | Prometheus, Loki (opcional) | OTLP, HTTP     |

Essa tabela resume como cada componente da stack de observabilidade interage dentro do Kubernetes, garantindo monitoramento eficiente de **métricas, logs e traces distribuídos**. 🚀

## 🔥 Como as aplicações se conectam à stack?

### Monitoramento de métricas

Aplicações expõem métricas em /metrics
O Prometheus coleta essas métricas e o Grafana as exibe

### Coleta de logs

Os logs dos containers são capturados pelo Promtail
O Promtail os envia para o Loki
O Grafana exibe logs centralizados
Traces distribuídos:

Aplicações instrumentadas com OpenTelemetry enviam traces para o OTel Collector
O OTel Collector encaminha métricas para o Prometheus e logs para o Loki
O Grafana pode exibir esses traces (se configurado)

## 🛠 Como acessar os serviços?

### Acessar o Grafana

```bash
Copiar
Editar
kubectl port-forward svc/grafana 3000:3000 -n observability
Acesse: http://localhost:3000
```

### Acessar o Prometheus

```bash
Copiar
Editar
kubectl port-forward svc/prometheus 9090:9090 -n observability
Acesse: http://localhost:9090
```

### Acessar o Loki (para logs)

```bash
Copiar
Editar
kubectl port-forward svc/loki 3100:3100 -n observability
Acesse via Grafana
```
