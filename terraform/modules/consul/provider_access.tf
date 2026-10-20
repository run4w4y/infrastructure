variable "cloudflare_access_headers" {
  description = "Optional Cloudflare Access headers for administrative API requests."
  type        = map(string)
  default     = {}
  sensitive   = true
}
