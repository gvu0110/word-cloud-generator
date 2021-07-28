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
        NEXUS_CREDENTIAL_ID = '44aba9f8-e2ba-4056-915f-ca700aae7b78'
        ARTIFACTS_FILE = 'artifacts/word-cloud-generator.gz'
        VERSION_FILE = 'static/version'
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
        
        stage('Publish to Nexus') {
            steps {
                script {
                    def String versionFile = readFile("${WORKSPACE}/${VERSION_FILE}")
                    def jsonSlurper = new JsonSlurper()
                    def appVersion = jsonSlurper.parseText(versionFile)["version"]

                    def String artifactsPath = "${WORKSPACE}/${ARTIFACTS_FILE}"
                    File artifacts = new File(artifactsPath)
                    assert artifacts.exists() : "*** File ${artifactsPath} not found"
                    
                    println("*** File: ${artifactsPath}, version ${appVersion}")
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
                            file: artifactsPath,
                            type: 'gz']
                        ]
                    )
                }
            }
        }
    }
}