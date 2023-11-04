pipeline {
  agent {
    node {
      label 'terraform1'
    }
  }
  environment {
    AWS_ACCESS_KEY     = credentials("main_aws_access_key")
    AWS_SECRET_KEY     = credentials("main_aws_secret_key")
    GIT_SSH_COMMAND    = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  }

  stages {
    //GLOBAL
    // [START tf-init, tf-validate]
    stage('TF init & validate global') {
      when { anyOf {branch "dev";branch "prod";changeRequest() } }
      steps {
        sshagent (credentials: ['bitbucket-sshkey']){
          ansiColor('xterm') {
          sh '''
          if [[ $CHANGE_TARGET ]]; then
              TARGET_ENV=$CHANGE_TARGET
          else
              TARGET_ENV=$BRANCH_NAME
          fi
          if [ -d "tf/envs/${TARGET_ENV}/" ]; then
              cd tf/envs/${TARGET_ENV}/global
              terraform init
              terraform validate
          else
            echo "Target branch does not exist"
            exit 0
          fi'''
          }
        }
      }
    }
    // [END tf-init, tf-validate]

    // [START tf-plan]
    stage('TF plan global') {
      when { anyOf {branch "dev";branch "prod";changeRequest() } }
      steps {
        ansiColor('xterm') {
        sh '''
        if [[ $CHANGE_TARGET ]]; then
            TARGET_ENV=$CHANGE_TARGET
        else
            TARGET_ENV=$BRANCH_NAME
        fi

        if [ -d "tf/envs/${TARGET_ENV}/" ]; then
            cd tf/envs/${TARGET_ENV}/global
            terraform plan
        else
           echo "Target branch does not exist"
          exit 0
        fi'''
        }
      }
    }
    // [END tf-plan]

    stage('Approval global') {
        when { anyOf {branch "dev"; branch "prod"} }
        steps {
            script {
            def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
            }
        }
    }

    // [START tf-apply]
    stage('TF Apply global') {
      when { anyOf {branch "dev"; branch "prod"} }
      steps {
        ansiColor('xterm') {
        sh '''
        TARGET_ENV=$BRANCH_NAME
        if [ -d "tf/envs/${TARGET_ENV}/" ]; then
            cd tf/envs/${TARGET_ENV}/global
            terraform apply -input=false -auto-approve
        else
            echo "****** SKIPPING APPLY ******"
            echo "Branch '$TARGET' does not represent an official directory."
            echo "****** APPLY SKIPPED *******"
        fi'''
        }
      }
    }
    // [END tf-apply]

    // [START tf-show]
    stage('TF Show global') {
      when { anyOf {branch "dev"; branch "prod"} }
      steps {
        ansiColor('xterm') {
        sh '''
        TARGET_ENV=$BRANCH_NAME
        if [ -d "tf/envs/${TARGET_ENV}/" ]; then
            cd tf/envs/${TARGET_ENV}/global
            terraform show
        else
            echo "***** SKIPPING TFSHOW ******"
        fi'''
        }
      }
    }
    // [END tf-show]
    // END GLOBAL

    // EU-WEST-1
    // [START tf-init, tf-validate]
    // stage('TF init & validate eu-west-1') {
    //   when { anyOf {branch "dev"; branch "prod";changeRequest() } }
    //   steps {
    //     sshagent (credentials: ['bitbucket-sshkey']){
    //       ansiColor('xterm') {
    //       sh '''
    //       if [[ $CHANGE_TARGET ]]; then
    //           TARGET_ENV=$CHANGE_TARGET
    //       else
    //           TARGET_ENV=$BRANCH_NAME
    //       fi
    //       if [ -d "tf/envs/${TARGET_ENV}/" ]; then
    //           cd tf/envs/${TARGET_ENV}/eu-west-1
    //           terraform init \
    //             -var "aws_access_key=${AWS_ACCESS_KEY}" \
    //             -var "aws_secret_key=${AWS_SECRET_KEY}"
    //           terraform validate
    //       else
    //         echo "Target branch does not exist"
    //         exit 0
    //       fi'''
    //       }
    //     }
    //   }
    // }
    // // [END tf-init, tf-validate]

    // // [START tf-plan]
    // stage('TF plan eu-west-1') {
    //   when { anyOf {branch "dev"; branch "prod";changeRequest() } }
    //   steps {
    //     ansiColor('xterm') {
    //     sh '''
    //     if [[ $CHANGE_TARGET ]]; then
    //         TARGET_ENV=$CHANGE_TARGET
    //     else
    //         TARGET_ENV=$BRANCH_NAME
    //     fi

    //     if [ -d "tf/envs/${TARGET_ENV}/" ]; then
    //         cd tf/envs/${TARGET_ENV}/eu-west-1
    //         terraform plan \
    //           -var "aws_access_key=${AWS_ACCESS_KEY}" \
    //           -var "aws_secret_key=${AWS_SECRET_KEY}"
    //     else
    //       echo "Target branch does not exist"
    //       exit 0
    //     fi'''
    //     }
    //   }
    // }
    // // [END tf-plan]

    // stage('Approval eu-west-1') {
    //     when { anyOf {branch "dev"; branch "prod"} }
    //     steps {
    //       script {
    //         def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
    //       }
    //     }
    // }

    // // [START tf-apply]
    // stage('TF Apply eu-west-1') {
    //   when { anyOf {branch "dev"; branch "prod"} }
    //   steps {
    //     ansiColor('xterm') {
    //     sh '''
    //     TARGET_ENV=$BRANCH_NAME
    //     if [ -d "tf/envs/${TARGET_ENV}/" ]; then
    //         cd tf/envs/${TARGET_ENV}/eu-west-1
    //         terraform apply -input=false -auto-approve \
    //           -var "aws_access_key=${AWS_ACCESS_KEY}" \
    //           -var "aws_secret_key=${AWS_SECRET_KEY}"
    //     else
    //         echo "****** SKIPPING APPLY ******"
    //         echo "Branch '$TARGET' does not represent an official directory."
    //         echo "****** APPLY SKIPPED *******"
    //     fi'''
    //     }
    //   }
    // }
    // // [END tf-apply]

    // // [START tf-show]
    // stage('TF Show eu-west-1') {
    //   when { anyOf {branch "dev"; branch "prod"} }
    //   steps {
    //     ansiColor('xterm') {
    //     sh '''
    //     TARGET_ENV=$BRANCH_NAME
    //     if [ -d "tf/envs/${TARGET_ENV}/" ]; then
    //         cd tf/envs/${TARGET_ENV}/eu-west-1
    //         terraform show
    //     else
    //         echo "***** SKIPPING TFSHOW ******"
    //     fi'''
    //     }
    //   }
    // }
    // [END tf-show]
    // END EU-WEST-1
  }
}