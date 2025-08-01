pipeline {
    agent any

    parameters {
        choice(name: 'BROWSER',
               choices: ['chrome', 'firefox'],
               description: 'Select the browser to run the tests on')

        string(name: 'URL',
               defaultValue: 'https://www.google.com',
               description: 'Enter the URL to test')

        string(name: 'EXPECTED_TITLE',
               defaultValue: 'Google',
               description: 'Enter the expected title of the page')
    }

    stages {
        stage('Build and Run Tests') {
            steps {
                script {
                    def dockerImageName = "selenium-${params.BROWSER}-tests:${env.BUILD_NUMBER}"

                    // Build the single Docker image, passing the BROWSER parameter as a build argument
                    sh "docker build --build-arg BROWSER=${params.BROWSER} -t ${dockerImageName} ."

                    // Run the Docker container with parameters passed as environment variables
                    sh """
                        docker run --rm \
                        -e BROWSER="${params.BROWSER}" \
                        -e URL="${params.URL}" \
                        -e EXPECTED_TITLE="${params.EXPECTED_TITLE}" \
                        ${dockerImageName}
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up the specific image created for this build
            script {
                def dockerImageName = "selenium-${params.BROWSER}-tests:${env.BUILD_NUMBER}"
                sh "docker rmi ${dockerImageName}"
            }
        }
    }
}