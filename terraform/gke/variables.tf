variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "asia-northeast1"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "system-cluster"
} 