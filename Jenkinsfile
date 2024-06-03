pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'us-west-2'
        CLUSTER_NAME = 'my-cluster'
        INGRESS_NAMESPACE = 'ingress-controller'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/roja-karra/jenkins-4-codepipelines.git']]
                )
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                terraform init \
                    -backend-config="bucket=p2-revhire-s3-bucket" \
                    -backend-config="key=terraform.tfstate" \
                    -backend-config="region=us-west-2" \
                    -backend-config="dynamodb_table=p2-dynamo-db" \
                    -backend-config="encrypt=true"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    def planResult = sh(script: 'terraform plan -out=plan.out', returnStatus: true)
                    if (planResult != 0) {
                        echo 'Plan failed, attempting to unlock state'
                        sh 'terraform force-unlock 1c6a57a5-26e9-b180-58f0-c46dafca8c92'
                        sh 'terraform plan -out=plan.out'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve plan.out'
            }
        }

        stage('Configure AWS CLI') {
            steps {
                script {
                    sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                    sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                    sh 'aws configure set default.region $AWS_DEFAULT_REGION'
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
                    def namespaceExists = sh(script: "kubectl get namespace $INGRESS_NAMESPACE", returnStatus: true) == 0
                    if (namespaceExists) {
                        echo "Namespace $INGRESS_NAMESPACE already exists. Skipping creation."
                    } else {
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
                    def prometheusNamespaceExists = sh(script: "kubectl get namespace prometheus", returnStatus: true) == 0
                    if (prometheusNamespaceExists) {
                        echo "Namespace prometheus already exists. Skipping creation."
                    } else {
                        echo "Creating namespace prometheus..."
                        sh "kubectl create namespace prometheus"
                    }
                    echo "Installing Prometheus..."
                    sh 'helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n prometheus'
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
    
    post {
        always {
            cleanWs()
        }
    }
}
