pipeline {
  agent any

  environment {
    AWS_REGION      = 'ap-south-1'
    ECR_REGISTRY    = '156916773321.dkr.ecr.ap-south-1.amazonaws.com'
    ECR_REPO        = 'jayamaran/sample-for-ecs'
    IMAGE_TAG       = 'latest'
    GIT_CREDENTIALS = '10962414-951f-44c5-921e-9e1afffe0993'

    // ✅ Add these variables
    TASK_FAMILY     = 'jai-ecs-web'
    CONTAINER_NAME  = 'buggy-web'
    CLUSTER_NAME    = 'Jai-Manual-Cluster'
    SERVICE_NAME    = 'jai-ecs-web-service-26129xjx'
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
        withCredentials([
          string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
          string(credentialsId: 'aws-session-token', variable: 'AWS_SESSION_TOKEN')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin ${ECR_REGISTRY}
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build --no-cache -f Dockerfile.app -t $ECR_REPO:$IMAGE_TAG .
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

    // ✅ ADD: Register new ECS task definition
    stage('Register New ECS Task Definition') {
      steps {
        sh """
          cat > task-def.json <<EOF
          {
            "family": "$TASK_FAMILY",
            "executionRoleArn": "arn:aws:iam::156916773321:role/ecsTaskExecutionRole",
            "taskRoleArn": "arn:aws:iam::156916773321:role/ecsTaskExecutionRole",
            "networkMode": "host",
            "containerDefinitions": [
              {
                "name": "$CONTAINER_NAME",
                "image": "$ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG",
                "cpu": 512,
                "memory": 256,
                "portMappings": [
                  { "name": "buggy-web-80-tcp", "containerPort": 80, "hostPort": 80, "protocol": "tcp", "appProtocol": "http" },
                  { "name": "buggy-web-3000-tcp", "containerPort": 3000, "hostPort": 3000, "protocol": "tcp" }
                ],
                "essential": true,
                "environment": [
                  { "name": "MYSQL_DATABASE", "value": "database" },
                  { "name": "MYSQL_PASSWORD", "value": "1011" },
                  { "name": "MYSQL_PORT", "value": "3306" },
                  { "name": "RAILS_ENV", "value": "production" },
                  { "name": "MYSQL_ROOT_PASSWORD", "value": "123" },
                  { "name": "MYSQL_USER", "value": "jayamaran" },
                  { "name": "MYSQL_HOST", "value": "172.31.8.83" },
                  { "name": "SECRET_KEY_BASE", "value": "327c5f2bda2e0518b89a125809a01af808c7e006e4c500d7c3ca09f804646de79bdf67be394c195f85f311ce24efc34b063ed4ddf5ab90f99151a4e6036b639b" }
                ],
                "logConfiguration": {
                  "logDriver": "awslogs",
                  "options": {
                    "awslogs-group": "/ecs/$TASK_FAMILY",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "ecs",
                    "awslogs-create-group": "true"
                  }
                }
              }
            ],
            "requiresCompatibilities": ["EC2"],
            "cpu": "512",
            "memory": "256",
            "runtimePlatform": {
              "cpuArchitecture": "X86_64",
              "operatingSystemFamily": "LINUX"
            }
          }
EOF

          aws ecs register-task-definition --cli-input-json file://task-def.json
        """
      }
    }

    // ✅ UPDATE: Deploy ECS with new task revision
    stage('Deploy to ECS') {
      steps {
        withCredentials([
          string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
          string(credentialsId: 'aws-session-token', variable: 'AWS_SESSION_TOKEN')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

            NEW_REVISION=$(aws ecs describe-task-definition \
              --task-definition $TASK_FAMILY \
              --query 'taskDefinition.revision' \
              --output text)

            aws ecs update-service \
              --cluster $CLUSTER_NAME \
              --service $SERVICE_NAME \
              --task-definition $TASK_FAMILY:$NEW_REVISION \
              --force-new-deployment \
              --region $AWS_REGION
          '''
        }
      }
    }
  }
}
