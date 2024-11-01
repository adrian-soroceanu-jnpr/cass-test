pipeline {
    agent any

    parameters {
        // Define environment choices for deployment
        choice(
            name: 'TARGET_ENV',
            choices: ['dev', 'staging', 'production'],
            description: 'Select the environment to deploy the schema changes'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                // Clone the repository containing CQL files
                git branch: 'main', url: 'https://github.com/adrian-soroceanu-jnpr/cass-test.git'
            }
        }

        stage('Deploy Schema to Selected Environment') {
            steps {
                script {
                    // Map the chosen environment to the correct Cassandra host
                    def cassandraHost = getCassandraHost(TARGET_ENV)
                    echo "Deploying schema to ${TARGET_ENV} environment on host ${cassandraHost}..."

                    // Deploy schema to the selected Cassandra environment
                    deployCQLToCassandra(cassandraHost)
                }
            }
        }
    }

    post {
        success {
            echo 'Schema deployed successfully!'
        }
        failure {
            echo 'Deployment failed.'
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

// Function to deploy the CQL files to the specified Cassandra host
def deployCQLToCassandra(host) {
    // Loop through all the CQL files and apply them to the specified Cassandra cluster
    sh '''
        for file in *.cql; do
            echo "Applying $file to Cassandra host $host..."
            ssh -o StrictHostKeyChecking=no cassandra_user@$host "cqlsh -f" < $file
        done
    '''
}
