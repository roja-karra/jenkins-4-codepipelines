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
                 sh '/usr/local/bin/terraform init'
            }
        }

        stage('Refresh') {
            steps {
                sh 'terraform refresh'
            }
        }

        stage('Plan') {
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