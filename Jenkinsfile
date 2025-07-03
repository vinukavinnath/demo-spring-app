pipeline {
    agent any

    environment {
        IMAGE_NAME = "vinukavinnath/hellospringboot"
        DOCKER_CREDENTIALS_ID = "dockerhub-pat"
        GIT_CREDENTIALS_ID = "github-pat"
        MANIFEST_REPO = "https://github.com/vinukavinnath/demo-spring-app-manifest.git"
        MANIFEST_BRANCH = "main"
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

        stage('Vulnerability Scan') {
            steps {
                script {
                    def imageNameWithTag = "${IMAGE_NAME}:${VERSION_TAG}"

                    sh """
                        echo "Scanning Image for Vulnerabilities..."
                        trivy --timeout 1h --severity HIGH,CRITICAL --format table --output trivy-report.txt --scanners vuln image ${imageNameWithTag} || true

                        echo "---- Trivy Scan Report ----"
                        cat trivy-report.txt

                        # Check for HIGH or CRITICAL vulnerabilities in the report
                        if grep -qE 'CRITICAL|HIGH' trivy-report.txt; then
                            echo "Vulnerabilities of HIGH or CRITICAL severity were found!"
                        else
                            echo "Everything OK! Proceeding..."
                        fi
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

        stage('Update Manifest Repo') {
            steps{
                withCredentials([usernamePassword(
                    credentialsId: "${GIT_CREDENTIALS_ID}",
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_TOKEN')])
                        {
                            sh '''
                            rm -rf helm-repo
                            git clone -b ${MANIFEST_BRANCH} https://${GIT_USER}:${GIT_TOKEN}@${MANIFEST_REPO#https://} helm-repo

                            cd helm-repo
                            sed -i "s|tag:.*|tag: ${VERSION_TAG}|" values.yaml

                            git add .
                            git commit -m "Update image tag to ${VERSION_TAG}"
                            git push origin ${MANIFEST_BRANCH}
                            '''
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