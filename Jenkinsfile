pipeline {
    agent any

    environment {
        IMAGE_NAME = "vinukavinnath/hellospringboot"
        DOCKER_CREDENTIALS_ID = "dockerhub-pat"
    }

    stages {
//     No need of this checkout stage as in the Jenkins server we are defining the git repo and credentials
//         stage('Checkout') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/vinukavinnath/demo-spring-app.git'
//             }
//         }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.LATEST_TAG = "latest"
                    env.VERSION_TAG = "v${commitHash}"

                    sh """
                        docker build -t ${IMAGE_NAME}:${VERSION_TAG} .
                        docker tag ${IMAGE_NAME}:${VERSION_TAG} ${IMAGE_NAME}:${LATEST_TAG}
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
                        docker push ${IMAGE_NAME}:${LATEST_TAG}
                    '''
                }
            }
        }

        stage('Deploy on cluster'){
            steps{
                withCredentials([file(credentialsId:'kubeconfig-jenkins', variable:'KUBECONFIGFILE')]){
                    sh '''
                        kubectl apply -f k8/deployment.yaml
                        kubectl apply -f k8/service.yaml
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
