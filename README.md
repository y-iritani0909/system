# System アプリケーション

Microfrontend アーキテクチャにおけるシステム管理・コントロールパネル機能を提供する Next.js アプリケーションです。

## 概要

- **技術スタック**: Next.js 15, React 19, TypeScript, Tailwind CSS
- **アーキテクチャ**: Microfrontend
- **デプロイ環境**: Google Kubernetes Engine (GKE)
- **コンテナ**: Docker + Artifact Registry

## ディレクトリ構造

```
system/
├── src/                       # ソースコード
│   ├── pages/                 # Next.js ページ
│   │   ├── index.tsx          # ホームページ
│   │   ├── system.tsx         # システムページ
│   │   ├── _app.tsx           # アプリケーション設定
│   │   ├── _document.tsx      # HTML ドキュメント設定
│   │   └── api/               # API ルート
│   └── styles/                # スタイル
├── public/                    # 静的ファイル
├── k8s/                       # Kubernetes マニフェスト
│   ├── deployment.yaml        # デプロイメント設定
│   └── service.yaml           # サービス設定
├── terraform/                 # インフラストラクチャ管理
│   ├── main.tf                # メイン設定
│   ├── variables.tf           # 変数定義
│   ├── gke/                   # GKE モジュール
│   └── README.md              # Terraform 詳細ドキュメント
├── Dockerfile                 # 本番用 Docker 設定
├── Dockerfile.dev             # 開発用 Docker 設定
├── deploy.sh                  # GKE デプロイスクリプト
├── setup-gcp.sh               # GCP 環境セットアップ
├── DEPLOY.md                  # デプロイ詳細手順
└── package.json               # 依存関係・スクリプト
```

## 開発環境

### 前提条件

- Node.js 18 以上
- npm または yarn
- Docker（オプション）

### ローカル開発

```bash
# 依存関係のインストール
npm install

# 開発サーバーの起動
npm run dev

# ブラウザで http://localhost:3000 を開く
```

### 利用可能なスクリプト

```bash
npm run dev      # 開発サーバー起動（Turbopack使用）
npm run build    # 本番ビルド
npm run start    # 本番サーバー起動
npm run lint     # ESLint チェック
```

## Docker 開発環境

### 開発用コンテナ

```bash
# 開発用イメージをビルド
docker build -f Dockerfile.dev -t system-dev .

# 開発用コンテナを起動
docker run -p 3000:3000 -v $(pwd):/app system-dev
```

### Docker Compose

プロジェクトルートの `compose.yml` を使用：

```bash
# プロジェクトルートから実行
docker compose up system
```

## デプロイ

### GKE デプロイ

詳細は [DEPLOY.md](./DEPLOY.md) を参照してください。

#### クイックデプロイ

```bash
# 1. GCP環境のセットアップ
./setup-gcp.sh

# 2. デプロイ実行
./deploy.sh
```

#### 手動デプロイ

```bash
# 1. Docker イメージのビルド・プッシュ
docker build -t asia-northeast1-docker.pkg.dev/sandbox-milabo/microfrontend-test/system:latest .
docker push asia-northeast1-docker.pkg.dev/sandbox-milabo/microfrontend-test/system:latest

# 2. Kubernetes デプロイ
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### インフラストラクチャ管理

Terraform を使用したインフラ管理：

```bash
cd terraform

# インフラの作成
terraform init
terraform plan
terraform apply

# 詳細は terraform/README.md を参照
```

## 設定

### 環境変数

| 変数名     | 説明       | デフォルト値  |
| ---------- | ---------- | ------------- |
| `NODE_ENV` | 実行環境   | `development` |
| `PORT`     | ポート番号 | `3000`        |

### Next.js 設定

- **出力モード**: Standalone（Docker 対応）
- **React Strict Mode**: 有効
- **Turbopack**: 開発時に使用

## トラブルシューティング

### よくある問題

1. **ポート競合**

   ```bash
   lsof -ti:3000 | xargs kill -9
   ```

2. **依存関係の問題**

   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

3. **Docker ビルド失敗**
   ```bash
   docker system prune -a
   ```

### ログ確認

```bash
# ローカル開発
npm run dev

# Docker コンテナ
docker logs <container-id>

# Kubernetes Pod
kubectl logs -l app=system
```

## 関連ドキュメント

- [DEPLOY.md](./DEPLOY.md) - 詳細なデプロイ手順
- [terraform/README.md](./terraform/README.md) - インフラ管理
- [Next.js Documentation](https://nextjs.org/docs)

## ライセンス

プライベートプロジェクト
