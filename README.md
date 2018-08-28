# loktionovam_microservices
loktionovam microservices repository

## Homework-12: Технология контейнеризации. Введение в Docker

Основные задания:

- Установка docker

- Базовая работа с консольной утилитой docker - создание, запуск, останов, удаление контейнеров, создание образов из контейнеров, удаление образов

Задание со *: описание отличий между container и image

Про образы.

- Docker image состоит из набора read-only слоев, например

```json
            "Layers": [
                "sha256:711e4cb62f50eb37292a0df824072b6a818211e3f9b3aae75a2067e65fa32eca",
                "sha256:a0e188d0e2789aeb82bd848958f432fbc19704bfa3337e0cad00545b43550f51",
                "sha256:6eaddaf493f101a62bb0875185e706424a33636db5d8a55945d63f6f870d7dd2",
                "sha256:07b9c3c04cbdf53317cb326fe3db42073366add5a8919f590e1574252ac6f8c9",
                "sha256:709bdd00b1a496a5ee836b8bc3e0f371fa114e9ff4cc524c0862696bbfc69c9c",
                "sha256:11266888239dc2bbd77759fb2c8df2eb2284983f817c745605d42d46402258a9"
     ]
```

- Каждый слой - это diff от предыдущего слоя.

- Разные images используют общие слои (не нужно загружать каждый слой каждый раз если он уже есть).

- В образах есть описание контейнеров (см. ниже), которые запущены поверх него

```json

        "Container": "b8fc5d0067d0ebc04a61b579250dc1753597e75fcc7554b2bebb6aefeb7abcp "${REPO_PATH}"/",
        "ContainerConfig": {
            "Hostname": "b8fc5d0067d0",
```

Про контейнеры.

- Создание нового контейнера создает COW read/write слой поверх image, этот слой называется container layer. В нем отличие контейнера от image (когда удаляется контейнер, то удаляется только его r/w слой, нижележащий image остается)

- При записи в файл контейнер просматривает слои (сверху-вниз, от самого нового, до самого старого). Файл копируется в writable слой и вся запись происходит в этот скопированный файл при этом контейнер не видит нижележащие read-only копии этого файла.

- В контейнерах есть состояние связанное с его runtime (pid, аппаратные ресурсы - память, процессор, описание сетевых интерфейсов), например

```json
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
...
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
```

Контейнеры это про runtime+r/w слой, images - это про хранение/доставку приложений.

## Homework-13: Docker контейнеры. Docker под капотом

### 13.1 Что было сделано

Основные задания:

- Создание docker host в GCP через docker machine

- Создание образа docker контейнера otus-reddit:1.0

- Создание репозитория на docker hub и загрузка в него образа otus-reddit:1.0

Задания со *:

- В docker-monolith/infra/ansible добавлена конфигурация ansible для настройки docker host (роль docker_host) и настроено dynamic inventory через gce.py

- В docker-monolith/infra/packer добавлена конфигурация для создания образа с уже установленным docker

- В docker-monolith/infra/terraform добавлена конфигурация для подъема инстансов docker-host-xxx, количество которых, задается переменной count


### 13.2 Как запустить проект

### 13.2.1 Шпаргалка по командам docker, docker machine. Создание образа otus-reddit

```bash
docker-machine create --driver google  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts  --google-machine-type n1-standard-1   --google-zone europe-west1-b  docker-host

docker-machine ls

docker-machine env docker-host
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://ip:port"
export DOCKER_CERT_PATH="/some/path/to/.docker/machine/machines/docker-host"
export DOCKER_MACHINE_NAME="docker-host"
# Run this command to configure your shell:
# eval $(docker-machine env docker-host)

eval $(docker-machine env docker-host)

# Запустить htop (PID из container namespaces)
docker run --rm -ti tehbilly/htop

# Запустить htop (PID из host namspaces)
docker run --rm --pid host -ti tehbilly/htop

docker run --help | grep "\-\-pid "
      --pid string                     PID namespace to use


# -t - tag (--tag=)
docker build -t reddit:latest .

# -d background mode (--detach=true)
# --network - use host network
docker run --name reddit -d --network=host reddit:latest

# Создать  tag алиас на reddit:latest
docker tag reddit:latest loktionovam/otus-reddit:1.0
# Запушить образ в docker registy
docker login
docker push loktionovam/otus-reddit:1.0

# Запустить существующий контейнер
docker stop reddit
docker start reddit

# Логи
docker logs reddit -f

# Запустить bash
docker exec -it reddit bash

# Удалить контейнер
docker rm reddit

# Запуск контейнера без запуска приложения
docker run --name reddit --rm  -it loktionovam/otus-reddit:1.0 bash
root@96aba478ca67:/# ps ax | grep start
   16 pts/0    S+     0:00 grep --color=auto start

# Полная информация об образе
docker inspect loktionovam/otus-reddit:1.0 

# Часть информации об образе
docker inspect loktionovam/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
[/bin/sh -c #(nop)  CMD ["/start.sh"]]

#Вывод списка измененных файлов и каталогов в контейнере
docker diff reddit
```

### 13.2.2 Настройка infra. Подготовительные действия - создание ssh ключей и сервисного аккаунта в GCP

```bash
export REPO_PATH=$(pwd)
export GCP_PROJECT=docker-project-name-here
ssh-keygen -t rsa -f ~/.ssh/docker-user -C 'docker-user' -q -N ''

gcloud iam service-accounts create docker-user --display-name docker-user

gcloud projects add-iam-policy-binding "${GCP_PROJECT}" --member serviceAccount:docker-user@"${GCP_PROJECT}".iam.gserviceaccount.com --role roles/editor
```

### 13.2.2 Настройка infra. Создание образа docker-host-base с помощью packer

```bash
# Создание образа хоста с предустановленным docker engine
cd "${REPO_PATH}"/docker-monolith/infra
packer build -var-file=packer/variables.json packer/docker_host.json
```

### 13.2.3 Настройка infra. Создание инстансов docker host через Terraform

```bash
cd "${REPO_PATH}"/docker-monolith/infra/terraform
# Перед выполением команд нужно настроить terrafrom.tfvars файл для создания remote backend
terraform init
terraform apply

cd "${REPO_PATH}"/stage
# Перед выполением команд нужно настроить terrafrom.tfvars файл для создания инстансов docker host и правил файерволла
terraform init
terrafrom apply
```

### 13.2.2 Настройка infra. Запуск reddit app

```bash
cd "${REPO_PATH}"/docker-monolith/infra/ansible
# Скопировать файл с секретными данными от service account
gcloud iam service-accounts keys create environments/stage/gce-service-account.json --iam-account docker-user@"${GCP_PROJECT}".iam.gserviceaccount.com

# Настроить gce dynamic inventory
ansible-playbook playbooks/gce_dynamic_inventory_setup.yml

# Развернуть reddit app на инстансах созданных ранее, через terraform
ansible-playbook playbooks/site.yml
```

### 13.3 Как проверить проект

- Приложение будет доступно в веб-браузере по адресу http://ip_address:9292, где список ip_address можно узнать командами

```bash
# Получить список всех ip адресов
cd "${REPO_PATH}"/docker-monolith/infra/terraform/stage
terraform output
```
