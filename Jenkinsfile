pipeline {
    agent any
    environment {
        DEV_BRANCH = 'dev'
        STAGE_BRANCH = 'stage'
        PROD_BRANCH = 'prod'
        SSH_HOST = 'cassandra_host'
        SSH_USER = 'root'
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: '$GIT_BRANCH', url: 'https://github.com/adrian-soroceanu-jnpr/cass-test.git'
            }
        }
        stage('SSH and Execute Scripts') {
            steps {
                script {
                    def environment = ''
                    switch (env.GIT_BRANCH) {
                        case 'dev':
                            environment = 'dev'
                            sshHost = '10.49.233.67'
                            // Other dev-specific environment variables
                            break
                        case 'stage':
                            environment = 'stage'
                            sshHost = 'stage_cassandra_host'
                            // Other stage-specific environment variables
                            break
                        case 'prod':
                            environment = 'prod'
                            sshHost = 'prod_cassandra_host'
                            // Other prod-specific environment variables
                            break
                        default:
                            error "Unknown branch: ${env.GIT_BRANCH}"
                    }

                    // Use the environment-specific variables to SSH and execute scripts
                    sh "ssh ${SSH_USER}@${sshHost} 'cqlsh *.cql'"
                }
            }
        }
    }
}
