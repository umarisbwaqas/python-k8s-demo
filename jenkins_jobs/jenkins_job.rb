job('build-and-deploy-python-app') do
  scm do
    git('https://github.com/yourusername/python-k8s-demo.git')
  end
  triggers do
    githubPush()
  end
  steps do
    shell <<-SHELL
      echo "Building Docker image..."
      docker build -t your_dockerhub_username/python-k8s-demo:latest .

      echo "Logging in to Docker Hub..."
      echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

      echo "Pushing image to Docker Hub..."
      docker push your_dockerhub_username/python-k8s-demo:latest

      echo "Deploying to Kubernetes..."
      kubectl apply -f k8s-deployment.yaml
    SHELL
  end
end