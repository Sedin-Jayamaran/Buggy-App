pipeline {
  agent any

  environment {
    AWS_REGION      = 'ap-south-1'
    ECR_REGISTRY    = '156916773321.dkr.ecr.ap-south-1.amazonaws.com'
    ECR_REPO        = 'jayamaran/sample-for-ecs'
    IMAGE_TAG       = 'latest'
    GIT_CREDENTIALS = '10962414-951f-44c5-921e-9e1afffe0993'
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/Sedin-Jayamaran/Buggy-App',
            credentialsId: "${env.GIT_CREDENTIALS}"
          ]]
        ])
      }
    }

    stage('Docker Login to ECR') {
  steps {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-userpass-creds']]) {
      sh '''
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
