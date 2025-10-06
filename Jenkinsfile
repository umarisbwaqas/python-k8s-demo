pipeline {
    agent any

    environment {
        IMAGE_NAME = "umarisbwaqas/python-k8s-demo"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKERFILE_PATH = "./app"
        K8S_NAMESPACE = "default"
        K8S_DEPLOYMENT = "python-k8s-demo"
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

        stage('Code Analysis') {
            steps {
                script {
                    try {
                        echo "Running SonarQube analysis..."
                        withSonarQubeEnv('sonarqube') {
                            sh '''
                                sonar-scanner \
                                    -Dsonar.projectKey=python-k8s-demo \
                                    -Dsonar.projectName="Python K8s Demo" \
                                    -Dsonar.sources=app/ \
                                    -Dsonar.host.url=http://sonarqube:9000 \
                                    -Dsonar.python.coverage.reportPaths=coverage.xml
                            '''
                        }
                    } catch (Exception e) {
                        echo "SonarQube analysis failed: ${e.getMessage()}"
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
                                docker logout
                            '''
                        }
                    } catch (Exception e) {
                        error("Docker push failed: ${e.getMessage()}")
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        echo "Deploying to Kubernetes..."
                        
                        // Update image tag in k8s manifest and apply
                        sh '''
                            sed "s|image: ${IMAGE_NAME}.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/k8s-deployment.yml > k8s/k8s-deployment-updated.yml
                            kubectl apply -f k8s/k8s-deployment.yml
                        '''
                        
                        // Wait for rollout to complete
                        sh '''
                            kubectl rollout status deployment/${K8S_DEPLOYMENT} \
                                -n ${K8S_NAMESPACE} --timeout=300s
                        '''
                        
                        echo "Deployment successful!"
                    } catch (Exception e) {
                        error("Kubernetes deployment failed: ${e.getMessage()}")
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
                    rm -f k8s/k8s-deployment-updated.yml || true
                '''
            }
            echo "Pipeline finished."
        }
        success {
            echo "Pipeline completed successfully!"
            echo "Image pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "Deployed to Kubernetes cluster"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}