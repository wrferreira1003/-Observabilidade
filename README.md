🚀 Observabilidade com OpenTelemetry, Zipkin, Prometheus, Loki, Promtail e Grafana

Este documento explica a stack de observabilidade utilizada no projeto, detalhando cada ferramenta, sua função e o motivo de sua escolha.

📌 Visão Geral

A observabilidade deste projeto é baseada em um conjunto de ferramentas que permitem coletar, armazenar e visualizar logs, métricas e traces de forma eficiente.

As tecnologias utilizadas são:

OpenTelemetry Collector (OTel) → Coleta métricas e traces.

Zipkin → Gerencia os traces do OpenTelemetry.

Prometheus → Coleta e armazena métricas.

Loki → Coleta e armazena logs.

Promtail → Envia logs para o Loki.

Grafana → Centraliza e visualiza logs, métricas e traces.

🔹 1. OpenTelemetry Collector (OTel)

O que é?

Um agente que coleta métricas e traces de aplicações distribuídas.

Por que usar?

Unifica a coleta de dados e os encaminha para diferentes sistemas de backend.

Permite coletar traces e métricas sem necessidade de instrumentação direta em cada serviço.

📌 Configuração

O OTel Collector recebe dados de instrumentação e os encaminha para o Zipkin e o Prometheus.

🔹 2. Zipkin

O que é?

Um sistema de rastreamento distribuído para analisar chamadas entre serviços.

Por que usar?

Ajuda a identificar gargalos e latências em aplicações distribuídas.

Permite visualizar o tempo de resposta das requisições entre microservices.

📌 Configuração

O Zipkin recebe traces diretamente do OpenTelemetry Collector e exibe um mapa das requisições.

🔹 3. Prometheus

O que é?

Um sistema de monitoramento que coleta e armazena métricas em séries temporais.

Por que usar?

Permite coletar métricas como uso de CPU, memória e tempo de resposta.

Facilita a criação de alertas para incidentes.

📌 Configuração

O OTel Collector exporta métricas para o Prometheus, que armazena e permite visualização no Grafana.

🔹 4. Loki

O que é?

Um sistema de logs otimizado para Kubernetes e aplicações distribuídas.

Por que usar?

Indexação eficiente, sem sobrecarga de armazenamento.

Integração fácil com Promtail e Grafana.

📌 Configuração

O Loki recebe logs enviados pelo Promtail, que captura logs dos containers.

🔹 5. Promtail

O que é?

Um agente que coleta logs e os envia para o Loki.

Por que usar?

Simples de configurar e altamente eficiente.

Funciona como o equivalente ao Prometheus, mas para logs.

📌 Configuração

Captura logs do Docker e os envia para o Loki.

🔹 6. Grafana

O que é?

Plataforma para visualização de métricas, logs e traces.

Por que usar?

Centraliza todas as informações da stack de observabilidade.

Permite criar dashboards personalizados para análise e monitoramento.

📌 Configuração

O Grafana consome dados do Prometheus, Loki e Zipkin para exibir métricas, logs e traces em dashboards interativos.

🎯 Conclusão

Esta stack de observabilidade garante monitoramento completo da aplicação, coletando métricas, logs e traces de forma eficiente. Com esta estrutura:
✅ Logs são armazenados no Loki via Promtail.
✅ Métricas são coletadas pelo Prometheus e visualizadas no Grafana.
✅ Traces são enviados para o Zipkin através do OTel Collector.
✅ O Grafana é o ponto central para visualizar todas as informações.

Essa abordagem permite detectar problemas rapidamente e melhorar a performance da aplicação de maneira contínua. 🚀
