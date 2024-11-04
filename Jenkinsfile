pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_FOLDER', choices: ['keyspaces', 'tables'], description: 'Choose which folder to deploy')
    }

    environment {
        // Cassandra credentials and connection details
        CASSANDRA_PORT = '9042' // Default Cassandra port
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
                    def folderToDeploy = params.DEPLOY_FOLDER == 'keyspaces' ? 'keyspaces/*.cql' : 'tables/*.cql'
                    echo "Deploying ${params.DEPLOY_FOLDER} schema to ${env.DEPLOYMENT_ENV} environment on host ${env.CASSANDRA_HOST}..."
                    deployCQLToCassandraDirectly(env.CASSANDRA_HOST, folderToDeploy)
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
            return [envName: 'Development', host: '10.49.233.67', gitBranch: 'dev']
        case 'staging':
            return [envName: 'Staging', host: 'cassandra-staging-host', gitBranch: 'staging']
        case 'production':
            return [envName: 'Production', host: 'cassandra-production-host', gitBranch: 'production']
        default:
            return null
    }
}

// Deploy CQL files to Cassandra host directly over the network
def deployCQLToCassandraDirectly(host, folder) {
    sh '''
        for file in ${folder}; do
            echo "Applying \$file to Cassandra on host ${host}..."
            cqlsh ${CASSANDRA_HOST} ${env.CASSANDRA_PORT} -f "$file"
        done
    '''.stripMargin()
}
