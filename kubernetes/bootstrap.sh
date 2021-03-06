#!/usr/bin/env bash
set -x
CLUSTER_NAME=$1
ZONE=$2
PROJECT=$3
SCRIPT_DIR=$(dirname $(realpath "$0"))
BOOTSTRAP_DIR="${SCRIPT_DIR}"/bootstrap
CHART_DIR="${SCRIPT_DIR}"/charts

GRAFANA_PASSWD=$(cat /dev/urandom| tr -c -d '[:alnum:]' | head -c 12)

gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "${ZONE}" --project "${PROJECT}"
gcloud beta container clusters update "${CLUSTER_NAME}" --monitoring-service none
gcloud beta container clusters update "${CLUSTER_NAME}" --logging-service none

kubectl apply -f "${BOOTSTRAP_DIR}"/cluster-admin-rolebinding.yaml
kubectl apply -f "${BOOTSTRAP_DIR}"/kubernetes-dashboard-rolebinding.yaml
kubectl apply -f "${BOOTSTRAP_DIR}"/kubernetes-dashboard.yaml
kubectl apply -f "${BOOTSTRAP_DIR}"/tiller.yaml

helm init --wait --service-account tiller
helm repo add gitlab https://charts.gitlab.io

helm install stable/nginx-ingress --name nginx
helm install --wait --name gitlab "${CHART_DIR}"/gitlab-omnibus -f "${CHART_DIR}"/gitlab-omnibus/values.yaml
helm upgrade --wait prom "${CHART_DIR}"/prometheus -f "${CHART_DIR}"/prometheus/custom_values.yml --install

# Get your 'admin' user password by running:
# kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
helm upgrade --install grafana stable/grafana --set "adminPassword=${GRAFANA_PASSWD}" --set "service.type=NodePort" --set "ingress.enabled=true" --set "ingress.hosts={reddit-grafana}"

helm dependency update "${CHART_DIR}"/efk

helm upgrade --wait --install logging "${CHART_DIR}"/efk

