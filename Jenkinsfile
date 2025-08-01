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
                    def dockerImageName = "selenium-${params.BROWSER}-tests-${env.BUILD_NUMBER}"
                    def reportDirectory = "test-reports"
                    
                    // Add debugging: Print the current working directory
                    bat "echo --- Current Directory ---"
                    bat "echo %cd%"
                    bat "echo -----------------------"

                    // Use Jenkins' dir() step to manage the report folder safely
                    dir(reportDirectory) {
                        echo "Created directory: ${reportDirectory}"
                        // Add debugging: List files to confirm the directory exists and is empty
                        bat "dir"
                    }

                    // Build Docker image
                    bat """
                        docker build --build-arg BROWSER=${params.BROWSER} -t ${dockerImageName} .
                    """

                    // Run container, passing test arguments directly to pytest
                    // Note: %cd% is now the correct root for the mounted volume
                    bat """
                        docker run --rm ^
                        -e BROWSER=${params.BROWSER} ^
                        -e URL=${params.URL} ^
                        -e EXPECTED_TITLE=${params.EXPECTED_TITLE} ^
                        -v "%cd%\\${reportDirectory}":/app/test-reports ^
                        ${dockerImageName} --html=/app/test-reports/report.html --self-contained-html
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                def dockerImageName = "selenium-${params.BROWSER}-tests-${env.BUILD_NUMBER}"
                def reportDirectory = "test-reports"

                // Check for the report file before publishing
                bat "dir %reportDirectory%"
                
                // Publish the HTML report to Jenkins
                publishHTML([
                    allowMissing: true,  // Important: Use allowMissing: true to prevent pipeline failure if report is not found
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: reportDirectory,
                    reportFiles: 'report.html',
                    reportName: 'Pytest Report'
                ])
                
                // Clean up Docker image
                bat "docker rmi -f ${dockerImageName}"
            }
        }
    }
}