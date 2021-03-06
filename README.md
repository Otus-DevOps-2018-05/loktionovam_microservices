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

## Homework-14: Docker образы. Микросервисы

### 14.1 Что было сделано

Основные задания:

- Созданы docker образы для микросервисов comment, ui, post
- Создана docker сеть для приложения reddit
- Создан docker том для данных mongodb
- Запущены контейнеры на основе созданных образов

Задания со *:

- Изменение сетевых алиасов, использование env переменных

```bash
# Пример решения
docker run -d --network=reddit --network-alias=post_db_alias --network-alias=comment_db_alias mongo:latest
docker run -d --network=reddit --network-alias=post_alias -e 'POST_DATABASE_HOST=post_db_alias' loktionovam/post:1.0
docker run -d --network=reddit --network-alias=comment_alias -e 'COMMENT_DATABASE_HOST=comment_db_alias' loktionovam/comment:1.0
docker run -d --network=reddit --network-alias=ui_alias -e 'POST_SERVICE_HOST=post_alias' -e 'COMMENT_SERVICE_HOST=comment_alias' loktionovam/ui:1.0
```

Задания со *:

- Уменьшены размеры образов comment, ui, post

```bash
# Размеры образов ui
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
loktionovam/ui      3.2                 b92f70287088        11 seconds ago      34.5MB # alpine, multi-stage build, cache cleaning
loktionovam/ui      3.1                 8e94d1738f8f        4 minutes ago       37.5MB # alpine, multi-stage build
loktionovam/ui      3.0                 0054caafcade        14 minutes ago      210MB # alpine
loktionovam/ui      2.0                 5f494c53de90        23 minutes ago      460MB # ubuntu 16.04
loktionovam/ui      1.0                 1dc4afe3d94c        26 minutes ago      777MB # ruby 2.2
```

```bash
# Размеры образов post
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
loktionovam/post    2.2                 e13a2539eef3        6 minutes ago       35.1MB # alpine:3.8, multi-stage build, venv packages cleaning, pyc files removing
loktionovam/post    2.1                 a4978e47831e        13 minutes ago      57.5MB # alpine:3.8, multi-stage build, venv packages cleaning
loktionovam/post    2.0                 324095723244        21 minutes ago      62.6MB # alpine:3.8, multi-stage build
loktionovam/post    1.0                 228a932d5c0d        3 hours ago         102MB # python:3.6.0-alpine
```

```bash
# Размеры образов comment
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
loktionovam/comment   2.0                 d42d889bed54        18 seconds ago      30.1MB # alpine, multi-stage build, cache cleaning
loktionovam/comment   1.0                 d1e034889328        4 hours ago         769MB # ruby 2.2
```

### 14.2 Как запустить проект

- Предполагается, что перед запуском проекта уже существует **docker-host** и имеет адрес **docker_host_ip**

```bash
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                       SWARM   DOCKER        ERRORS
docker-host   *        google   Running   tcp://docker_host_ip:2376           v18.06.0-ce

eval $(docker-machine env docker-host)
```

- Создание docker образов микросервисов comment, post, ui

```bash
cd src
docker build -t loktionovam/comment:2.0  ./comment
docker build -t loktionovam/post:2.2  ./post-py
docker build -t loktionovam/ui:3.2  ./ui
```

- Запуск проекта

```bash
docker network create reddit
docker volume create reddit_db

docker run -d --network=reddit --network-alias=post_db \
 --network-alias=comment_db -v reddit_db:/data/db mongo:latest

docker run -d --network=reddit --network-alias=post loktionovam/post:2.2

docker run -d --network=reddit --network-alias=comment loktionovam/comment:2.0

docker run -d --network=reddit -p 9292:9292 loktionovam/ui:3.2
```

### 14.3 Как проверить проект

После запуска, reddit приложение будет доступно по адресу <http://docker_host_ip:9292>, при этом можно создать пост и оставить комментарий.

## Homework-15: Docker сети, docker-compose

Основные задания:

- Работа с none, host, bridge сетями docker
- Установка docker-compose
- Сборка образов приложения reddit с помощью docker-compose
- Запуск приложения reddit с помощью docker-compose
- Изменение префикса в docker-compose

В docker-compose имена префиксов контейнеров задаются env переменной **COMPOSE_PROJECT_NAME**, которая по умолчанию равна названию каталога с проектом:

```bash
cd /some/path/to/project_directory
basename $(pwd)
```

Эту переменную можно переопределить в **.env** файле:

```bash
# Defaul setting COMPOSE_PROJECT_NAME to the basename
# Change this value to setup containers prefix name
# COMPOSE_PROJECT_NAME=
```

Задания со *:

- Создание docker-compose.override.yml, который позволяет изменять код приложений без пересборки docker образов и запускать ruby приложения в режиме отладки с двумя воркерами.

