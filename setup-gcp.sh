#!/bin/bash

# 設定変数
PROJECT_ID="sandbox-milabo"

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

print_info "GCP環境をセットアップします..."

# 1. プロジェクトを設定
print_info "プロジェクトを設定します..."
gcloud config set project ${PROJECT_ID}

# 2. 必要なAPIを有効化
print_info "必要なAPIを有効化します..."
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# 3. 現在のユーザーを取得
CURRENT_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
print_info "現在のユーザー: ${CURRENT_USER}"

# 4. 必要なIAM権限を付与
print_info "必要なIAM権限を付与します..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${CURRENT_USER}" \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${CURRENT_USER}" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${CURRENT_USER}" \
    --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${CURRENT_USER}" \
    --role="roles/cloudbuild.builds.editor"

# 5. Artifact Registryリポジトリを作成
print_info "Artifact Registryリポジトリを作成します..."
gcloud artifacts repositories create microfrontend-test \
    --repository-format=docker \
    --location=asia-northeast1 \
    --description="Microfrontend test repository" || true

# 6. Docker認証を設定
print_info "Docker認証を設定します..."
gcloud auth configure-docker asia-northeast1-docker.pkg.dev

print_success "GCP環境のセットアップが完了しました！"
print_info "これでTerraformまたはgcloudコマンドでGKEクラスターを作成できます。" 