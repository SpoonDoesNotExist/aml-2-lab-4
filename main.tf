# YC_TOKEN, YC_CLOUD_ID и YC_FOLDER_ID передаются через окружение.
provider "yandex" {
  zone = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_vpc_network" "lab" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "lab" {
  name           = var.subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.lab.id
  v4_cidr_blocks = [var.subnet_cidr]
}

resource "yandex_vpc_security_group" "web" {
  name       = var.web_sg_name
  network_id = yandex_vpc_network.lab.id
  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "HTTP API"
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "worker" {
  name       = var.worker_sg_name
  network_id = yandex_vpc_network.lab.id
  ingress {
    description    = "SSH from the lab subnet only"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.subnet_cidr]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "web" {
  name        = var.web_name
  zone        = var.zone
  platform_id = var.platform_id
  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.lab.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web.id]
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init/web.yaml.tftpl", {
      ssh_user = var.ssh_user
      ssh_key  = trimspace(file(pathexpand(var.ssh_public_key_path)))
      image    = var.web_image
    })
  }
}

resource "yandex_compute_instance" "worker" {
  name        = var.worker_name
  zone        = var.zone
  platform_id = var.platform_id
  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.lab.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.worker.id]
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init/worker.yaml.tftpl", {
      ssh_user = var.ssh_user
      ssh_key  = trimspace(file(pathexpand(var.ssh_public_key_path)))
    })
  }
}
