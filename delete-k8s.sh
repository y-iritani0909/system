#!/bin/bash

# Kubernetesマニフェストを削除するスクリプト
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

# メイン処理
main() {
    log_info "=== Kubernetes マニフェスト削除開始 ==="
    
    # 事前チェック
    log_info "kubectl と接続性をチェック中..."
    check_kubectl
    log_success "kubectl 接続確認完了"
    
    # 現在のコンテキスト表示
    local current_context=$(kubectl config current-context)
    log_info "現在のKubernetesコンテキスト: $current_context"
    
    # 確認プロンプト
    echo
    log_warning "以下のリソースが削除されます:"
    echo "- Ingress: microfrontend-ingress"
    echo "- Service: system-service"
    echo "- Deployment: system"
    echo "- BackendConfig: system-backend-config"
    echo
    read -p "本当に削除しますか? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_warning "処理を中断しました"
        exit 0
    fi
    
    echo
    log_info "マニフェストを削除中..."
    
    # 逆順で削除（依存関係を考慮）
    
    # 1. Ingress を最初に削除
    log_info "1/4: Ingress を削除中..."
    kubectl delete -f k8s/ingress.yaml --ignore-not-found=true
    log_success "Ingress 削除完了"
    
    # 2. Service を削除
    log_info "2/4: Service を削除中..."
    kubectl delete -f k8s/service.yaml --ignore-not-found=true
    log_success "Service 削除完了"
    
    # 3. Deployment を削除
    log_info "3/4: Deployment を削除中..."
    kubectl delete -f k8s/deployment.yaml --ignore-not-found=true
    log_success "Deployment 削除完了"
    
    # 4. BackendConfig を最後に削除
    log_info "4/4: BackendConfig を削除中..."
    kubectl delete -f k8s/backend-config.yaml --ignore-not-found=true
    log_success "BackendConfig 削除完了"
    
    echo
    log_success "=== すべてのマニフェスト削除完了 ==="
    
    # クリーンアップ確認
    echo
    log_info "クリーンアップ確認中..."
    
    # 残存リソース確認
    local remaining_pods=$(kubectl get pods -l app=system --no-headers 2>/dev/null | wc -l || echo "0")
    if [[ $remaining_pods -gt 0 ]]; then
        log_warning "まだ $remaining_pods 個のPodが残っています（削除中の可能性があります）"
    else
        log_success "すべてのPodが削除されました"
    fi
    
    echo
    log_info "確認コマンド:"
    log_info "kubectl get all -l app=system"
}

# スクリプト実行
main "$@" 