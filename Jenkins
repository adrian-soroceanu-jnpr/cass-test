pipeline {
    agent any

    environment {
        CASSANDRA_HOST = 'your-cassandra-host'
        CASSANDRA_USER = 'cassandra'
        CASSANDRA_PASSWORD = 'password'
    }

    stages {

        stage('Checkout') {
            steps {
                // Clone the repository containing CQL files
                git branch: 'main', url: 'https://github.com/your-org/cassandra-schema.git'
            }
        }

        stage('Lint & Validate CQL') {
            steps {
                // Run a Cassandra linter to validate the CQL files
                sh 'cassandra-lint keyspaces/**/*.cql'
            }
        }

        stage('Test Schema on Staging') {
            when {
                branch 'main'
            }
            steps {
                // Deploy changes to the staging Cassandra cluster for testing
                script {
                    deployCQLToCassandra('staging')
                }
            }
        }

        stage('Deploy Schema to Production') {
            when {
                branch 'main'
            }
            steps {
                // Deploy schema changes to the production Cassandra cluster
                script {
                    deployCQLToCassandra('production')
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
            script {
                rollbackSchema()
            }
        }
    }
}

def deployCQLToCassandra(environment) {
    // Environment-specific configuration (staging vs production)
    def host = (environment == 'production') ? CASSANDRA_HOST : 'your-staging-host'

    // Loop through all the CQL files and apply them to the Cassandra cluster
    sh """
        for file in keyspaces/**/*.cql; do
            echo "Applying $file to $environment Cassandra cluster..."
            cqlsh $host -u $CASSANDRA_USER -p $CASSANDRA_PASSWORD -f $file
        done
    """
}

def rollbackSchema() {
    // You can implement rollback logic using reverse CQL files or migration scripts
    echo 'Rollback logic goes here. Reverse the changes or apply the previous schema version.'
}

