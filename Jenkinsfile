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

                    // Create folder for test reports (on host)
                    bat "mkdir %reportDirectory%"

                    // Build Docker image
                    bat """
                        docker build --build-arg BROWSER=${params.BROWSER} -t ${dockerImageName} .
                    """

                    // Run container, passing test arguments directly to pytest
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

                // List test-reports to verify report is created
                bat "dir %reportDirectory%"

                // Publish the HTML report to Jenkins
                publishHTML([
                    allowMissing: false,
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