resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  # GKE Autopilotモードを使用
  enable_autopilot = true

  # ネットワーク設定
  network    = "form-vpc"
  subnetwork = "form-vpc"

  # IPアロケーションポリシー（自動割り当て）
  ip_allocation_policy {}

  # プライベートクラスター設定
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # マスター認証ネットワーク
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }
}

# Output values
output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
} 