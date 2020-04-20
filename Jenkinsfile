#!groovy

pipeline {
    agent {
        label 'hamlet-latest'
    }
    options {
        timestamps ()
        buildDiscarder(
            logRotator(
                daysToKeepStr: '14'
            )
        )
        disableConcurrentBuilds()
        durabilityHint('PERFORMANCE_OPTIMIZED')
        parallelsAlwaysFailFast()
        checkoutToSubdirectory('deploy')
    }

    environment {
        properties_file = "/var/opt/codeontap/testnet.properties"
        GITHUB_CREDENTIALS = credentials('github')
        DOCKER_BUILD_DIR = "${env.DOCKER_STAGE_DIR}/${BUILD_TAG}"
    }

    parameters {
        string(
            name: 'branchref_chambers_app',
            defaultValue: 'master',
            description: 'The commit to use for the testing build'
        )
        string(
            name: 'branchref_intergov',
            defaultValue: 'master',
            description: 'The commit to use for the testing build'
        )
        booleanParam(
            name: 'all_tests',
            defaultValue: false,
            description: 'Run tests for all components'
        )
    }

    stages {

        stage('Clone Repos') {
            steps {
                dir("${env.DOCKER_BUILD_DIR}/test/intergov/") {
                    script {
                        def intergov_repo = checkout(
                        [
                            $class: 'GitSCM',
                            branches: [[name: "${params.branchref_intergov}" ]],
                            userRemoteConfigs: [
                                [
                                    url: 'https://github.com/trustbridge/intergov',
                                    refspec: '+refs/pull/*/head:refs/remotes/origin/pr/*',
                                    credentialsId: 'github'
                                ]
                            ]
                        ]
                        )
                        env.intergov_git_commit = intergov_repo.GIT_COMMIT
                    }
                }

                dir("${env.DOCKER_BUILD_DIR}/test/chambers_app/") {
                    script {
                        def chambers_app_repo = checkout(
                        [
                            $class: 'GitSCM',
                            branches: [[name: "${params.branchref_chambers_app}" ]],
                            userRemoteConfigs: [
                                [
                                    url: 'https://github.com/trustbridge/chambers-app',
                                    refspec: '+refs/pull/*/head:refs/remotes/origin/pr/*',
                                    credentialsId: 'github'
                                ]
                            ]
                        ]
                        )
                        env.chambers_app_git_commit = chambers_app_repo.GIT_COMMIT
                    }
                }
            }
        }

        stage('Setup Intergov') {
            steps {
                dir("${env.DOCKER_BUILD_DIR}/test/intergov/") {
                    sh '''#!/bin/bash
                        cp demo-local-example.env demo-local.env
                        python3.6 pie.py intergov.build
                        python3.6 pie.py intergov.start
                        echo "waiting for startup"
                        sleep 60s
                    '''
                }
            }
        }

        stage('Setup Chambers App') {
            steps {
                dir("${env.DOCKER_BUILD_DIR}/test/chambers_app/src/") {
                    sh '''#!/bin/bash
                    touch local.env
                    docker-compose -f docker-compose.yml -f demo.yml up --build -d
                    sleep 30s
                    '''
                }
            }
        }

        stage('Testing') {
            stages {
                stage('Interov') {

                    when {
                        anyOf {
                            equals expected: true, actual: params.all_tests
                            not {
                                equals expected: 'master', actual: params.branchref_intergov
                            }
                        }
                    }

                    steps {
                        dir("${env.DOCKER_BUILD_DIR}/test/intergov/") {

                            sh '''#!/bin/bash
                                python3.6 pie.py intergov.tests.unit
                                python3.6 pie.py intergov.tests.integration || true
                            '''
                        }
                    }

                    post {
                        always {
                            dir("${env.DOCKER_BUILD_DIR}/test/intergov/"){
                                publishHTML(
                                    [
                                        allowMissing: true,
                                        alwaysLinkToLastBuild: true,
                                        keepAll: true,
                                        reportDir: 'htmlcov',
                                        reportFiles: 'index.html',
                                        reportName: 'Intergov Coverage Report',
                                        reportTitles: ''
                                    ]
                                )
                            }
                        }
                    }
                }

                stage('Chambers App' ) {

                    when {
                        anyOf {
                            equals expected: true, actual: params.all_tests
                            not {
                                equals expected: 'master', actual: params.branchref_chambers_app
                            }
                        }
                    }


                    steps {
                        dir("${env.DOCKER_BUILD_DIR}/test/chambers_app/src/") {
                            sh '''#!/bin/bash
                            docker-compose -f docker-compose.yml -f demo.yml run -T django py.test
                            docker-compose -f docker-compose.yml -f demo.yml run -T django coverage run -m pytest
                            docker-compose -f docker-compose.yml -f demo.yml run -T django coverage html
                            '''
                        }
                    }

                    post {
                        always {

                            dir("${env.DOCKER_BUILD_DIR}/test/chambers_app/src/"){
                                publishHTML(
                                    [
                                        allowMissing: true,
                                        alwaysLinkToLastBuild: true,
                                        keepAll: true,
                                        reportDir: 'htmlcov',
                                        reportFiles: 'index.html',
                                        reportName: 'Chambers Coverage Report',
                                        reportTitles: ''
                                    ]
                                )
                            }
                        }
                    }
                }
            }

            post {

                always {
                    // Cleanup chambers app
                    dir("${env.DOCKER_BUILD_DIR}/test/chambers_app/src/") {
                        sh '''#!/bin/bash
                            if [[ -f docker-compose.yml ]]; then
                                docker-compose -f docker-compose.yml -f demo.yml down --rmi local -v --remove-orphans
                            fi
                        '''
                    }

                    dir("${env.DOCKER_BUILD_DIR}/test/intergov/") {
                        sh '''#!/bin/bash
                            if [[ -f pie.py ]]; then
                                python3.6 pie.py intergov.destroy
                            fi
                        '''
                    }
                }
            }
        }

    }

    post {
        cleanup {
            cleanWs()
        }
    }
}
