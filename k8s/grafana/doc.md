# 📌 Diferença entre PV e PVC

PersistentVolume (grafana-pv.yaml): Representa um volume físico no cluster, seja um diretório no host, um disco de uma nuvem (EBS, Azure Disk, etc.), ou um NFS. Ele define um recurso de armazenamento disponível no cluster.
PersistentVolumeClaim (grafana-pvc.yaml): É um pedido de armazenamento feito por um Pod. Ele solicita um PV que atenda aos requisitos (tamanho, acesso, etc.).
Em resumo:

PV = Infraestrutura de armazenamento (onde os dados ficam guardados).
PVC = Requisição para usar um PV disponível.

### 🔹 Explicação do grafana-pv.yaml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
name: grafana-pv
spec:
capacity:
storage: 5Gi # Capacidade total do volume
accessModes: - ReadWriteOnce # Pode ser montado apenas por um nó
hostPath:
path: /mnt/data/grafana # Caminho físico no nó onde os dados são armazenados
```

### 📌 O que esse PV faz?

✅ Define um volume de 5GB.
✅ Usa um hostPath, ou seja, armazena os dados localmente no worker node no caminho /mnt/data/grafana.
✅ Só pode ser acessado por um único pod/nó (ReadWriteOnce).

🚨 Se o pod mudar para outro nó, ele pode perder os dados!
Isso acontece porque hostPath está fixo em um nó específico.

### 🔹 Explicação do grafana-pvc.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: grafana-pvc
spec:
accessModes: - ReadWriteOnce
resources:
requests:
storage: 5Gi
```

### 📌 O que esse PVC faz?

✅ Pede um volume de 5GB.
✅ Procura por um PV disponível que atenda aos requisitos.
✅ Se não houver um PV manualmente criado, o Kubernetes pode criar um dinamicamente, caso esteja configurado um StorageClass.

🔹 Como eles trabalham juntos?
Criamos grafana-pv.yaml → Kubernetes disponibiliza 5GB de armazenamento.
Criamos grafana-pvc.yaml → Grafana solicita 5GB de armazenamento.
O Kubernetes liga o PVC ao PV, garantindo que o Grafana possa armazenar dados lá.

### 🔥 Quando usar cada um?

Se estiver em um ambiente local ou precisar de um volume fixo:
→ Crie manualmente um PV e vincule ao PVC (exemplo com hostPath).
Se estiver na nuvem (AWS, Azure, GCP, etc.):
→ Apenas crie o PVC, pois o Kubernetes pode criar um volume dinâmico com um StorageClass.
🚨 Melhor prática:

No ambiente local → Use hostPath com PV.
Na nuvem → Apenas defina o PVC e deixe o StorageClass provisionar o volume automaticamente.
Exemplo sem PV (provisionamento dinâmico)
Se estiver rodando no Kubernetes de um provedor de nuvem, não precisa do PV. Apenas crie o PVC, e um volume será provisionado automaticamente:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: grafana-pvc
spec:
accessModes: - ReadWriteOnce
resources:
requests:
storage: 5Gi
storageClassName: standard # Usa o storage padrão do cluster
Isso faz com que o Kubernetes crie um volume automaticamente sem precisar de um PV manual.
```
