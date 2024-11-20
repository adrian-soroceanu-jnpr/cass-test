pipeline {
    agent any

    parameters {
        choice(
            name: 'OPERATION',
            choices: ['deploy', 'delete'],
            description: 'Choose the operation to perform: deploy schema or delete objects'
        )
        choice(
            name: 'DEPLOY_FOLDER',
            choices: ['keyspaces', 'tables'],
            description: 'Choose which folder to deploy (only for deploy operation)'
        )
        string(
            name: 'OBJECT_NAME',
            defaultValue: '',
            description: 'Specify the keyspace or table name to delete (e.g., keyspace.table) (only for delete operation)'
        )
        choice(
            name: 'OBJECT_TYPE',
            choices: ['keyspace', 'table'],
            description: 'Choose the object type to delete (only for delete operation)'
        )
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
            when {
                expression { return params.OPERATION == 'deploy' }
            }
            steps {
                // Checkout the code from the corresponding Git branch for each environment
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/adrian-soroceanu-jnpr/cass-test.git'
            }
        }

        stage('Delete Keyspace/Table') {
            when {
                 allOf {
                    expression { return params.OPERATION == 'delete' }
                    expression { return params.OBJECT_NAME?.trim() != '' }
                }
            }
            steps {
                script {
                    deleteKeyspaceOrTable(params.OBJECT_TYPE, params.OBJECT_NAME, env.CASSANDRA_HOST)
                }
            }
        }
        stage('Deploy Schema') {
            when {
                expression { return params.OPERATION == 'deploy' }
            }
            steps {
                script {
                    def folderToDeploy = params.DEPLOY_FOLDER == 'keyspaces' ? '*.cql' : '*.cql'
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
            echo 'Deployment failed.'
        }
    }
}

// Direct mapping of branch name to environment, Cassandra host, and Git branch
def getEnvironmentFromBranch(branchName) {
    switch (branchName) {
        case 'dev':
            return [envName: 'Development', host: '10.49.234.9', gitBranch: 'dev']
        case 'stage':
            return [envName: 'Staging', host: '10.49.234.9', gitBranch: 'stage']
        case 'prod':
            return [envName: 'Production', host: '10.49.234.9', gitBranch: 'prod']
        default:
            return null
    }
}

// Deploy CQL files to Cassandra host directly over the network
def deployCQLToCassandraDirectly(host, folder) {
    sh '''
        for file in ${DEPLOY_FOLDER}/*.cql; do
            echo "Applying \$file to Cassandra on host ${host}..."
            cqlsh ${CASSANDRA_HOST} ${CASSANDRA_PORT} -f "$file"
        done
    '''.stripMargin()
}

// Delete a keyspace or table in Cassandra
def deleteKeyspaceOrTable(type, name, host) {
    def dropCommand
    if (type == 'keyspace') {
        dropCommand = "DROP KEYSPACE IF EXISTS ${name};"
    } else if (type == 'table') {
        def parts = name.split("\\.")
        if (parts.size() != 2) {
            error "Table name must be in the format keyspace.table"
        }
        dropCommand = "DROP TABLE IF EXISTS ${name};"
    } else {
        error "Unsupported object type: ${type}"
    }

    sh """
        echo "Executing drop command: ${dropCommand}"
        echo "${dropCommand}" | cqlsh ${CASSANDRA_HOST}
    """.stripMargin()}
