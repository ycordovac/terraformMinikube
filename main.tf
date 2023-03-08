resource "kubernetes_namespace" "jenkinsns1" {
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
    namespace = "jenkinsns1"
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
        }
      }
    }
  }    
}

resource "kubernetes_service" "jenkinsservice" {
  metadata {
    name = "jenkinsservice"
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
