pipeline {
    tools {
        go 'go1.16.6'
    }

    agent any
    stages {
        script {
            env.APP_VERSION = "1.$BUILD_NUMBER"
            def props = readProperties file: 'metadata.properties'
            env.NEXUS_VERSION = props.NEXUS_VERSION
            env.NEXUS_PROTOCOL = props.NEXUS_PROTOCOL
            env.NEXUS_URL = props.NEXUS_URL
            env.NEXUS_GROUP_ID = props.NEXUS_GROUP_ID
            env.NEXUS_REPOSITORY = props.NEXUS_REPOSITORY
            env.NEXUS_CREDENTIAL_ID = props.NEXUS_CREDENTIAL_ID
            env.NEXUS_ARTIFACT_ID = props.NEXUS_ARTIFACT_ID
            env.ARTIFACTS_FILE = props.ARTIFACTS_FILE
        }

        stage('Build') {
            steps {
                sh 'sed -i "s/1.DEVELOPMENT/$VERSION/g" ./static/version'
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
                    def String artifactsPath = "$WORKSPACE/$ARTIFACTS_FILE"
                    File artifacts = new File(artifactsPath)
                    assert artifacts.exists() : "*** File $artifactsPath not found"
                    
                    println("*** File: $artifactsPath, version $APP_VERSION")
                    nexusArtifactUploader(
                        nexusVersion: NEXUS_VERSION,
                        protocol: NEXUS_PROTOCOL,
                        nexusUrl: NEXUS_URL,
                        groupId: NEXUS_GROUP_ID,
                        version: APP_VERSION,
                        repository: NEXUS_REPOSITORY,
                        credentialsId: NEXUS_CREDENTIAL_ID,
                        artifacts: [
                            [artifactId: NEXUS_ARTIFACT_ID,
                            classifier: '',
                            file: artifactsPath,
                            type: 'gz']
                        ]
                    )
                }
            }
        }

        stage('Deploy to test fixture') {
            steps {
                sh '''
                    docker run --rm -it --name ansible --network="shared-backend" ansible:latest \
                        /usr/bin/ansible-playbook /etc/ansible/main.yml \
                        -i /etc/ansible/hosts.yml \
                        --extra-var "hosts=test_fixture, repository=$NEXUS_REPOSITORY, group=$NEXUS_GROUP_ID, version=$VERSION, artifactId=$NEXUS_ARTIFACT_ID, username=$NEXUS_USERNAME, password=$NEXUS_PASSWORD"
                '''
            }
        }
    }
}