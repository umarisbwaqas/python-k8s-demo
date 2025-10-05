pipeline {
    agent any

    environment {
        IMAGE_NAME = "umarisbwaqas/python-k8s-demo"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKERFILE_PATH = "./app"
    }

    stages {
        stage('Validate') {
            steps {
                script {
                    if (!fileExists("${DOCKERFILE_PATH}/Dockerfile")) {
                        error("Dockerfile not found at ${DOCKERFILE_PATH}/Dockerfile")
                    }
                    echo "Dockerfile validated successfully"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${DOCKERFILE_PATH}") {
                    script {
                        try {
                            echo "Building Docker image..."
                            sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                            sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                        } catch (Exception e) {
                            error("Docker build failed: ${e.getMessage()}")
                        }
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds-id', 
                                                        usernameVariable: 'DOCKERHUB_USR', 
                                                        passwordVariable: 'DOCKERHUB_PSW')]) {
                            sh '''
                                set +x  # Hide commands from logs
                                echo "Logging into Docker Hub..."
                                echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin
                                set -x  # Show commands again
                                echo "Pushing Docker images..."
                                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                                docker push ${IMAGE_NAME}:latest
                            '''
                        }
                    } catch (Exception e) {
                        error("Docker push failed: ${e.getMessage()}")
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Cleanup local images to save disk space
                sh '''
                    docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                    docker rmi ${IMAGE_NAME}:latest || true
                    docker system prune -f || true
                '''
            }
            echo "Pipeline finished."
        }
        success {
            echo "Pipeline completed successfully! Image pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}