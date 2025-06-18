pipeline {
    agent any

    environment {
        IMAGE_NAME = "vinukavinnath/hellospringboot"
        DOCKER_CREDENTIALS_ID = "dockerhub-pat"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/vinukavinnath/demo-spring-app.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def versionTag = "v${commitHash}"
                    env.VERSION_TAG = versionTag

                    sh """
                        docker build -t ${IMAGE_NAME}:${versionTag} .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS_ID}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${VERSION_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Docker image pushed successfully: ${IMAGE_NAME}:${VERSION_TAG}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
