
module "kubernetes_cluster" {
    source = "./eks/"
    region = "us-east-1"
    cluster_name = "kudo"

}

provider "kudo" {
    kudo_version = "0.11.0"
    host = module.kubernetes_cluster.cluster_endpoint
    token = module.kubernetes_cluster.token
    cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_certificate
    load_config_file = false
}


resource "kudo_operator" "zookeeper" {
    operator_name = "zookeeper"
    skip_instance = true

    
     depends_on = [module.kubernetes_cluster]
}


resource "kudo_instance" "zk1" {
    name = "zook"
    parameters = {
        "NODE_COUNT": 3,
    }
    operator_version_name = kudo_operator.zookeeper.object_name

}

locals {
    zkConnection = join(",",formatlist("%s.${kudo_instance.zk1.name}-hs:${kudo_instance.zk1.output_parameters.CLIENT_PORT}", kudo_instance.zk1.pods[*]))
}


resource "kudo_operator" "microservice" {
    operator_name = "service" # local path
    skip_instance = true

    depends_on = [module.kubernetes_cluster]
}

resource "kudo_instance" "app" {
    name = "info"
    operator_version_name = kudo_operator.microservice.object_name
    parameters = {
        image = "runyonsolutions/request-log"
        tag = "0.3"
        replicas = 3
        prefix = "ZOOKEEPER:\n"
        postfix = local.zkConnection
        port = "8080"
    }

}

resource "kubernetes_pod" "watcher" {
  metadata {
    name = "watcher"
  }

  spec {
    container {
      image = "runyonsolutions/http-getter:0.2"
      name  = "getter"
      env {
        name  = "URL"
        value = "http://info:8080/"
      }
      env {
        name = "JUST_BODY"
        value = "true"
      }
    }
  }

  
   depends_on = [module.kubernetes_cluster]
}