### 15.1 Что было сделано

- Создан контейнер с none network driver, проверена конфигурация его сетевых интерфейсов

- Создан контейнер с host network driver, проверена конфигурация его сетевых интерфейсов

- Созданы контейнеры с bridge network driver, которым были присвоены сетевые алиасы

- Созданы docker сети front_net (подключены контейнеры ui, post, comment), back_net (подключены контейнеры mongo, post, comment)

- Проверена работа сетевого стека linux (net namespaces, iptables) при работе с docker

- Установлен docker-compose, написан docker-compose.yml для автоматического создания и запуска docker ресурсов

- Создан .env файл для настройки docker-compose через environment переменные (версии образов, префикс проекта и т. д.)

- Создан docker-compose.override.yml позволяющий изменять код приложения без пересоздания образа и запускать puma сервер в режиме отладки. Соответственно, изменены Dockerfile в микросервисах comment, ui, post для поддержки docker-compose.override.yml

### 15.2 Как запустить проект

- Предполагается, что перед запуском проекта уже существует **docker-host** и имеет адрес **docker_host_ip**, а также установлен **docker-compose**

```bash
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                       SWARM   DOCKER        ERRORS
docker-host   *        google   Running   tcp://docker_host_ip:2376           v18.06.0-ce

eval $(docker-machine env docker-host)
```

```bash
cd src
docker-compose up -d
```

### 15.3 Как проверить проект

После запуска, reddit приложение будет доступно по адресу <http://docker_host_ip:9292>, при этом можно создать пост и оставить комментарий.

## Homework-16: Gitlab CI. Построение процесса непрервыной интеграции

Основные задания: подготовить инсталляцию Gitlab CI, подготовить репозиторий с кодом приложения, описать для приложения этапы непрервыной интеграции

Задания со *: автоматизировать развертывание и регистрацию gitlab runner, добавить интеграцию pipeline со slack чатом

### 16.1 Что было сделано

- Добавлен boot disk size параметр в конфигурацию модуля docker_host в terraform, добавлена конфигурация файерволла для docker host в terraform

- Добавлена поддержка docker compose для ansible роли docker_host

- Пересобран packer образ для поддержки docker compose docker-host-base

- Добавлена gitlab_omnibus ansible роль для автоматического развертывания сервера с gitlab, для роли написаны тесты с использованием molecula и testinfra, добавлен healthchek в конфигурацию docker compose

- Добавлен gitlab_omnibus.yml плейбук для развертывания инстанса gitlab в GCP

- Добавлена конфигурация пайплана gitlab

- Добавлена gitlab_runner ansible роль для автоматического развертывания gitlab runner, для роли написаны тесты с использованием molecula и testinfra

- Добавлен gitlab_runner.yml плейбук для автоматического развертывания и регистрации gitlab runner

- Добавлено reddit приложение и тесты для него, настроен запуск тестов в gitlab CI/CD

- Добавлена интеграция со slack чатом <https://devops-team-otus.slack.com/messages/CB4BAETU5/>

### 16.2 Как запустить проект

Предполагается, что уже существует конфигурация terraform настроенная в рамках выполнения **Homework-13**

- Собрать новый образ docker-host-base с поддержкой docker compose через packer

```bash
cd infra
packer build -var-file=packer/variables.json packer/docker_host.json
```

- Настроить boot size в terraform и переразвенуть docker хост

```bash
cd infra/terraform/stage
# настроить size = 50 в terraform.tfvars
# и пересоздать docker host
terraform taint -module=docker_host google_compute_instance.docker_host
terraform apply -auto-approve
terraform output
```

- Установить gitlab сервер

```bash
cd gitlab-ci/ansible
ansible-playbook playbooks/gitlab_omnibus.yml
```

- Настроить пользователя, проект и т. д. в gitlab сервере

- Установить и зарегистрировать gitlab runner. Перед запуском плейбука необходимо настроить в `~/.ansible/gilab_runner_credentials.yml` переменные `gitlab_runner_token` и `gitlab_runner_coordinator_url`

```bash
cd gitlab-ci/ansible
ansible-playbook playbooks/gitlab_runner.yml
```

### 16.3 Как проверить проект

После настройки CI/CD в gitlab, можно запушить изменения и проверить, что статус пайплайна будет **passed**

```bash
git remote add gitlab http://<your-vm-ip>/homework/example.git
git push gitlab gitlab-ci-1
```

## Homework-17: Устройство Gitlab CI. Непрерывная поставка

Основные задания: расширить существующий пайплайн в gilab ci, определить окружения

Задания со *: при пуше новой ветки должен создаваться сервер для окружения с возможностью удалить его кнопкой

Задания с **: в шаг build добавить сборку контейнера с приложением reddit, контейнер деплоить на созданный для ветки сервер

