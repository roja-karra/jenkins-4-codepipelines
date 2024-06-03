pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/roja-karra/jenkins-4-codepipelines.git', branch: 'main'
            }
        }

        stage('Init') {
            steps {
                sh 'terraform init -backend-config="bucket=p2-revhire-s3-bucket" -backend-config="key=terraform.tfstate" -backend-config="region=us-west-2" -backend-config="dynamodb_table=p2-dynamo-db" -backend-config="encrypt=true"'
            }
        }

        stage('Plan') { // Refresh is implicitly handled in plan
            steps {
                sh 'terraform plan -out=plan.out'
            }
        }

        stage('Apply') {
            steps {
                sh 'terraform apply -input=false plan.out'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
