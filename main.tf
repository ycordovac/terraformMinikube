resource "kubernetes_namespace" "jenkinsns" {
  metadata {
    name = "jenkinsns1"

  }
}

resource "kubernetes_deployment" "jenkinsdeploy" {
  metadata {
    name = "jenkinsdeploy"
    labels = {
      test = "jenkinslabel"
    }
    namespace = kubernetes_namespace.jenkinsns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "jenkinslabel"
      }
    }

    template {
      metadata {
        labels = {
          test = "jenkinslabel"
        }
      }

      spec {
        container {
          image = "jenkins:2.60.3-alpine"
          name  = "jenkins"
          port {
            container_port = 8080
          }
        }
      }
    }
  }    
}

resource "kubernetes_service" "jenkinsservice" {
  metadata {
    name = "jenkinsservice"
    namespace = kubernetes_namespace.jenkinsns.metadata[0].name
  }

  spec {
    selector = {
      app = "jenkinslabel"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "NodePort"
  }

}

# es necesario que este habilitado el addons ingress en minikube con el comando minikube addons enable ingress
resource "kubernetes_ingress" "jenkinsingress" {
  metadata {
    name = "jenkinsingress"
    namespace = kubernetes_namespace.jenkinsns.metadata[0].name
  }

  spec {
    rule {
      host = "jenkins.yandihlg.es"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.jenkinsservice.metadata[0].name
            service_port = kubernetes_service.jenkinsservice.spec[0].port[0].target_port
          }
        }
      }
    }
  }
}
