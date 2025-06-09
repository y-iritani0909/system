# Terraform インフラストラクチャ

このディレクトリには、system アプリケーションのインフラストラクチャを管理する Terraform 設定が含まれています。

## 作成されるリソース

- **GKE Autopilot クラスター**: アプリケーションの実行環境
- **Artifact Registry**: Docker イメージの保存と管理

## ディレクトリ構造

```
terraform/
├── main.tf                    # メインのTerraform設定
├── variables.tf               # 変数定義
├── terraform.tfvars.example   # 変数の例
└── gke/                       # GKEモジュール
    ├── main.tf                # GKEクラスターのリソース定義
    ├── variables.tf           # GKE固有の変数
    └── terraform.tfvars.example
```

## 使用方法

### 1. 事前準備：API の有効化

**重要**: Terraform を実行する前に、以下の API を Google Cloud Console で手動で有効化してください：

1. **Kubernetes Engine API**

   - https://console.cloud.google.com/apis/library/container.googleapis.com?project=sandbox-milabo

2. **Compute Engine API**

   - https://console.cloud.google.com/apis/library/compute.googleapis.com?project=sandbox-milabo

3. **Artifact Registry API**
   - https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com?project=sandbox-milabo

### 2. 設定ファイルの準備

```bash
# terraform.tfvars ファイルを作成
cp terraform.tfvars.example terraform.tfvars

# 必要に応じて値を編集
vim terraform.tfvars
```

### 2. Terraform の初期化

```bash
terraform init
```

### 3. 実行計画の確認

```bash
terraform plan
```

### 4. インフラストラクチャの作成

```bash
terraform apply
```

## リソース

### Artifact Registry

Docker イメージを安全に保存・管理するためのプライベートレジストリです。

**設定内容:**

- リポジトリ名: `microfrontend`
- 形式: Docker
- 保持ポリシー: 最新 10 バージョンを保持
- 場所: asia-northeast1

### GKE モジュール

GKE Autopilot クラスターを作成します。

**設定内容:**

- GKE Autopilot モード
- プライベートクラスター設定
- VPC-native ネットワーキング
- マスター認証ネットワーク設定

## 出力値

| 出力名                         | 説明                           |
| ------------------------------ | ------------------------------ |
| `cluster_name`                 | 作成された GKE クラスター名    |
| `cluster_endpoint`             | GKE クラスターのエンドポイント |
| `artifact_registry_repository` | Artifact Registry リポジトリ名 |
| `artifact_registry_url`        | Docker イメージ push 用の URL  |

## 将来の拡張

このモジュラー構造により、以下のような追加インフラストラクチャを簡単に統合できます：

```
terraform/
├── main.tf
├── variables.tf
├── gke/              # GKEクラスター
├── database/         # Cloud SQL
├── storage/          # Cloud Storage
├── networking/       # VPC・サブネット
└── monitoring/       # Cloud Monitoring
```

## 変数

| 変数名         | 説明                    | デフォルト値      |
| -------------- | ----------------------- | ----------------- |
| `project_id`   | Google Cloud Project ID | -                 |
| `region`       | Google Cloud Region     | `asia-northeast1` |
| `zone`         | Google Cloud Zone       | `asia-northeast1` |
| `cluster_name` | GKE Cluster Name        | `system-cluster`  |

## バージョン管理

### コミットすべきファイル ✅

```
terraform/
├── main.tf                    # メインの設定
├── variables.tf               # 変数定義
├── terraform.tfvars.example   # 設定例
├── .terraform.lock.hcl        # 依存関係ロック
├── .gitignore                 # Git除外設定
├── README.md                  # ドキュメント
└── gke/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars.example
```

### コミット不要なファイル ❌

```
# 機密情報・状態ファイル
*.tfstate                      # Terraform状態ファイル
*.tfstate.backup               # 状態ファイルのバックアップ
terraform.tfvars               # 実際の設定値（機密情報）

# 一時ファイル・キャッシュ
.terraform/                    # プロバイダープラグイン
*.plan                         # 実行計画ファイル
crash.log                      # エラーログ
```

**重要**:

- `terraform.tfvars` には機密情報が含まれるためコミットしない
- `terraform.tfstate` にはリソース情報が含まれるためコミットしない
- `.terraform.lock.hcl` は依存関係の固定のためコミットする
