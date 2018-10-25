#!/usr/bin/env bash
set -x
CLUSTER_NAME=$1
ZONE=$2
PROJECT=$3
SCRIPT_DIR=$(dirname $(realpath "$0"))
BOOTSTRAP_DIR="${SCRIPT_DIR}"/bootstrap
CHART_DIR="${SCRIPT_DIR}"/charts
gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "${ZONE}" --project "${PROJECT}"

kubectl apply -f "${BOOTSTRAP_DIR}"/cluster-admin-rolebinding.yml
kubectl apply -f "${BOOTSTRAP_DIR}"/kubernetes-dashboard-rolebinding.yml
kubectl apply -f "${BOOTSTRAP_DIR}"/tiller.yml

helm init --wait --service-account tiller
helm repo add gitlab https://charts.gitlab.io

helm install --wait --name gitlab "${CHART_DIR}"/gitlab-omnibus -f "${CHART_DIR}"/gitlab-omnibus/values.yaml
