# System Application

GKE 上で動作する Next.js 15 アプリケーション

## ディレクトリ構成

```
system/
├── k8s/                    # Kubernetesマニフェスト
│   ├── deployment.yaml     # アプリケーションデプロイメント
│   ├── service.yaml        # Kubernetesサービス
│   ├── backend-config.yaml # GCE BackendConfig
│   └── ingress.yaml        # Ingress設定
├── terraform/              # Terraformインフラ設定
│   ├── main.tf            # メインTerraform設定
│   ├── variables.tf       # 変数定義
│   └── gke/               # GKEクラスター設定
│       └── main.tf
├── apply-k8s.sh           # Kubernetesマニフェスト適用スクリプト
├── delete-k8s.sh          # Kubernetesマニフェスト削除スクリプト
└── README.md              # このファイル
```

## デプロイ手順

### 1. GKE クラスター作成

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. kubectl 設定

```bash
gcloud container clusters get-credentials system-cluster --zone asia-northeast1 --project sandbox-milabo
```

### 3. Kubernetes マニフェスト適用

```bash
# 自動適用スクリプトを使用（推奨）
./apply-k8s.sh

# または手動で適用
kubectl apply -f k8s/backend-config.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## スクリプト説明

### apply-k8s.sh

Kubernetes マニフェストを正しい順序で適用するスクリプト

**機能:**

- kubectl 接続確認
- ファイル存在チェック
- 現在のコンテキスト確認
- 依存関係を考慮した順序で適用:
  1. BackendConfig
  2. Deployment
  3. Service
  4. Ingress
- 適用後のリソース状態確認

**使用方法:**

```bash
./apply-k8s.sh
```

### delete-k8s.sh

Kubernetes マニフェストを安全に削除するスクリプト

**機能:**

- kubectl 接続確認
- 削除対象リソースの確認
- 依存関係を考慮した逆順で削除:
  1. Ingress
  2. Service
  3. Deployment
  4. BackendConfig
- 削除後のクリーンアップ確認

**使用方法:**

```bash
./delete-k8s.sh
```

## リソース確認

```bash
# すべてのリソース確認
kubectl get all -l app=system

# Pod詳細
kubectl describe pod -l app=system

# Ingress詳細
kubectl describe ingress microfrontend-ingress

# ログ確認
kubectl logs -l app=system
```

## パス書き換え設定

現在の Ingress 設定では、以下のパス書き換えが設定されています：

- `/system/*` → アプリケーションの `/` にマッピング
- `/csp/*` → アプリケーションの `/` にマッピング（将来用）

## トラブルシューティング

### よくある問題

1. **Pod が起動しない**

   ```bash
   kubectl describe pod -l app=system
   kubectl logs -l app=system
   ```

2. **Service に接続できない**

   ```bash
   kubectl get endpoints system-service
   ```

3. **Ingress の外部 IP が取得できない**

   ```bash
   kubectl describe ingress microfrontend-ingress
   ```

4. **502 エラー**
   - BackendConfig の設定確認
   - Pod の健全性確認
   - ヘルスチェックパスの確認

### ログレベル設定

```bash
# デバッグログ有効化
kubectl set env deployment/system LOG_LEVEL=debug

# ログ監視
kubectl logs -f -l app=system
```

## 設定値

- **アプリケーションポート**: 8080
- **サービスポート**: 80
- **コンテナイメージ**: `asia-northeast1-docker.pkg.dev/sandbox-milabo/microfrontend-test/system:latest`
- **レプリカ数**: 2
- **リソース制限**: CPU 500m, Memory 512Mi
