DOCKER_REGISTRY_USER ?= loktionovam

UI_DOCKER_DIR ?= src/ui
UI_DOCKER_IMAGE_NAME ?= ui
UI_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(UI_DOCKER_DIR)/Dockerfile)
UI_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(UI_DOCKER_IMAGE_NAME):$(UI_DOCKER_IMAGE_TAG)

POST_DOCKER_DIR ?= src/post-py
POST_DOCKER_IMAGE_NAME ?= post
POST_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(POST_DOCKER_DIR)/Dockerfile)
POST_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(POST_DOCKER_IMAGE_NAME):$(POST_DOCKER_IMAGE_TAG)

COMMENT_DOCKER_DIR ?= src/comment
COMMENT_DOCKER_IMAGE_NAME ?= comment
COMMENT_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(COMMENT_DOCKER_DIR)/Dockerfile)
COMMENT_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(COMMENT_DOCKER_IMAGE_NAME):$(COMMENT_DOCKER_IMAGE_TAG)

PROMETHEUS_DOCKER_DIR ?= monitoring/prometheus
PROMETHEUS_DOCKER_IMAGE_NAME ?= prometheus
PROMETHEUS_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(PROMETHEUS_DOCKER_DIR)/Dockerfile)
PROMETHEUS_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(PROMETHEUS_DOCKER_IMAGE_NAME):$(PROMETHEUS_DOCKER_IMAGE_TAG)

MONGODB_EXPORTER_DOCKER_DIR ?= monitoring/prometheus/mongodb_exporter
MONGODB_EXPORTER_DOCKER_IMAGE_NAME ?= mongodb_exporter
MONGODB_EXPORTER_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(MONGODB_EXPORTER_DOCKER_DIR)/Dockerfile)
MONGODB_EXPORTER_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(MONGODB_EXPORTER_DOCKER_IMAGE_NAME):$(MONGODB_EXPORTER_DOCKER_IMAGE_TAG)

BLACKBOX_EXPORTER_DOCKER_DIR ?= monitoring/prometheus/blackbox_exporter
BLACKBOX_EXPORTER_DOCKER_IMAGE_NAME ?= blackbox_exporter
BLACKBOX_EXPORTER_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(BLACKBOX_EXPORTER_DOCKER_DIR)/Dockerfile)
BLACKBOX_EXPORTER_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(BLACKBOX_EXPORTER_DOCKER_IMAGE_NAME):$(BLACKBOX_EXPORTER_DOCKER_IMAGE_TAG)

ALERTMANAGER_DOCKER_DIR ?= monitoring/alertmanager
ALERTMANAGER_DOCKER_IMAGE_NAME ?= alertmanager
ALERTMANAGER_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(ALERTMANAGER_DOCKER_DIR)/Dockerfile)
ALERTMANAGER_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(ALERTMANAGER_DOCKER_IMAGE_NAME):$(ALERTMANAGER_DOCKER_IMAGE_TAG)

TELEGRAF_DOCKER_DIR ?= monitoring/telegraf
TELEGRAF_DOCKER_IMAGE_NAME ?= telegraf
TELEGRAF_DOCKER_IMAGE_TAG ?= $(shell ./get_dockerfile_version.sh $(TELEGRAF_DOCKER_DIR)/Dockerfile)
TELEGRAF_DOCKER_IMAGE ?= $(DOCKER_REGISTRY_USER)/$(TELEGRAF_DOCKER_IMAGE_NAME):$(TELEGRAF_DOCKER_IMAGE_TAG)

build_reddit: ui_build post_build comment_build
build_monitoring: prometheus_build mongodb_exporter_build blackbox_exporter_build alertmanager_build telegraf_build
build: build_reddit build_monitoring

push_reddit: ui_push post_push comment_push
push_monitoring: prometheus_push mongodb_exporter_push blackbox_exporter_push alermanager_push telegraf_push
push: push_reddit push_monitoring

all: build push

ui_build: 
	@echo ">> building docker image $(UI_DOCKER_IMAGE)"
	@cd "$(UI_DOCKER_DIR)"; \
	echo `git show --format="%h" HEAD | head -1` > build_info.txt; \
	echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt; \
	docker build -t $(UI_DOCKER_IMAGE) .

ui_push:
	@echo ">> push $(UI_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(UI_DOCKER_IMAGE)"

ui: ui_build ui_push

