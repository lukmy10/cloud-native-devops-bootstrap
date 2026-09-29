terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "digitalocean_token" {}
# Variable to pass your digitalocean token

variable "public_key" {}
# Variable to pass your public_key file path

provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

resource "digitalocean_ssh_key" "default" {
  name = "publickey"
   public_key = "${file("${var.public_key}")}"
}

resource "digitalocean_droplet" "server" {
  count = 1 

    name = "kserver01r01"
  image = "ubuntu-26-04-x64"
  size = "s-2vcpu-4gb"
  region = "fra1"
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

resource "digitalocean_droplet" "node" {
  count = 1 

    name = "knode01r01"
  image = "ubuntu-26-04-x64"
  size = "s-2vcpu-2gb"
  region = "fra1"
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

output "ipv4_public_s" {
  value = ["${digitalocean_droplet.server.*.ipv4_address}"]
}

output "ipv4_public_n" {
  value = ["${digitalocean_droplet.node.*.ipv4_address}"]
}
