pipeline {
  agent any

  environment {
    AWS_REGION   = 'ap-south-1'
    ECR_REGISTRY = '156916773321.dkr.ecr.ap-south-1.amazonaws.com'
    ECR_REPO     = 'jayamaran/sample-for-ecs'
    IMAGE_TAG    = 'latest'
    GIT_CREDENTIALS = 'github-token'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/Sedin-Jayamaran/CI-CD-Buggy.git'
      }
    }

    stage('Docker Login to ECR') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'aws-userpass-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh '''
            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
            aws configure set region $AWS_REGION
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t $ECR_REPO:$IMAGE_TAG .
          docker tag $ECR_REPO:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Push Docker Image to ECR') {
      steps {
        sh '''
          docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Deploy to ECS') {
      steps {
        sh '''
          aws ecs update-service \
            --cluster Jai-Manual-Cluster \
            --service jai-ecs-web \
            --force-new-deployment \
            --region $AWS_REGION
        '''
      }
    }
  }
}