### 17.1 Что было сделано

- В конвейер непрервывной поставки были добавлены шаги **staging, production** использующие различные окружения

- В ansible создана роль **reddit_monolith** для деплоя контейнера на docker хост

- Изменен плейбук **reddit_app.yml** с учетом **reddit_monolith**

- Написан Dockerfile для сборки docker образа reddit приложения

- Написан Dockerfile для сборки docker образа провижинера приложения, содержащий в себе terraform, ansible

- В docker_host module (terraform) добавлены ресурсы для провижинга приложения

- В шаг build добавлена сборка образов reddit, app_provision с их последующим сохранением в docker registry

- В конвейер непрервывной поставки был добавлен шаг **branch_start_review** для автоматического создания серверов для каждой ветки и деплоя приложения reddit. При этом, для каждой ветки через terrafrom workspace создается инстанс docker хоста, на который плейбуком reddit_app.yml деплоится reddit приложение

- В конвейер непрервывной поставки был добавлен шаг branch_stop_review для удаления серверов

### 17.2 Как запустить проект

Предполагается, что уже настроен gitlab сервер и зарегистрирован gitlab runner

В настройках CI/CD gitlab server нужно добавить следующие переменные:

- `CI_GOOGLE_CREDENTIALS` - переменная для подключения terraform к GCP

- `DOCKER_REGISTRY_USER` - пользователь docker hub registry

- `DOCKER_REGISTRY_PASSWORD` - пароль docker hub registry

- `GCE_SERVICE_ACCOUNT` - содержимое credentials файла от сервисного аккаунта GCP. Используется для настройки динамического инвентори через gce.py (роль ansible gce_py)

- `GCP_PROJECT` - название проекта в GCP

- `SSH_PRIVATE_KEY`, `SSH_PUBLIC_KEY` - пара ssh ключей для подключения к docker host (используются при провиженге через ansible)

После настройки environment переменных при пуше новой ветки в gitlab будет автоматичкски создано окружение и на него развернуто reddit приложение

### 17.3 Как проверить проект

После успешного выполнения шага **branch_start_review**, приложение будет доступно по адресу <http://docker_host_external_ip:9292>

```bash

Outputs:

docker_host_external_ip = [
    35.240.19.232
]
Job succeeded
```

После проверки приложения, сервер можно удалить нажав на **branch_stop_review**

## Homework-18: Введение в мониторинг. Системы мониторинга

Основное задание: запуск, конфигурация Prometheus; мониторинг состояния микросервисов; сбор метирк хоста с использованием экспортера

Задание со *: добавить в Prometheus мониторинг mongodb, зафиксировав версию образа экспортера на последнюю стабильную

Задание со *: добавить в Prometheus blackbox мониторинг сервисов comment, post, ui, зафиксировав версию образа экспортера на последнюю стабильную

Задание со *: добавить Makefile, которые умеет собирать и пушить образы docker контейнеров

### 18.1 Что было сделано

- Изменена структура каталогов проекта, добавлены каталоги docker, monitoring

- В конфигурацию docker compose добавлен сервис prometheus

- В конфигурацию prometheus и docker compose добавлен node-exporter

- Добавлен Dockerfile для сборки mongodb prometheus exporter от percona (результирующий образ построен на scratch), добавлен мониторинг mongodb в prometheus и docker compose

- Добавлен Dockerfile для сборки blackbox exporter; добавлен мониторинг микросервисов ui (blackbox-http), post (blackbox-tcp), comment (blackbox-tcp)

- Добавлен Makefile для сборки образов docker контейнеров и их пуша в docker hub; добавлена возможность старта и удаления микросервисов через Makefile

### 18.2 Как запустить проект

- Предполагается, что уже установлен **docker, docker compose**

- Установить make

```bash
apt-get update && apt-get install make
```

- Собрать образы контейнеров и локально запустить их через docker compose можно командой

```bash
make up
```

- Собрать образы контейнеров и запушить их в docker hub репозиторий можно командой

```bash
make all
```

- Остановить и удалить запущенные контейнеры

```bash
make down
```

Примеры работы с отдельными микросервисами:

- Собрать docker образ микросервиса (ui) можно командой

```bash
make ui_build
```

- Запушить docker образ микросервиса (ui) можно командой

```bash
make ui_push
```

- Собрать и запушить образ отдельного микросервиса (ui)

```bash
make ui
```

### 18.3 Как проверить проект

- В корне репозитория выполнить

```bash
make up
```

После сборки и запуска контейнеров по адресу <http://localhost:9292> будет доступно reddit приложение

По адресу <http://localhost:9090> будет доступен интерфейс prometheus

- В корне репозитория выполнить

```bash
make all
```

