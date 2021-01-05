[#ftl]

[@addExtension
    id="channel_shareddb"
    aliases=[
        "_channel_sharedb"
    ]
    description=[
        "Provides standard configuration for the Shared DB components"
    ]
    supportedTypes=[
        ECS_SERVICE_COMPONENT_TYPE,
        ECS_TASK_COMPONENT_TYPE,
        LAMBDA_COMPONENT_TYPE,
        LAMBDA_FUNCTION_COMPONENT_TYPE
    ]
/]


[#macro shared_extension_channel_shareddb_deployment_setup occurrence ]
    [@DefaultLinkVariables enabled=false /]
    [@DefaultCoreVariables enabled=false /]
    [@DefaultEnvironmentVariables enabled=false /]
    [@DefaultBaselineVariables enabled=false /]

    [@Settings
        [
            "KMS_PREFIX",
            "SENTRY_DSN",
            "JURISDICTION"
        ]
    /]

    [#assign awsRegion = (_context.DefaultEnvironment["AWS_REGION"])!"ap-southeast-2" ]
    [@Settings
        {
            "SENTRY_ENVIRONMENT"            : _context.DefaultEnvironment["ENVIRONMENT"]!"",
            "SENTRY_RELEASE"                : _context.DefaultEnvironment["APP_REFERENCE"]!(_context.DefaultEnvironment["BUILD_REFERENCE"]!""),
            "SERVER_NAME"                   : _context.DefaultEnvironment["API_FQDN"]!"",
            "SERVICE_URL"                   : _context.DefaultEnvironment["API_URL"]!"",
            "PREFERRED_URL_SCHEME"          : "https",
            "IGL_DEFAULT_S3_USE_SSL"        : "true",
            "IGL_DEFAULT_S3_REGION"         : awsRegion,
            "IGL_DEFAULT_S3_HOST"           : formatDomainName("s3", awsRegion, "amazonaws.com"),
            "IGL_DEFAULT_S3_PORT"           : "443",
            "IGL_DEFAULT_S3_ACCESS_KEY"     : "",
            "IGL_DEFAULT_S3_SECRET_KEY"     : "",
            "IGL_DEFAULT_SQS_USE_SSL"       : "true",
            "IGL_DEFAULT_SQS_PORT"          : "443",
            "IGL_DEFAULT_SQS_SECRET_KEY"    : "",
            "IGL_DEFAULT_SQS_ACCESS_KEY"    : "",
            "IGL_DEFAULT_SQS_REGION"        : awsRegion,
            "IGL_DEFAULT_SQS_HOST"          : formatDomainName("sqs", awsRegion, "amazonaws.com")
        }
    /]

    [#-- Environment variables --]
    [#list _context.DefaultEnvironment as env,value ]
        [#if env?starts_with("BKT") && env?ends_with("NAME") ]

            [#assign envvar = (env?remove_beginning("BKT_"))?remove_ending("_NAME") ]

            [@Settings
                {
                    envvar + "_BUCKET"      : value
                }
            /]
        [/#if]

        [#if env?starts_with("QUE") && env?ends_with("NAME") ]

            [#assign envvar = (env?remove_beginning("QUE_"))?remove_ending("_NAME") ]
            [@Settings
                {
                    envvar + "_QNAME"       : value
                }
            /]
        [/#if]
    [/#list]

    [#list _context.Links as id,link ]
        [#if link.Core.Type == S3_COMPONENT_TYPE ]
            [@Policy
                [
                    getS3BucketStatement(
                        [
                            "s3:ListBucket",
                            "s3:GetBucketLocation"
                        ],
                        link.State.Resources["bucket"].Id
                    )
                ]

            /]
        [/#if]
    [/#list]

    [@AltSettings
        {
            "DATABASE_URI" : "DATABASE_URL",
            "SENTRY_ENVIRONMENT" : "ENVIRONMENT",
            "SENTRY_RELEASE" : "BUILD_REFERENCE"
        }
    /]

    [#switch (_context.Mode)!"" ]
        [#case "DELV"]
            [@Command [ "python", "manage_production.py", "run_callback_delivery" ] /]
            [#break]

        [#case "SPRD"]
            [@Command [ "python", "manage_production.py", "run_callback_spreader" ] /]
            [#break]

        [#case "OBSV"]
            [@Command [ "python", "manage_production.py", "run_message_observer" ] /]
            [#break]
    [/#switch]

[#macro]
