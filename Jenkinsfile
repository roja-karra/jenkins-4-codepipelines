pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'us-west-2'
        CLUSTER_NAME = 'my-cluster'
        INGRESS_NAMESPACE = 'ingress-controller'
        CREATE_KMS_ALIAS = true // Set to true if you want to create KMS alias
        CREATE_CLOUDWATCH_LOG_GROUP = true // Set to true if you want to create CloudWatch log group
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -reconfigure'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Add conditional logic for KMS alias creation
                    def createKmsAlias = env.CREATE_KMS_ALIAS ? '-var create_kms_alias=true' : '-var create_kms_alias=false'
                    
                    // Add conditional logic for CloudWatch log group creation
                    def createCloudWatchLogGroup = env.CREATE_CLOUDWATCH_LOG_GROUP ? '-var create_cloudwatch_log_group=true' : '-var create_cloudwatch_log_group=false'

                    // Run Terraform apply with conditional flags
                    sh "terraform apply -auto-approve $createKmsAlias $createCloudWatchLogGroup"
                }
            }
        }

        stage('Get EKS Cluster Credentials') {
            steps {
                script {
                    sh 'aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION'
                }
            }
        }

        stage('Add Ingress Nginx Helm Repository') {
            steps {
                script {
                    sh 'helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx'
                    sh 'helm repo update'
                }
            }
        }

        stage('Create Ingress Namespace') {
            steps {
                script {
                    def namespaceExists = sh(script: "kubectl get namespace $INGRESS_NAMESPACE", returnStatus: true)
                    if (namespaceExists != 0) {
                        sh "kubectl create namespace $INGRESS_NAMESPACE"
                    }
                }
            }
        }

        stage('Upgrade or Install Ingress Nginx') {
            steps {
                script {
                    sh 'helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --version 4.10.1 --namespace $INGRESS_NAMESPACE --set-string controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-type"="nlb"'
                }
            }
        }

        stage('Add Helm Repositories') {
            steps {
                script {
                    sh 'helm repo add stable https://charts.helm.sh/stable'
                    sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
                }
            }
        }

        stage('Create and Install Prometheus') {
            steps {
                script {
                    def prometheusNamespaceExists = sh(script: "kubectl get namespace prometheus", returnStatus: true)
                    if (prometheusNamespaceExists != 0) {
                        sh "kubectl create namespace prometheus"
                        sh 'helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus'
                    }
                }
            }
        }

        stage('Check Prometheus Pods') {
            steps {
                script {
                    sh 'kubectl get pods -n prometheus'
                }
            }
        }

        stage('Check Prometheus Services') {
            steps {
                script {
                    sh 'kubectl get svc -n prometheus'
                }
            }
        }
        
        stage('Destroy') {
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}
