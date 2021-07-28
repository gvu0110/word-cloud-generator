import groovy.json.JsonSlurper

pipeline {
    tools {
        go 'go1.16.6'
    }
    environment {
        GO111MODULE = 'on'
        NEXUS_VERSION = 'nexus3'
        NEXUS_PROTOCOL = 'http'
        NEXUS_URL = 'nexus:8081'
        NEXUS_GROUP_ID = 'cd_class'
        NEXUS_REPOSITORY = 'word-cloud-generator'
        NEXUS_CREDENTIAL_ID = 'nexus-user-credentials'
        ARTIFACT_PATH = './artifacts/word-cloud-generator'
        VERSION_PATH = './static/version'
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
        
        stage('Publish to Nexus Repository Manager') {
            steps {
                script {
                    def versionFile = readFile(VERSION_PATH);
                    def jsonSlurper = new JsonSlurper();
                    appVersion = jsonSlurper.parseText(versionFile)["version"];
                    def artifact = new File(ARTIFACT_PATH);
                    if (artifact.exists()) {
                        println("*** File: ${ARTIFACT_PATH}, version ${appVersion}");
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: NEXUS_GROUP_ID,
                            version: appVersion,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: 'word-cloud-generator',
                                classifier: '',
                                file: artifactPath,
                                type: 'gz']
                            ]
                        );
                    } else {
                        println("*** File: ${ARTIFACT_PATH} could not be found");
                    }
                }
            }
        }
    }
}