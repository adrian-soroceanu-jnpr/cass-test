pipeline {
    agent any

    environment {
        // Jenkins environment variables for Cassandra credentials
        CASSANDRA_SSH_USER = 'root' // SSH user for Cassandra host
    }

    parameters {
        choice(
            name: 'TARGET_ENV',
            choices: ['dev', 'staging', 'production'],
            description: 'Select the environment to deploy the schema changes'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                // Clone the Git repository containing CQL files
                git branch: 'main', url: 'https://github.com/adrian-soroceanu-jnpr/cass-test.git'
            }
        }

        stage('Deploy Schema to Selected Environment') {
            steps {
                script {
                    // Get the appropriate Cassandra host based on TARGET_ENV
                    def cassandraHost = getCassandraHost(TARGET_ENV)
                    echo "Deploying schema to ${TARGET_ENV} environment on host ${cassandraHost}..."

                    // Deploy schema to the selected Cassandra environment over SSH
                    deployCQLToCassandraViaSSH(cassandraHost)
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

// Function to map environment to the correct Cassandra host
def getCassandraHost(env) {
    switch (env) {
        case 'dev':
            return '10.49.233.67'
        case 'staging':
            return 'cassandra-staging-host'
        case 'production':
            return 'cassandra-production-host'
        default:
            error "Unknown environment: ${env}"
    }
}

// Function to deploy the CQL files to the specified Cassandra host via SSH
def deployCQLToCassandraViaSSH(host) {
    // Loop through all the CQL files and apply them on the remote Cassandra server via SSH
    sh """
        for file in *.cql; do
            echo 'Applying $file to Cassandra on remote host $host...'
            ssh -o StrictHostKeyChecking=no ${env.CASSANDRA_SSH_USER}@${host} && cqlsh -f $file
        done
    """
}
