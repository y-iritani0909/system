#!/bin/bash

# 設定変数
PROJECT_ID="sandbox-milabo"
CLUSTER_NAME="system-cluster"
ZONE="asia-northeast1-a"
REGION="asia-northeast1"
IMAGE_NAME="system"
IMAGE_TAG="latest"
REGISTRY="asia-northeast1-docker.pkg.dev"
REPOSITORY="microfrontend-test"

# 色付きの出力用関数
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# エラーハンドリング
set -e

print_info "GKEデプロイスクリプトを開始します..."

# 1. Docker イメージをビルド
print_info "Docker イメージをビルドします..."
docker build -t ${REGISTRY}/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG} .

# 2. イメージをArtifact Registryにプッシュ
print_info "イメージをArtifact Registryにプッシュします..."
docker push ${REGISTRY}/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}

# 3. GKEクラスターに接続
print_info "GKEクラスターに接続します..."
gcloud container clusters get-credentials ${CLUSTER_NAME} --region=${REGION} --project=${PROJECT_ID}

# 4. Kubernetesリソースをデプロイ
print_info "Kubernetesリソースをデプロイします..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# 5. デプロイメント状況を確認
print_info "デプロイメント状況を確認します..."
kubectl rollout status deployment/system

# 6. サービスの外部IPを取得
print_info "サービスの外部IPを取得中..."
kubectl get service system-service

print_success "デプロイが完了しました！"
print_info "外部IPが割り当てられるまでしばらくお待ちください。"
print_info "ステータス確認: kubectl get service system-service" 