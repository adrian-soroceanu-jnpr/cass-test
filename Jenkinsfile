pipeline {
    agent any

    parameters {
        choice(
            name: 'OPERATION',
            choices: ['deploy', 'delete', 'update'],
            description: 'Choose the operation to perform: deploy, update, delete objects'
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
        choice(name: 'OBJECT_TYPE', 
               choices: ['keyspace', 'table'], 
               description: 'Select the object type.')
        
        string(name: 'OBJECT_NAME', 
               defaultValue: '', 
               description: 'Comma-separated list of objects (e.g., keyspace1 or keyspace1.table1).')
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

stage('Validate Deletion Objects') {
    when {
        expression { return params.OPERATION == 'delete' }
    }
    steps {
        script {
            def objectNames = params.OBJECT_NAME.split(',').collect { it.trim() }

            // Directories to check based on object type
            def directory = params.OBJECT_TYPE == 'keyspace' ? 'keyspaces' : 'tables'

            objectNames.each { name ->
                def searchText = params.OBJECT_TYPE == 'keyspace' ? "CREATE KEYSPACE IF NOT EXISTS ${name}" : "CREATE TABLE IF NOT EXISTS ${name}"

                // Check if the name exists in any .cql file
                def matchFound = sh(
                    script: "grep -rl '${searchText}' ${directory} || true",
                    returnStdout: true
                ).trim()

                if (matchFound) {
                    error "Deletion not allowed: ${params.OBJECT_TYPE} '${name}' is still defined in the repository. Found in files:\n${matchFound}"
                } else {
                    echo "No match for ${params.OBJECT_TYPE} '${name}' in ${directory}. Proceeding with deletion."
                }
            }
        }
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
                    def objectNames = params.OBJECT_NAME.split(',').collect { it.trim() }
                    deleteKeyspaceOrTable(params.OBJECT_TYPE, objectNames, env.CASSANDRA_HOST)
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

stage('Update Keyspace/Table') {
    when {
        expression { return params.OPERATION == 'update' }
    }
    steps {
        script {
            // Assume OBJECT_NAME is the relative file path provided by the user
            def filePath = params.OBJECT_NAME.trim()

            // Ensure the file exists
            def fileExists = sh(
                script: "test -f ${filePath} && echo 'exists' || echo 'not exists'",
                returnStdout: true
            ).trim()

            if (fileExists != 'exists') {
                error "Update file '${filePath}' not found in the repository. Cannot proceed."
            }

            // Execute the update
            echo "Applying update using file ${filePath}."
            sh '''
                "cqlsh ${CASSANDRA_HOST} ${CASSANDRA_PORT} -f $filePath"
            '''.stripMargin()
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
def deleteKeyspaceOrTable(type, names, host) {
    if (!names || names.isEmpty()) {
        error "No objects provided for deletion."
    }

    // Ensure names is a list
    if (names instanceof String) {
        names = names.split(',').collect { it.trim() }
    }

    // Compile DROP statements
    def dropCommand = names.collect { name ->
        if (type == 'keyspace') {
            return "DROP KEYSPACE IF EXISTS ${name};"
        } else if (type == 'table') {
            def parts = name.split("\\.")
            if (parts.size() != 2) {
                error "Table name must be in the format keyspace.table (invalid name: ${name})"
            }
            return "DROP TABLE IF EXISTS ${name};"
        } else {
            error "Unsupported object type: ${type}"
        }
    }.join("\n")

    sh """
        echo "Executing drop command: ${dropCommand}"
        echo "${dropCommand}" | cqlsh ${CASSANDRA_HOST}
    """.stripMargin()
}
