pipeline {
    agent any

    parameters {
        choice(name: 'BROWSER', choices: ['chrome', 'firefox'], description: 'Select the browser to run the tests on')
        string(name: 'URL', defaultValue: 'https://www.google.com', description: 'Enter the URL to test')
        string(name: 'EXPECTED_TITLE', defaultValue: 'Google', description: 'Enter the expected title of the page')
    }

    stages {
        stage('Build and Run Tests') {
            steps {
                script {
                    def dockerImageName = "selenium-${params.BROWSER}-tests-${env.BUILD_NUMBER}"

                    bat "docker build --build-arg BROWSER=${params.BROWSER} -t ${dockerImageName} ."

                    // Make sure reports go to a local folder Jenkins can read
                    bat """
                        mkdir test-reports
                        docker run --rm ^
                        -e BROWSER=${params.BROWSER} ^
                        -e URL=${params.URL} ^
                        -e EXPECTED_TITLE=${params.EXPECTED_TITLE} ^
                        -v %cd%\\test-reports:/app/test-reports ^
                        ${dockerImageName}
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                def dockerImageName = "selenium-${params.BROWSER}-tests-${env.BUILD_NUMBER}"
                bat "docker rmi -f ${dockerImageName}"

                // Publish the HTML report
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'test-reports',
                    reportFiles: 'report.html',
                    reportName: 'Pytest Report'
                ])
            }
        }
    }
}
