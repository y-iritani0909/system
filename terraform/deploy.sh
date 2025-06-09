#!/bin/bash

set -e

echo "🚀 Microfrontend システムをデプロイします..."

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 設定値の読み込み
if [ ! -f terraform.tfvars ]; then
    echo -e "${RED}❌ terraform.tfvars が見つかりません"
    echo -e "${YELLOW}💡 terraform.tfvars.example をコピーして設定してください${NC}"
    exit 1
fi

PROJECT_ID=$(grep project_id terraform.tfvars | cut -d'"' -f2)
REGION=$(grep region terraform.tfvars | cut -d'"' -f2 || echo "asia-northeast1")

echo -e "${BLUE}📋 設定情報:"
echo -e "   Project ID: ${PROJECT_ID}"
echo -e "   Region: ${REGION}${NC}"

# 1. Terraform でインフラを作成
echo -e "\n${YELLOW}🏗️  Terraform でインフラストラクチャを作成中...${NC}"
terraform init
terraform plan
terraform apply -auto-approve

# 2. kubectl の設定
echo -e "\n${YELLOW}⚙️  kubectl を設定中...${NC}"
CLUSTER_NAME=$(terraform output -raw cluster_name)
gcloud container clusters get-credentials ${CLUSTER_NAME} --region ${REGION} --project ${PROJECT_ID}

# 3. Artifact Registry の認証設定
echo -e "\n${YELLOW}🔐 Artifact Registry 認証を設定中...${NC}"
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# 4. Docker イメージをビルドしてプッシュ
echo -e "\n${YELLOW}🐳 Docker イメージをビルド・プッシュ中...${NC}"
REGISTRY_URL=$(terraform output -raw artifact_registry_url)

# system アプリ
cd ../..
docker build -f system/Dockerfile -t ${REGISTRY_URL}/system:latest .
docker push ${REGISTRY_URL}/system:latest

# aws アプリ
docker build -f csp/aws/Dockerfile -t ${REGISTRY_URL}/aws:latest --platform linux/amd64 .
docker push ${REGISTRY_URL}/aws:latest

# gcp アプリ  
docker build -f csp/gcp/Dockerfile -t ${REGISTRY_URL}/gcp:latest --platform linux/amd64 .
docker push ${REGISTRY_URL}/gcp:latest

cd system/terraform

echo -e "\n${GREEN}✅ デプロイが完了しました！${NC}"
echo -e "\n${BLUE}📋 次の手順:"
echo -e "   1. kubectl でアプリケーションをデプロイ"
echo -e "   2. Ingress を設定してアクセス可能にする${NC}"
echo -e "\n${BLUE}📊 リソース情報:"
echo -e "   Cluster: $(terraform output -raw cluster_name)"
echo -e "   Endpoint: $(terraform output -raw cluster_endpoint)"
echo -e "   Registry: $(terraform output -raw artifact_registry_url)${NC}" 