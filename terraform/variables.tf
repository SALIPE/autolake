variable "servervm_object" {
  type = map(object({
    name         = string
    tags         = list(string)
    ipv4_address = string
    memory       = number
    cpu_cores    = number
    disk_size    = number
  }))
}

variable "proxmox_nodename" {
  type = string
}

variable "proxmox_endpoint" {
  type = string
}

variable "ipv4_gateway" {
  type = string
}

variable "ipv4_prefix" {
  type = string
}

