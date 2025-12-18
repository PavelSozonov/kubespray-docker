# Kubespray Docker (prod-ready reusable project)

Этот проект запускает Kubespray внутри официального Docker-образа и устанавливает Kubernetes кластер из бастион-хоста.
Подходит для тестового стенда (Timeweb Cloud) и как база для production развертываний.

## Цели и требования

- **Kubernetes:** `v1.32.0`
- **Kubespray:** `v2.29.1` (официальный образ `quay.io/kubespray/kubespray:v2.29.1`)
- **CNI:** Calico (`v3.30.5`)
- **kube-proxy:** iptables
- **VIP:** kube-vip (ARP), `192.168.0.10`
- **Отключить:** dashboard, metallb
- **Стенд:** 3x master + 1x worker, AlmaLinux 9.0, 1 CPU / 2 GB RAM
- **Подсеть:** `192.168.0.0/24`
- **Запуск:** с bastion хоста

> В конфигурациях параметры для слабой конфигурации снабжены комментариями с **full-size** значениями для production.

## Структура проекта

```
.
├── inventory/timeweb
│   ├── hosts.yaml
│   └── group_vars
│       ├── all/all.yml
│       └── k8s_cluster
│           ├── addons.yml
│           ├── k8s-cluster.yml
│           └── kube-vip.yml
└── scripts
    ├── run-kubespray.sh
    ├── reset-cluster.sh
    └── shell.sh
```

## Подготовка

1. Установите Docker на bastion-хост.
2. Обеспечьте SSH-доступ с bastion до всех нод (мастера/воркеры).
3. Убедитесь, что SSH-ключ находится по пути `~/.ssh/id_rsa` (или задайте `SSH_KEY_PATH`).

## Настройка инвентаря

### 1) IP и хостнеймы

Файл: `inventory/timeweb/hosts.yaml`

- Обновите IP-адреса на свои реальные.
- Имена `master1..3`, `worker1` используются как inventory hostnames.

### 2) SSH/бастион

Файл: `inventory/timeweb/group_vars/all/all.yml`

- `ansible_user` — пользователь для подключения на ноды.
- Для ProxyJump (bastion) раскомментируйте `ansible_ssh_common_args`.
- Опция `override_system_hostname: false` запрещает переименование хостов.

### 3) Kubernetes и Calico

Файл: `inventory/timeweb/group_vars/k8s_cluster/k8s-cluster.yml`

- `kube_version: v1.32.0`
- `calico_version: v3.30.5`
- `kube_proxy_mode: iptables`
- `kubeadm_ignore_preflight_errors: [NumCPU]` — отключена проверка 2 CPU

Параметры для слабой конфигурации снабжены комментариями `full-size`.

### 4) kube-vip

Файл: `inventory/timeweb/group_vars/k8s_cluster/kube-vip.yml`

- `kube_vip_address: 192.168.0.10`
- `kube_vip_arp_enabled: true`
- `kube_vip_iface: eth0` (на VMware/L2 VLAN часто это `ens192` и т.п.)

### 5) Addons

Файл: `inventory/timeweb/group_vars/k8s_cluster/addons.yml`

- `dashboard_enabled: false`
- `metallb_enabled: false`

## Запуск установки

```bash
./scripts/run-kubespray.sh
```

При необходимости можно указать переменные:

```bash
INVENTORY_NAME=timeweb \
KUBESPRAY_IMAGE=quay.io/kubespray/kubespray:v2.29.1 \
SSH_KEY_PATH=~/.ssh/id_rsa \
./scripts/run-kubespray.sh
```

## Сброс кластера

```bash
./scripts/reset-cluster.sh
```

## Air-gapped деплой (шаблоны)

Файл: `inventory/timeweb/group_vars/all/all.yml` содержит закомментированные параметры для:

- внутренних registry и mirror репозиториев
- proxy
- `no_proxy`

Заполните и раскомментируйте их перед air-gapped деплоем.

## Примечания для Timeweb Cloud / L2 VLAN

- В Timeweb Cloud обычно достаточно `kube_vip_iface: eth0`.
- Для L2 VLAN (VMware) может потребоваться:
  - корректный интерфейс (например, `ens192`)
  - разрешение ARP на всей цепочке (security groups, vSwitch и т.п.)
  - настройка `calico_ipip_mode` или `calico_vxlan_mode` в зависимости от сети

## Лучшие практики

- Для production отключите `kubeadm_ignore_preflight_errors` и используйте full-size значения.
- Держите версии компонентов в соответствии с Kubespray release notes.
- Храните inventory и скрипты в Git для воспроизводимости.
