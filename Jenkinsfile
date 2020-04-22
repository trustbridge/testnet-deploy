#!groovy

// Build pipeline for the devnet environment
// This pipeline provides a centralised point to control the build of the various components that make up the devnet deployment
// The pipeline expects to be called from other pipelines which will update the parameters of the repo they come from

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
        properties_file = "/var/opt/properties/devnet.properties"
        GITHUB_CREDENTIALS = credentials('github')
    }

    parameters {
        string(
            name: 'branchref_intercustomsledger',
            defaultValue: 'master',
            description: 'The commit to use for the deploy'
        )
        string(
            name: 'branchref_chambersapp',
            defaultValue: 'master',
            description: 'The commit to use for the deploy'
        )
        string(
            name: 'branchref_intergov',
            defaultValue: 'master',
            description: 'The commit to use for the deploy'
        )

        booleanParam(
            name: 'force_chambers'
            defaultValue : false,
            description: 'Force build of chambers components'
        )
        booleanParam(
            name: 'force_imports'
            defaultValue: false,
            description: 'Force build of imports components'
        )
        booleanParam(
            name: 'force_exports'
            defaultValue: false,
            description: 'Force build of exports components'
        )
        booleanParam(
            name: 'force_intergov'
            defaultValue: false,
            description: 'Force build of intergov components'
        )
    }

    stages {
        // hamlet specifc artefact storage
        stage('Build_Artefact - Chambers App') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_chambers
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_chambersapp}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'www-chm,www-beat-chm,www-work-chm,www-flwr-chm,www-task-chm'
                segment = 'clients'
                image_format = 'docker'
                BUILD_PATH = 'chambers-app/'
                DOCKER_CONTEXT_DIR = 'chambers-app/src/'
                BUILD_SRC_DIR = 'src/'
                DOCKER_FILE = 'chambers-app/src/compose/production/django/Dockerfile'
            }

            steps {
                dir("chambers-app/") {
                    script {
                        def repoChambersApp = checkout(
                            [
                                $class: 'GitSCM',
                                branches: [[name: "${env.branchref_chambersapp}" ]],
                                userRemoteConfigs: [[
                                    credentialsId: 'github',
                                    url: 'https://github.com/trustbridge/chambers-app'
                                ]]
                            ]
                        )
                        env.gitcommit_chambersapp = repoChambersApp.GIT_COMMIT
                    }
                }

                echo "GIT_COMMIT is ${env.gitcommit_chambersapp}"

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_chambersapp}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_chambersapp}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}" )
                ]
            }
        }

        stage('Build_Artefact - Exports App') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_exports
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intercustomsledger}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'www-exp,www-beat-exp,www-work-exp,www-flwr-exp,www-task-exp'
                segment = 'clients'
                image_format = 'docker'
                BUILD_PATH = 'exports-app/exporter_app'
                DOCKER_CONTEXT_DIR = 'exports-app/exporter_app'
                BUILD_SRC_DIR = 'src/'
                DOCKER_FILE = 'exports-app/exporter_app/compose/production/django/Dockerfile'
            }

            steps {
                dir("exports-app/") {
                    script {
                        def repoExportsApp = checkout(
                            [
                                $class: 'GitSCM',
                                branches: [[name: "${env.branchref_intercustomsledger}" ]],
                                userRemoteConfigs: [[
                                    credentialsId: 'github',
                                    url: 'https://github.com/gs-gs/inter-customs-ledger'
                                ]]
                            ]
                        )
                        env.gitcommit_exportsapp = repoExportsApp.GIT_COMMIT
                    }
                }

                echo "GIT_COMMIT is ${env["gitcommit_exportsapp"]}"

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_exportsapp}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_exportsapp}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }
        }

        stage('Build_Artefact - Imports App') {
             when {
                anyOf {
                    equals expected: true, actual: params.force_imports
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intercustomsledger}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'www-imp,www-beat-imp,www-work-imp,www-flwr-imp,www-task-imp'
                segment = 'clients'
                image_format = 'docker'
                BUILD_PATH = 'imports-app/importer_app'
                DOCKER_CONTEXT_DIR = 'imports-app/importer_app'
                BUILD_SRC_DIR = 'src/'
                DOCKER_FILE = 'imports-app/importer_app/compose/production/django/Dockerfile'
            }

            steps {

                dir("imports-app/") {
                    script {
                        def repoImportsApp = checkout(
                            [
                                $class: 'GitSCM',
                                branches: [[name: "${env.branchref_intercustomsledger}" ]],
                                userRemoteConfigs: [[
                                    credentialsId: 'github',
                                    url: 'https://github.com/gs-gs/inter-customs-ledger'
                                ]]
                            ]
                        )
                        env.gitcommit_importsapp = repoImportsApp.GIT_COMMIT
                    }
                }

                echo "GIT_COMMIT is ${env.gitcommit_importsapp}"

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_imports-app}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_importsapp}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }
        }

        stage('Build - Intergov') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_intergov
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intergov}"
                        }
                        branch 'master'
                    }
                }
            }

            steps {
                echo "GIT_COMMIT is ${env.branchref_intergov}"

                dir('intergov/') {
                    script {
                        def repoIntergov = checkout(
                            [
                                $class: 'GitSCM',
                                branches: [[name: "${env.branchref_intergov}" ]],
                                userRemoteConfigs: [[
                                    credentialsId: 'github',
                                    url: 'https://github.com/trustbridge/intergov'
                                ]]
                            ]
                        )
                        env.gitcommit_intergov = repoIntergov.GIT_COMMIT
                    }

                    sh '''#!/bin/bash
                        if [[ -d "${HOME}/.nodenv" ]]; then
                            export PATH="$HOME/.nodenv/bin:$PATH"
                            eval "$(nodenv init - )"
                            nodenv install 12.16.1 || true
                            nodenv shell 12.16.1
                        fi
                        npm install serverless@1.67.3 serverless-python-requirements@5.1.0 serverless-wsgi@1.7.4
                        export PATH="$( npm bin ):$PATH"

                        sls package --package dist/document_api --config "../deploy/deployment/intergov/document_api/lambda/serverless.yml"
                        sls package --package dist/message_api --config "../../deploy/deployment/intergov/message_api/lambda/serverless.yml"
                        sls package --package dist/message_rx_api --config "../../deploy/deployment/intergov/message_rx_api/lambda/serverless.yml"
                        sls package --package dist/subscriptions_api --config "../../deploy/deployment/intergov/subscriptions_api/lambda/serverless.yml"
                    '''
                }
            }

            post {
                success {
                    dir('intergov/') {
                        archiveArtifacts artifacts: 'dist/document_api/document_api.zip', fingerprint: true
                        archiveArtifacts artifacts: 'dist/message_api/message_api.zip', fingerprint: true
                        archiveArtifacts artifacts: 'dist/message_rx_api/message_rx_api.zip', fingerprint: true
                        archiveArtifacts artifacts: 'dist/subscriptions_api/subscriptions_api.zip', fingerprint: true
                    }
                }
            }
        }

        stage('Artefact - Intergov - document_api') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_intergov
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intergov}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'document-api-imp'
                segment = 'intergov'
                image_format = 'lambda'
                BUILD_SRC_DIR = 'intergov/'
            }

            steps {

                dir('intergov') {
                    sh '''
                        cp dist/document_api/document_api.zip dist/lambda.zip
                    '''
                }

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_intergov}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_intergov}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }

        }

        stage('Artefact - Intergov - message_api') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_intergov
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intergov}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'message-api-imp'
                segment = 'intergov'
                image_format = 'lambda'
                BUILD_SRC_DIR = 'intergov/'
            }

            steps {

                dir('intergov') {
                    sh '''
                        cp dist/message_api/message_api.zip dist/lambda.zip
                    '''
                }

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_intergov}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_intergov}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }

        }

        stage('Artefact - Intergov - message_rx_api') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_intergov
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intergov}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'messagerx-api-imp'
                segment = 'intergov'
                image_format = 'lambda'
                BUILD_SRC_DIR = 'intergov/'
            }

            steps {

                dir('intergov') {
                    sh '''
                        cp dist/message_rx_api/message_rx_api.zip dist/lambda.zip
                    '''
                }

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_intergov}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_intergov}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }

        }

        stage('Artefact - Intergov - subscriptions_api') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_intergov
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intergov}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units = 'subscriptions-api-imp'
                segment = 'intergov'
                image_format = 'lambda'
                BUILD_SRC_DIR = 'intergov/'
            }

            steps {

                dir('intergov') {
                    sh '''
                        cp dist/subscriptions_api/subscriptions_api.zip dist/lambda.zip
                    '''
                }

                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_intergov}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_intergov}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }

        }

        // hamlet specifc artefact storage
        stage('Artefact - Intergov - processor') {
            when {
                anyOf {
                    equals expected: true, actual: params.force_intergov
                    allOf {
                        not {
                            equals expected: 'master', actual: "${params.branchref_intergov}"
                        }
                        branch 'master'
                    }
                }
            }

            environment {
                //hamlet deployment variables
                deployment_units =  'proc-msg,proc-callbdel,proc-callbspd,proc-rejstat,proc-bchloopback,proc-docspider,proc-channelrouter'
                segment = 'intergov'
                image_format = 'docker'
                BUILD_PATH = 'intergov/'
                DOCKER_CONTEXT_DIR = 'intergov/'
                BUILD_SRC_DIR = ''
                DOCKER_FILE = 'intergov/Dockerfile-demo'
            }

            steps {
                uploadImageToRegistry(
                    "${env.properties_file}",
                    "${env.deployment_units.split(',')[0]}",
                    "${env.image_format}",
                    "${env.gitcommit_intergov}"
                )

                build job: '../cote-c1/master', parameters: [
                        extendedChoice(name: 'DEPLOYMENT_UNITS', value: "${env.deployment_units}"),
                        string(name: 'GIT_COMMIT', value: "${env.gitcommit_intergov}"),
                        booleanParam(name: 'AUTODEPLOY', value: true),
                        string(name: 'IMAGE_FORMATS', value: "${env.image_format}"),
                        string(name: 'SEGMENT', value: "${env.segment}")
                ]
            }
        }
    }

    post {
        cleanup {
            cleanWs()
        }
    }
}


void uploadImageToRegistry( properties_file, deployment_unit, image_format, git_commit )   {

    script {
        env['deployment_unit'] = "${deployment_unit}"
        env['image_format'] = "${image_format}"
        env['unit_git_commit'] = "${git_commit}"
    }

    // Product Setup
    script {
        def contextProperties = readProperties interpolate: true, file: "${properties_file}" ;
        contextProperties.each{ k, v -> env["${k}"] ="${v}" }
    }

    sh '''#!/bin/bash
    ${AUTOMATION_BASE_DIR}/setContext.sh || exit $?
    '''

    script {
        def contextProperties = readProperties interpolate: true, file: "${WORKSPACE}/context.properties";
        contextProperties.each{ k, v -> env["${k}"] ="${v}" }
    }

    sh '''#!/bin/bash
    ${AUTOMATION_DIR}/manageImages.sh -g "${unit_git_commit}" -u "${deployment_unit}" -f "${image_format}"  || exit $?
    '''

    script {
        def contextProperties = readProperties interpolate: true, file: "${WORKSPACE}/context.properties";
        contextProperties.each{ k, v -> env["${k}"] ="${v}" }
    }

}