После сборки и пуша, образы контейнеров будут доступны в dockerhub по ссылке: <https://hub.docker.com/r/loktionovam>

## Homework-19: Мониторинг приложения и инфраструктуры

### 19.1 Что было сделано

Основное задание: мониторинг docker контейнеров; визуализация метрик; сборк метрик работы приложения и бизнес метрик; настройка и проверка алертинга

Задание со *: в Makefile добавлены цели для контейнеров telegraf, grafana, stackdriver, autoheal

Задание со *: в ansible роль docker-host добавлена настройка докер-хоста для отдачи метрик в prometheus, в grafana добавлен дашборд для их отображения (Docker_Engine_Metrics.json)

<https://grafana.com/dashboards/1229>

```bash
# Docker native metrics
curl http://172.17.0.1:9323/metrics 2>/dev/null| grep -E "^# " -v | wc -l
339
```

```bash
# Cadvisor metrics (их общее число зависит от числа контейнеров)
curl http://localhost:8080/metrics 2>/dev/null| grep -v "^# " | wc -l
3950

# Число уникальных метрик в Cadvisor
total: 58
```

Задание со *: добавлен мониторинг через telegraf, добавлен grafana dashboard `Docker_Performance_Monitoring.json` для отображения метрик собираемых через telegraf

```bash
# telegraf docker metrics
curl http://localhost:9273/metrics 2>/dev/null 2>/dev/null | grep -v "#"  metrics  | grep docker | wc -l
926
```

Задание со *: добавлен `UIHTTPHighResponceLatency` алерт (95-й перцентиль времени ответа UI)

