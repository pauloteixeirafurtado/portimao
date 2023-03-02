variable "windows_server" {
  type = string
  default = "ami-039965e18092d85cb"
}

variable "rh_based" {
  type = string
  default = "ami-0b029b1931b347543"
}

variable "deb_based" {
  type = string
  default = "ami-0735c191cf914754d"
}

variable "avail_zone" {
  type = string
  default = "us-west-2a"
}

variable "vpc_ep_svc_name" {
  type = string
  default = "com.amazonaws.us-west-2.s3"
}
