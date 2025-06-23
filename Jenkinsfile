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
                    env.VERSION_TAG = "v${commitHash}"

                    sh """
                        docker build -t ${IMAGE_NAME}:${VERSION_TAG} .
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

        stage('Delete the pushed Image from local Jenkins Server'){
            steps{
                sh '''
                    docker rmi ${IMAGE_NAME}:${VERSION_TAG}
                '''
            }
        }

        stage('Deploy on cluster'){
            steps{
                withCredentials([file(credentialsId:'kubeconfig-jenkins', variable:'KUBECONFIGFILE')]){
                    sh """
                        cp k8/deployment.yaml deployment-temp.yaml
                        sed -i 's|IMAGE_TAG_PLACEHOLDER|${VERSION_TAG}|' deployment-temp.yaml

                        kubectl apply -f deployment-temp.yaml
                        kubectl apply -f k8/service.yaml

                        rm deployment-temp.yaml
                    """

                }
            }
        }
    }

    post {
        success {
            echo "Workflow Completed with ${IMAGE_NAME}:${VERSION_TAG}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
