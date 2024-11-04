pipeline {
    agent any

    environment {
        // Cassandra credentials and SSH user for remote access
        CASSANDRA_SSH_USER = 'cassandra_user' // SSH user for Cassandra host
    }

    stages {

        stage('Set Environment Based on Branch') {
            steps {
                script {
                    // Map branch directly to environment and host based on branch name
                    def envDetails = getEnvironmentFromBranch(env.BRANCH_NAME)
                    if (!envDetails) {
                        error "Branch '${env.BRANCH_NAME}' does not map to any valid environment."
                    }
                    env.CASSANDRA_HOST = envDetails.host
                    env.DEPLOYMENT_ENV = envDetails.envName
                    env.GIT_BRANCH = envDetails.gitBranch

                    echo "Deploying to environment: ${env.DEPLOYMENT_ENV} on host ${env.CASSANDRA_HOST}, using Git branch: ${env.GIT_BRANCH}"
                }
            }
        }

        stage('Checkout') {
            steps {
                // Checkout the code from the corresponding Git branch for each environment
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/adrian-soroceanu-jnpr/cass-test.git'
            }
        }

        stage('Deploy Schema') {
            steps {
                script {
                    echo "Deploying schema to ${env.DEPLOYMENT_ENV} environment on host ${env.CASSANDRA_HOST}..."

                    // Deploy the schema to the selected environment via SSH
                    deployCQLToCassandraViaSSH(env.CASSANDRA_HOST)
                }
            }
        }
    }

    post {
        success {
            echo 'Schema deployed successfully!'
        }
        failure {
            echo 'Deployment failed. Attempting rollback...'
        }
    }
}

// Direct mapping of branch name to environment, Cassandra host, and Git branch
def getEnvironmentFromBranch(branchName) {
    switch (branchName) {
        case 'dev':
            return [envName: 'Development', host: 'cassandra-dev-host', gitBranch: 'dev']
        case 'staging':
            return [envName: 'Staging', host: 'cassandra-staging-host', gitBranch: 'staging']
        case 'production':
            return [envName: 'Production', host: 'cassandra-production-host', gitBranch: 'production']
        default:
            return null
    }
}

// Deploy CQL files to Cassandra host via SSH
def deployCQLToCassandraViaSSH(host) {
    sh '''
        for file in keyspaces/**/*.cql; do
            echo "Applying $file to Cassandra on remote host $host..."
            ssh -o StrictHostKeyChecking=no ${env.CASSANDRA_SSH_USER}@${host} "cqlsh -f -" < \$file
        done
    '''
}