post_build:
	@echo ">> building docker image $(POST_DOCKER_IMAGE)"
	@cd "$(POST_DOCKER_DIR)"; \
	echo `git show --format="%h" HEAD | head -1` > build_info.txt; \
	echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt; \
	docker build -t $(POST_DOCKER_IMAGE) .

post_push:
	@echo ">> push $(POST_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(POST_DOCKER_IMAGE)"

post: post_build post_push

comment_build:
	@echo ">> building docker image $(COMMENT_DOCKER_IMAGE)"
	@cd "$(COMMENT_DOCKER_DIR)"; \
	echo `git show --format="%h" HEAD | head -1` > build_info.txt; \
	echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt; \
	docker build -t $(COMMENT_DOCKER_IMAGE) .

comment_push:
	@echo ">> push $(COMMENT_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(COMMENT_DOCKER_IMAGE)"

comment: comment_build comment_push

prometheus_build:
	@echo ">> building docker image $(PROMETHEUS_DOCKER_IMAGE)"
	@cd "$(PROMETHEUS_DOCKER_DIR)"; \
	docker build -t $(PROMETHEUS_DOCKER_IMAGE) .

prometheus_push:
	@echo ">> push $(PROMETHEUS_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(PROMETHEUS_DOCKER_IMAGE)"

prometheus: prometheus_build prometheus_push

mongodb_exporter_build:
	@echo ">> building docker image $(MONGODB_EXPORTER_DOCKER_IMAGE)"
	@cd "$(MONGODB_EXPORTER_DOCKER_DIR)"; \
	docker build -t $(MONGODB_EXPORTER_DOCKER_IMAGE) .

mongodb_exporter_push:
	@echo ">> push $(MONGODB_EXPORTER_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(MONGODB_EXPORTER_DOCKER_IMAGE)"

mongodb_exporter: mongodb_exporter_build mongodb_exporter_push

blackbox_exporter_build:
	@echo ">> building docker image $(BLACKBOX_EXPORTER_DOCKER_IMAGE)"
	@cd "$(BLACKBOX_EXPORTER_DOCKER_DIR)"; \
	docker build -t $(BLACKBOX_EXPORTER_DOCKER_IMAGE) .

blackbox_exporter_push:
	@echo ">> push $(BLACKBOX_EXPORTER_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(BLACKBOX_EXPORTER_DOCKER_IMAGE)"

blackbox_exporter: blackbox_exporter_build blackbox_exporter_push

alertmanager_build:
	@echo ">> building docker image $(ALERTMANAGER_DOCKER_IMAGE)"
	@cd "$(ALERTMANAGER_DOCKER_DIR)"; \
	docker build -t $(ALERTMANAGER_DOCKER_IMAGE) .

alermanager_push:
	@echo ">> push $(ALERTMANAGER_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(ALERTMANAGER_DOCKER_IMAGE)"

alertmanager: alertmanager_build alermanager_push

telegraf_build:
	@echo ">> building docker image $(TELEGRAF_DOCKER_IMAGE)"
	@cd "$(TELEGRAF_DOCKER_DIR)"; \
	docker build -t $(TELEGRAF_DOCKER_IMAGE) .

telegraf_push:
	@echo ">> push $(TELEGRAF_DOCKER_IMAGE) docker image to dockerhub"
	@docker push "$(TELEGRAF_DOCKER_IMAGE)"

telegraf: telegraf_build telegraf_push

up_reddit: build_reddit
	@echo ">> Create and start microservices via docker compose"
	@cd docker; docker-compose up -d

up_monitoring: build_monitoring
	@echo ">> Create and start monitoring microservices via docker compose"
	@cd docker; docker-compose -f docker-compose-monitoring.yml up -d

down_reddit:
	@echo ">> Stop and remove containers, networks, images, and volumes via docker compose"
	@cd docker; docker-compose down

down_monitoring:
	@echo ">> Stop and remove containers monitoring via docker compose"
	@cd docker; docker-compose -f docker-compose-monitoring.yml down

up: up_reddit up_monitoring

down: down_monitoring down_reddit

.PHONY: all build push up down up_monitoring up_reddit down_monitoring down_reddit build_reddit build_monitoring\
ui_build ui_push ui \
post_build post_push post \
comment_build comment_push comment \
prometheus prometheus_build prometheus_push \
mongodb_exporter_build mongodb_exporter_push mongodb_exporter \
blackbox_exporter blackbox_exporter_build blackbox_exporter_push \
alertmanager alertmanager_build alermanager_push \
telegraf telegraf_build telegraf_push