Задание со *: настроена интеграция alertmanager с mailgun для рассылки оповещений на почту Для alertmanager я не нашел хорошего способа передачи секретных данных, кроме как хранить их в файле с конфигурацией ([https://github.com/prometheus/alertmanager/issues/504]), поэтому я добавил генерацию этого файла во время старта контейнера через скрипт `docker-entrypoint.sh`, при этом файл с секретами `alertmanager.secrets` лежит рядом с `Dockerfile` и настраивается через ansible плейбук `configure_microservices.yml` когда хост создается через terraform. Файл `alertmanager/config.yml` оставлен для проверки валидатором этого ДЗ и не используется Добавлена поддержка `alertmanager.secrets` в конфигурацию travis (данные зашифрованы в `secrets.tar.enc`)

Задание с **: добавлена загрузка дашбордов и источников данных в grafana через конфигурационные файлы, переделаны `json` файлы дашбордов для поддержки такого способа конфигурирования grafana (суть проблемы описана здесь [https://community.grafana.com/t/what-is-the-correct-way-to-save-dashboard-json-for-use-in-provisioning/5254/5])

Задание с **: добавлен мониторинг через stackdriver prometheus exporter (полный список метрик можно посмотреть здесь [https://cloud.google.com/monitoring/api/metrics_gcp]), добавлен `GCP stackdriver` дашборд в grafana. Stackdriver сэмплирует метрики раз в 60 секунд и отдает большинство из них только через 240 секунд, что может быть проблематично для оперативного обнаружения и устранения проблем (правда позволяет собирать не только метрики хостов, но множество других метрик GCP, например storage или loadbalancing)

```bash
# stackdriver metrics
curl http://localhost:9255/metrics 2>/dev/null | grep -E "^# " -v | wc -l
94
```

Задание с **: в код приложения post добавлен сбор метрик INSERT_DB_LATENCY, UPDATE_DB_LATENCY, VOTE_COUNT, добавлен дашборд `Post_DB_stats.json` в grafana для отображения задержек при операциях с БД в сервисе post, в дашборд Business_Logic_Monitoring добавлен график `Vote rate`

Задание с ***: в конфигурацию микросервисов добавлен trickster, datasource в grafana изменены с prometheus на trickster, в конфигурацию prometheus добавлен сбор метрик с trickster

Задание с ***: добавлена связка autoheal+AWX для автоматического исправления проблем. Добавлена ansible роль `awx_wrapper` которая автоматически устанавливает и запускает AWX, создает в нем организацию, проект, необходимые credentials, inventory, job template для исправления проблемы падения микросервиса. Добавлена конфигурация docker для сборки и запуска autoheal, добавлена ansible роль `autoheal` для автоматического запуска и настройки autoheal и окружения для его запуска (autoheal прибит гвоздями к kubernetes, поэтому для его запуска роль использует `minikube`, обсуждение проблемы здесь [https://github.com/openshift/autoheal/issues/110]). Добавлен ansible плейбук `mgmt_host.yml` для автоматического развертывания AWX+autoheal. Добавлен шаблон `mgmt_host.json` в packer для подготовки образа ноды c AWX+autoheal. Добавлен модуль `mgmt_host` в terraform для автоматического провиженинга AWX+autoheal на отдельный инстанс в GCE, в конфигурацию stage/prod terraform добавлено использование этого модуля.

### 19.2 Как запустить проект

Предполагается, что уже настрен аккаунт mailgun и есть конфигурационные параметры для настройки alertmanager

- Настроить следующие файлы

```bash
find . -name "*.example"

./infra/packer/variables.json.example
./infra/terraform/stage/terraform.tfvars.example
./infra/terraform/terraform.tfvars.example
./infra/terraform/prod/terraform.tfvars.example
./monitoring/stackdriver/gce-service-account.json.example
./monitoring/alertmanager/alertmanager.secrets.example
```

- Установить зависимости для ansible ролей

```bash
cd infra/ansible
ansible-galaxy install -r roles/awx_wrapper/requirements.yml
```

- Создать образы `docker_host`, `mgmt_host` через packer

```bash
cd ..
packer build -var-file=packer/variables.json packer/mgmt_host.json
packer build -var-file=packer/variables.json packer/docker_host.json
```

- Запустить через terraform, например stage окружение

```bash
cd terraform
terraform init
terraform apply -auto-approve
cd stage
terraform init
terraform apply -auto-approve
```

### 19.3 Как проверить проект

После выполнения вышеописанных шагов будет создано два инстанса в GCE `docker-host-default-001` (микросервисы), `mgmt-host-default-001` (AWX+autoheal)

```
docker_host_external_ip = [
    docker_host_ip
]
mgmt_host_external_ip = mgmt_host_ip
```

при этом на `docker-host-default-001` будут доступны следующие ресурсы

```
http://docker_host_ip:9292 - reddit ui
http://docker_host_ip:3000 - grafana ui
http://docker_host_ip:9090 - prometheus ui
```

а на `mgmt-host-default-001`

```
http://mgmt_host_ip  - AWX ui
```

Если убить, например, `ui` контейнер, то в slack и на почту упадет оповещение

```
[1] Firing
Labels
alertname = InstanceDown
instance = ui:9292
job = ui
severity = page
Annotations
description = ui:9292 of job ui has been down for more than 1 minute
summary = Instance ui:9292 down
```

а через autoheal+AWX сервис будет перезапущен с помощью AWX job template `run_microservices`, при этом в логах autoheal будут сообщения

```
I1017 16:11:10.524400       1 alerts_worker.go:135] Checking rule 'start-services' for alert 'InstanceDown'
I1017 16:11:10.524507       1 alerts_worker.go:103] Rule 'start-services' matches alert 'InstanceDown'
I1017 16:11:10.524516       1 alerts_worker.go:174] Running rule 'start-services' for alert 'InstanceDown'
I1017 16:11:11.120843       1 awx_action_runner.go:117] Running AWX job from project 'otus' and template 'run_microservices' to heal alert 'InstanceDown'
I1017 16:11:11.740007       1 awx_action_runner.go:164] Request to launch AWX job from template 'run_microservices' has been sent, job identifier is '3'
I1017 16:15:38.765453       1 active_jobs_worker.go:27] Going over active jobs queue
I1017 16:15:39.180936       1 awx_action_runner.go:213] Job 3 status: successful
```

## Homework-20: Логирование и распределенная трассировка

Основное задание: сбор неструктурированных логов, визуализация логов, сбор структурированных логов

Задание со *: добавление в fluentd дополнительного фильтра для разбора двух форматов логов UI-сервиса

Задание со *: настройка распределенного трейсинга через zipkin; решение проблемы медленной загрузки поста с помощью zipkin

### 20.1 Что было сделано

- Микросервисы ui, post, comment обновлены до версий, в которых реализована поддержка централизованного логирования и распределенной отладки

- Добавлена конфигурация docker для fluentd

- Добавлена конфигурация (`docker-compose-logging.yml`) для логирования на основе EFK стека

- В Makefile добавлены цели `up_logging`, `down_logging`, `run_logging` для более простой сборки docker образов и запуска сервисов логирования

- Для ui, post микросервисов включено логирование с помощью EFK стека

- (*) Для неструктурированных логов ui сервиса в конфигурации fluentd создано два grok фильтра

- (*) Настроен распределенный трейсинг через zipkin, с помощью которого, проблема медленной загрузки постов

- В terraform добавлены правила файерволла для kibana, zipkin

- В ansible роль docker_host добавлена таска "Setup sysctl vm.max_map_count (need to start Elasticsearch docker container)"


Решение проблемы медленной загрузки постов:

- В трейсе zipkin видно, что загрузка поста тормозит (выполняется более 3 секунд) в микросервисе post на span `db_find_single_post`

```json
{"traceId":"b75e6044b69e4b97","parentId":"10936eab56fcedd8","id":"7bf8af12a44a74dd","kind":"CLIENT","name":"db_find_single_post","timestamp":1539891825806233,"duration":3005865,"localEndpoint":{"serviceName":"post","ipv4":"172.27.0.5","port":5000}},
```

- В коде `post_app.py` ищем `span=db_find_single_post` и видим, что `time.sleep(3)`. Этот sleep нужно удалить, пересобрать образ post контейнера и перезапустить его

```python
@zipkin_span(service_name='post', span_name='db_find_single_post')
def find_post(id):
...
        stop_time = time.time()  # + 0.3
        resp_time = stop_time - start_time
        app.post_read_db_seconds.observe(resp_time)
        time.sleep(3)

```

### 20.2 Как запустить проект

Описано в п. 19.2 и дополнительно, после запуска всех приложений, нужно настроить в kibana index pattern для fluentd

### 20.3 Как проверить проект

После запуска проекта будут доступны следующие дополнительные ресурсы

- <http://docker_host_ip:9411> - веб-интерфейс zipkin

- <http://docker_host_ip:5601> - веб-интерфейс kibana

## Homework-21: Введение в Kubernetes

Основное задание: Разобрать на практике все компоненты kubernetes, развернуть их вручную используя Hard Way, ознакомиться с описанием основных примитивов куввше приложения и его дальнейшим запуском в Kubernetes

Задание со*: Описать установку компонентов kubernetes из туториала `Kubernetes The Hard Way` в виде Ansible-плейбуков в папке `kubernetes/ansible`

### 21.1 Что было сделано

- Пройден туториал `Kubernetes The Hard Way` вручную, проверена загрузка deployment-ов (ui, post, mongo, comment) и запуск подов

- Написаны ansible плейбуки полностью автоматизирующие `Kubernetes The Hard Way`

```bash
02-client-tools.yml
03-create-controller-instance.yml
03-create-worker-instance.yml
03-provisioning-compute-resources.yml
04-certificate-authority.yml
04-copy-creds-to-controller.yml
04-copy-creds-to-worker.yml
04-prepare-node.yml
04-worker-instance-certificate.yml
05-generate-kubeconfigs.yml
05-generate-service-kubeconfig.yml
05-generate-worker-kubeconfig.yml
06-data-encryption.yml
07-bootstraping-etcd.yml
08-bootstrapping-kubernetes-controllers.yml
08-kubernetes-frontend-load-balancer.yml
09-bootstrapping-kubernetes-workers.yml
10-configuring-kubectl.yml
11-pod-network-routes.yml
12-dns-addon.yml
kubernetes_the_hard_way.yml
```

### 21.2 Как запустить проект

Предполагается, что gcloud уже настроен и есть учетная запись сервисного аккаунта google из под которой будет выполняться создание в GCP инстансов, сетей и т. д.

```bash
cd kubernetes/ansible
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
export GCE_REGION=$(gcloud config get-value compute/region 2> /dev/null)
export GCE_CREDENTIALS_FILE_PATH=~/.ansible/gce-service-account.json
export GCE_EMAIL=user@docker-1234.iam.gserviceaccount.com
export GCE_PROJECT=docker-1234
ansible-playbook -K kubernetes_the_hard_way.yml
```

### 21.3 Как проверить проект

Для проверки инсталляции kubernetes нужно:

- Выполнить шаги описанные в <https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md>

- Проверить запуск подов `ui, post, mongo, comment`

```bash
cd kubernetes/reddit
for DEPLOYMENT in *.yml; do kubectl apply -f $DEPLOYMENT;done
```

## Homework-22: Kubernetes. Запуск кластера и приложения. Модель безопасности

Основное задание: развернуть локальное окружение для работы с k8s; развернуть k8s в GKE; запустить reddit в k8s

Задание со*: развернуть k8s в GKE с помощью terraform; создать YAML манифесты для включения k8s dashboard

### 22.1 Что было сделано

- Развернуто и настроено локальное окружение k8s через minicube

- Сконфигурированы `deployment` и `service` файлы reddit приложения

- Добавлен манифест с dev `namespace`

- Добавлена конфигурация `terraform` для провиженинга k8s в GKE - модуль gke, который развертывает k8s кластер и настраивает файерволл

- Добавлены YAML манифесты для развертывания k8s dashboard

### 22.2 Как запустить проект

- Развернуть kubernetes в GKE

```bash
cd kubernetes/terraform
terraform init
terraform apply -auto-approve=true
cd kubernetes
terraform init
terraform apply -auto-approve=true
```

- Сконфигурировать `kubectl` для работы с вновь созданным кластером

```bash
export GKE_CLUSTER=cluster-name-here
export GCP_ZONE=zone-here
export GCP_PROJECT=project-here
gcloud container clusters get-credentials $GKE_CLUSTER --zone $GCP_ZONE --project $GCP_PROJECT
```

- Разрешить пользователю создавать роли в Kubernetes, настроив `name: SETUP_USER_ACCOUNT_HERE` в файле `kubernetes/reddit/cluster-admin-rolebinding.yml` и выполнив

```bash
kubectl apply -f cluster-admin-rolebinding.yml
```

- Загрузить dashboard в kubernetes

```bash
kubectl apply -f kubernetes-dashboard.yaml
kubectl apply -f kubernetes-dashboard-rolebinding.yml
```

- Создать `dev` namespace

```bash
kubectl apply -f dev-namespace.yml
```

- Задеплоить reddit приложение в `dev`

```bash
kubectl apply -f . -n dev
````

### 22.3 Как проверить проект

- Проверка dashboard. После выполнения команды

```bash
kubectl proxy
```

должен быть доступен dashboard по адресу <http://localhost:8001/ui>

- Проверка reddit приложеня. 

```bash
REDDIT_IP=$(kubectl get nodes  -o json | jq --raw-output --arg ext_ip "ExternalIP" '.items[0].status.addresses[] | select( .type == $ext_ip) | .address')
```

```bash
REDDIT_PORT=$(kubectl get services ui -n dev -o json | jq '.spec.ports[].nodePort')
```

Приложение должно быть доступно по адресу <http://$REDDIT_IP:$REDDIT_PORT>

## Homework-23: Kubernetes. Networks, Storages

Основное задание: ознакомиться с типами сервисов для управления сетью (ClusterIP, NodePort, LoadBalancer), их работой в связке с `kube-dns`; ознакомиться с работой Ingress контроллера для организации доступа к приложению снаружи кластера, балансировки трафика, терминации TLS; ознакомиться с работой сетевых политик для ограничения доступа к сервису mongodb; конфигурирование быстрого, постоянного хранилища для mongodb с помощью persistent volume claim и storage class

Задание со*: описать создаваемый объект `Secret` в виде Kubernetes манифеста

### 23.1 Что было сделано

- Проверена работа `kube-dns`

- Проверена работа сервиса `ui` в режиме `nodePort`

- Настроен сервис `LoadBalancer` для TCP балансировки, проверена его работа

- Вместо `LoadBalancer` (у которого имеется ряд ограничений) настроен `Ingress controller` для L7 балансировки и терминирования TLS

- (*) Объект Secret описан в виде k8s манифеста (см. `ui-ingress-secret.yml.example`)

- Добавлено описание через `StorageClass` быстрого хранилища для mongodb

- Хранилище для mongodb подключено через `Persistent Volume Claim`

### 23.2 Как запустить проект

Все аналогично описанному в п. 22.2 за исключением того, что после создания кластера терраформом нужно включить `NetworkPolicy` командами

```bash
gcloud beta container clusters update <cluster_name_here> --zone=<zone_here> --update-addons=NetworkPolicy=ENABLED
gcloud beta container clusters update <cluster_name_here> --zone=<zone_here> --enable-network-policy
```

и настроить `ui-ingress-secret.yml.example` добавив реальные сертификат и ключ вместо `tls_certificate_here`, `tls_key_here`

### 23.3 Как проверить проект

- Для проверки `Ingress` контроллера нужно получить адрес командой

```bash
INGRESS_ADDRESS=$(kubectl get ingress -n dev -o json | jq --raw-output '.items[].status.loadBalancer.ingress[].ip')
```

и проверить в браузере, что reddit приложение открывается через https по этому адресу <https://INGRESS_ADDRESS>

- Для проверки `Persistent Volume Claim` нужно создать пост в reddit приложении, затем удалить mongodb deploymlent и снова запустить

```bash
kubectl delete deploy mongo -n dev
kubectl apply -f mongo-deployment.yml -n dev
```

при этом ранее созданный пост должен остаться.

## Homework-24: CI/CD в Kubernetes

Основное задание: работа с helm, развертывание gitlab в kubernetes, запуск CI/CD конвейера в Kubernetes

Задание со*: связать пайпланы сборки образов и деплоя на staging и production так, чтобы после релиза образа из ветки мастер - запускался деплой уже новой версии приложения на production

### 24.1 Что было сделано

- Установлен helm (локально) и tiller (в k8s)

- Для микросервисов post, reddit, ui разработаны `helm charts`

- В k8s развернут и настроен gitlab omnibus

- Созданы пайпланы в gitlab для ui, commit, post сервисов со стадиями `review/stop_review`

- Создан пайплайн для деплоя reddit приложения в k8s на stage/prod

- (*) Связаны пайплайны сборки образов и деплоя на staging и production

- В конфигурацию terraform добавлены node_pool (defaultpool, bigpool) для более гибкой настройки GKE. В terraform добавлен провиженер GKE настраивающий права, устанавливающий tiller, gitlab и т. д

### 24.2 Как запустить проект

Предполагается, что на локальной машине установлены terraform, kubectl, helm

- Развернуть kubernetes в GKE, при этом будут развернуты tiller и gitlab-omnibus

```bash
cd kubernetes/terraform
terraform init
terraform apply -auto-approve=true
cd kubernetes
terraform init
terraform apply -auto-approve=true
```

- В gitlab нужно создать группу и проекты ui, comment, post, reddit-deploy

- Для reddit-deploy нужно создать триггер запуска (который будет использован в остальных пайпланах) `reddit_deploy`, при этом нужно сохранить токен в переменной `REDDIT_DEPLOY_TOKEN`

- В gitlab в настройках группы добавить следующие переменные:

```
CI_REGISTRY_USER - логин в dockerhub
CI_REGISTRY_PASSWORD - пароль в dockerhub
REDDIT_DEPLOY_TOKEN - - токен для запуска reddit-deploy из других пайплайнов
```

- Запушить исходный код в соответствующие проекты ui, comment, post, reddit-deploy

### 24.3 Как проверить проект

- Если изменения произошли не в ветке `master`, то после сборки соответствующего микросервиса в gitlab, в `environments` будет ссылка на `review`.

- Если изменнеия произошли в ветке `master`, то сначала запустится пайплайн для билда соответствующего микросервиса, после которого будет запущен пайплайн для деплоя на stage/prod

- Список запущенных релизов можно увидеть командой

```bash
helm ls
```

## Homework-25: Kubernetes. Мониторинг и логирование

Основное задание: развертывание prometheus в k8s, настройка prometheus и grafana для сбора метрик, настройка EFK для сбора логов

Задание со*: запуск alertmanager в k8s и настройка правил для контроля за доступностью api-сервера и хостов k8s

Задание со*: создать helm-чарт для установки стека EFK

### 25.1 Что было сделано

- Выключен stackdriver (мониторинг и логирование) в процессе первоначальной установки и настройки k8s

- Добавлен prometheus helm-чарт c kube-state-metrics и node-exporter

- Добавлены `reddit-production, post-endpoints, comment-endpoints, ui-endpoints` jobs в конфигурацию prometheus helm-чарта

- Добавлена установка grafana в процесс первоначальной установки и настройки k8s

- Для `Business_Logic_Monitoring, Post_DB_stats, UI_Service_Monitoring` grafana dashboard включена параметризация через namespaces

- Добавлены новые `kubernetes cluster monitoring, Kubernetes deployment metrics` дашборды в grafana

- (*) В helm-чарте prometheus включен alertmanager, добавлены алерты `NodeDown`, `APIServerDown`

- (*) Добавлен helm-чарт для установки EFK стека, добавлена установка EFK стека в процесс первоначальной установки и настройки k8s

### 25.2 Как запустить проект

Предполагается, что на локальной машине установлены terraform, kubectl, helm

- Развернуть kubernetes в GKE, при этом будут развернуты tiller, prometheus, alertmanager, grafana, EFK

```bash
cd kubernetes/terraform
terraform init
terraform apply -auto-approve=true
cd kubernetes
terraform init
terraform apply -auto-approve=true
```

- После бутстрапа в grafana нужно создать `Prometheus server` datasource и импортировать `Business_Logic_Monitoring, Post_DB_stats, UI_Service_Monitoring, Kubernetes cluster monitoring, Kubernetes deployment metrics` дашборды из каталога `monitoring/grafana/dashboards`

- В kibana нужно создать шаблон индекса `fluentd-*`

### 25.3 Как проверить проект

- Получить внешний IP адрес приложений и изменить hosts файл

```bash
export HOSTS_ENTRY="$(kubectl get svc | grep nginx-nginx-ingress-controller | awk '{print $4}') reddit-prometheus reddit-grafana reddit-kibana"

echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts
```

при этом prometheus, grafana, kibana будут доступны по адресам <http://reddit-prometheus>, <http://reddit-grafana>, <http://reddit-kibana>

- Запустить несколько инстансов reddit приложения

```bash
helm upgrade reddit-test ./reddit —install
helm upgrade production --namespace production  ./reddit --install
helm upgrade staging --namespace staging  ./reddit —instal
```

- В дашбордах графаны `Business_Logic_Monitoring, Post_DB_stats, UI_Service_Monitoring` можно выбрать соответствующий namespace и получить метрики reddit приложения только для этого namespace

- Дашборды графаны `Kubernetes cluster monitoring, Kubernetes deployment metrics` отображают текущее состояние k8s

- При падении ноды k8s (например, выключении) срабатывает алерт `NodeDown` - оповещение должно приходить в slack канал и на почту

- В веб-интерфейсе kibana после создания индекса, доступны логи reddit приложений
