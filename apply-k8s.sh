#!/bin/bash

# Kubernetesマニフェストを適用するスクリプト
set -e  # エラー時に停止

# 色付きログ用の関数
log_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

log_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

# kubectlが利用可能かチェック
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl コマンドが見つかりません"
        exit 1
    fi
    
    # Kubernetesクラスターへの接続確認
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Kubernetesクラスターに接続できません"
        log_info "gcloud container clusters get-credentials を実行してください"
        exit 1
    fi
}

# ファイル存在チェック
check_files() {
    local files=("k8s/deployment.yaml" "k8s/service.yaml" "k8s/backend-config.yaml" "k8s/ingress.yaml")
    
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "ファイルが見つかりません: $file"
            exit 1
        fi
    done
    log_success "すべてのマニフェストファイルが存在します"
}

# メイン処理
main() {
    log_info "=== Kubernetes マニフェスト適用開始 ==="
    
    # 事前チェック
    log_info "kubectl と接続性をチェック中..."
    check_kubectl
    log_success "kubectl 接続確認完了"
    
    log_info "マニフェストファイル存在確認中..."
    check_files
    
    # 現在のコンテキスト表示
    local current_context=$(kubectl config current-context)
    log_info "現在のKubernetesコンテキスト: $current_context"
    
    # 確認プロンプト
    echo
    read -p "このコンテキストでマニフェストを適用しますか? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_warning "処理を中断しました"
        exit 0
    fi
    
    echo
    log_info "マニフェストを適用中..."
    
    # 1. BackendConfig を最初に適用 (Serviceで参照されるため)
    log_info "1/4: BackendConfig を適用中..."
    kubectl apply -f k8s/backend-config.yaml
    log_success "BackendConfig 適用完了"
    
    # 2. Deployment を適用
    log_info "2/4: Deployment を適用中..."
    kubectl apply -f k8s/deployment.yaml
    log_success "Deployment 適用完了"
    
    # 3. Service を適用
    log_info "3/4: Service を適用中..."
    kubectl apply -f k8s/service.yaml
    log_success "Service 適用完了"
    
    # 4. Ingress を最後に適用 (Serviceが必要なため)
    log_info "4/4: Ingress を適用中..."
    kubectl apply -f k8s/ingress.yaml
    log_success "Ingress 適用完了"
    
    echo
    log_success "=== すべてのマニフェスト適用完了 ==="
    
    # リソース状態確認
    echo
    log_info "リソース状態確認:"
    echo "--- Pods ---"
    kubectl get pods -l app=system --no-headers 2>/dev/null || log_warning "Podが見つかりません"
    
    echo "--- Services ---"
    kubectl get service system-service --no-headers 2>/dev/null || log_warning "Serviceが見つかりません"
    
    echo "--- Ingress ---"
    kubectl get ingress microfrontend-ingress --no-headers 2>/dev/null || log_warning "Ingressが見つかりません"
    
    echo
    log_info "詳細なステータス確認:"
    log_info "kubectl get all -l app=system"
    log_info "kubectl describe ingress microfrontend-ingress"
}

# スクリプト実行
main "$@" 