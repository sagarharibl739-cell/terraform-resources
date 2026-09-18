pipeline {
  agent any

  parameters {
    choice(
      name: 'TERRAFORM_ACTION',
      choices: ['plan', 'apply', 'destroy'],
      description: 'Select the Terraform operation to run.'
    )
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init') {
      steps { sh 'terraform init -input=false' }
    }

    stage('Format Check') {
      steps { sh 'terraform fmt -check -recursive' }
    }

    stage('Validate') {
      steps { sh 'terraform validate' }
    }

    stage('Plan') {
      when {
        expression { params.TERRAFORM_ACTION in ['plan', 'apply'] }
      }
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY_ID', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh 'terraform plan -input=false -out=tfplan'
        }
      }
    }

    stage('Apply') {
      when {
        expression {
          params.TERRAFORM_ACTION == 'apply' &&
          (env.BRANCH_NAME == 'main' || env.GIT_BRANCH == 'main' || env.GIT_BRANCH == 'origin/main')
        }
      }
      steps {
        input message: 'MANUAL APPROVAL REQUIRED: Apply Terraform changes to AWS?', ok: 'Approve Apply'
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY_ID', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh 'terraform apply -input=false tfplan'
        }
      }
    }

    stage('Destroy') {
      when {
        expression {
          params.TERRAFORM_ACTION == 'destroy' &&
          (env.BRANCH_NAME == 'main' || env.GIT_BRANCH == 'main' || env.GIT_BRANCH == 'origin/main')
        }
      }
      steps {
        input message: 'MANUAL APPROVAL REQUIRED: Destroy all Terraform-managed AWS resources?', ok: 'Approve Destroy'
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY_ID', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh 'terraform destroy -input=false -auto-approve'
        }
      }
    }
  }

  post {
    always { archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true }
  }
}
