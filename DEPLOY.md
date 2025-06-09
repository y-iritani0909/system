# System アプリ GKE デプロイ手順

## 前提条件

以下のツールがインストールされていることを確認してください：

- Docker
- Google Cloud CLI (gcloud)
- kubectl
- Terraform（オプション）

## 1. Google Cloud の認証

```bash
# Google Cloud にログイン
gcloud auth login

# Application Default Credentials を設定
gcloud auth application-default login

# プロジェクトを設定
gcloud config set project sandbox-milabo

# Docker を Artifact Registry に認証
gcloud auth configure-docker asia-northeast1-docker.pkg.dev
```

## 2. GKE クラスターの作成

### Option A: Terraform を使用する場合

```bash
cd terraform

# terraform.tfvars ファイルを作成
cp terraform.tfvars.example terraform.tfvars

# Terraform を初期化
terraform init

# 実行計画を確認
terraform plan

# クラスターを作成
terraform apply
```

### Option B: gcloud コマンドを使用する場合

```bash
# GKE Autopilot クラスターを作成
gcloud container clusters create-auto system-cluster \
    --region=asia-northeast1 \
    --project=sandbox-milabo
```

## 3. Docker イメージのビルドとプッシュ

```bash
# systemディレクトリに移動
cd system

# Docker イメージをビルド
docker build --platform linux/amd64 -t asia-northeast1-docker.pkg.dev/sandbox-milabo/microfrontend/system:latest .
# イメージをプッシュ
docker push asia-northeast1-docker.pkg.dev/sandbox-milabo/microfrontend/system:latest
```

## 4. GKE へのデプロイ

### Option A: デプロイスクリプトを使用

```bash
# systemディレクトリから実行
./deploy.sh
```

### Option B: 手動でデプロイ

```bash
# GKE クラスターに接続
gcloud container clusters get-credentials system-cluster \
    --region=asia-northeast1 \
    --project=sandbox-milabo

# Kubernetes リソースをデプロイ
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## 5. デプロイ状況の確認

```bash
# Pod の状況確認
kubectl get pods

# Service の状況確認
kubectl get services

# デプロイメントの状況確認
kubectl rollout status deployment/system

# 外部 IP の取得（LoadBalancer タイプの場合）
kubectl get service system-service
```

## 6. アプリケーションへのアクセス

LoadBalancer の外部 IP が割り当てられたら、ブラウザで以下の URL にアクセス：

```
http://<EXTERNAL-IP>
```

## トラブルシューティング

### Pod のログを確認

```bash
kubectl logs -l app=system
```

### Pod の詳細情報を確認

```bash
kubectl describe pod -l app=system
```

### イベントを確認

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

## リソースの削除

### Kubernetes リソースの削除

```bash
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/service.yaml
```

### GKE クラスターの削除

```bash
# Terraform を使用した場合
terraform destroy

# gcloud を使用した場合
gcloud container clusters delete system-cluster \
    --region=asia-northeast1 \
    --project=sandbox-milabo
```

## 設定ファイル

- `k8s/deployment.yaml`: Kubernetes Deployment 設定
- `k8s/service.yaml`: Kubernetes Service 設定（LoadBalancer）
- `deploy.sh`: 自動デプロイスクリプト
- `terraform/`: Terraform による GKE クラスター作成設定

## 使用するコンテナイメージ

```
asia-northeast1-docker.pkg.dev/sandbox-milabo/microfrontend-test/system:latest
```

## 設定情報

- **プロジェクト ID**: sandbox-milabo
- **リージョン**: asia-northeast1（東京）
- **クラスター名**: system-cluster
- **レジストリ**: asia-northeast1-docker.pkg.dev
- **リポジトリ**: microfrontend-test
