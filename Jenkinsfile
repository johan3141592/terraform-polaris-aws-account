pipeline {
    agent any
    triggers {
        cron(env.BRANCH_NAME == 'main' ? 'H 23 * * *' : '')
    }
    parameters {
        booleanParam(name: 'RUN_TESTS', defaultValue: false)
    }
    environment {
        // AWS provider.
        AWS_ACCESS_KEY        = credentials('tf-module-aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('tf-module-aws-secret-access-key')
        AWS_DEFAULT_REGION    = credentials('tf-module-aws-default-region')

        // RSC provider.
        RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS = credentials('tf-module-polaris-service-account')

        // Terraform module test input.
        TF_VAR_account_id = credentials('tf-module-aws-account-id')

        // Run acceptance tests with the nightly build or when triggered manually.
        RUN_TESTS = "${currentBuild.getBuildCauses('hudson.triggers.TimerTrigger$TimerTriggerCause').size() > 0 ? 'true' : params.RUN_TESTS}"
    }
    stages {
        stage('Test') {
            steps {
                sh 'if [ "$RUN_TESTS" != "false" ]; then terraform init -no-color; fi'
                sh 'if [ "$RUN_TESTS" != "false" ]; then terraform test -no-color; fi'
            }
        }
    }
    post {
        success {
            script {
                if (currentBuild.getBuildCauses('hudson.triggers.TimerTrigger$TimerTriggerCause').size() > 0) {
                    slackSend(
                        channel: '#terraform-provider-development',
                        color: 'good',
                        message: "The pipeline ${currentBuild.fullDisplayName} succeeded (runtime: ${currentBuild.durationString.minus(' and counting')})\n${currentBuild.absoluteUrl}"
                    )
                }
            }
        }
        failure {
            script {
                if (currentBuild.getBuildCauses('hudson.triggers.TimerTrigger$TimerTriggerCause').size() > 0) {
                    slackSend(
                        channel: '#terraform-provider-development',
                        color: 'danger',
                        message: "The pipeline ${currentBuild.fullDisplayName} failed (runtime: ${currentBuild.durationString.minus(' and counting')})\n${currentBuild.absoluteUrl}"
                    )
                }
            }
        }
        cleanup {
            cleanWs()
        }
    }
}
