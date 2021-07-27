pipeline {
    tools {
        go 'go1.16.6'
    }
    environment {
        GO111MODULE = 'on'
    }
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'sed -i "s/1.DEVELOPMENT/1.$BUILD_NUMBER/g" ./static/version'
                sh 'make init'
                sh 'make lint'
                sh 'make unittest'
                sh 'make build'
                sh 'md5sum ./artifacts/word-cloud-generator'
            }
        }
    }
}