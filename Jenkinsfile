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
        stage('Build Docker Image') {
            steps {
                script {
                    def dockerImageName = "selenium-${params.BROWSER}-tests-${env.BUILD_NUMBER}"
                    bat """
                        docker build --build-arg BROWSER=${params.BROWSER} -t ${dockerImageName} .
                    """
                }
            }
        }

        stage('Run Tests in Container') {
            steps {
                script {
                    def dockerImageName = "selenium-${params.BROWSER}-tests-${env.BUILD_NUMBER}"
                    bat """
                        mkdir test-reports
                        docker run --rm ^
                        -e BROWSER=${params.BROWSER} ^
                        -e URL=${params.URL} ^
                        -e EXPECTED_TITLE=${params.EXPECTED_TITLE} ^
                        -v %CD%\\test-reports:/app ^
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
            }

            // Publish HTML report
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
