[#ftl]

[@addExtension
    id="intergov_services"
    aliases=[
        "_intergov_srv"
    ]
    description=[
        "Provides the configuration shared between the api and processor components in the intergov module"
    ]
    supportedTypes=[
        ECS_SERVICE_COMPONENT_TYPE,
        ECS_TASK_COMPONENT_TYPE,
        LAMBDA_COMPONENT_TYPE,
        LAMBDA_FUNCTION_COMPONENT_TYPE
    ]
/]


[#macro shared_extension_intergov_services_deployment_setup occurrence ]

    [@DefaultLinkVariables enabled=false /]
    [@DefaultCoreVariables enabled=false /]
    [@DefaultEnvironmentVariables enabled=false /]
    [@DefaultBaselineVariables enabled=false /]


    [#assign awsRegion = (_context.DefaultEnvironment["AWS_REGION"])!"ap-southeast-2" ]

    [@Settings
        [
            "KMS_PREFIX",
            "SENTRY_DSN",
            "IGL_JURISDICTION"
        ]
    /]

    [@AltSettings
        {
            "IGL_APP_JURISDICTION" : "IGL_JURISDICTION"
        }
    /]

    [#-- Custom Cloudwatch Metrics --]
    [#assign iglMetricsNamespace = "IGL" ]
    [@Settings
        {
            "CLOUDWATCH_NAMESPACE" : iglMetricsNamespace,
            "SEND_CLOUDWATCH_METRICS" : "true"
        }
    /]
    [@Policy
        [
            getPolicyStatement(
                [ "cloudwatch:PutMetricData" ],
                "*",
                "",
                {
                    "StringEquals" : {
                        "cloudwatch:namespace" : iglMetricsNamespace
                    }
                }
            )
        ]
    /]

    [@Settings
        {
            "SENTRY_ENVIRONMENT"            : _context.DefaultEnvironment["ENVIRONMENT"]!"",
            "SENTRY_RELEASE"                : _context.DefaultEnvironment["APP_REFERENCE"]!(_context.DefaultEnvironment["BUILD_REFERENCE"]!""),
            "IGL_MCHR_ROUTING_TABLE"        : _context.DefaultEnvironment["IGL_MCHR_ROUTING_TABLE"]!"",
            "IGL_JURISDICTION_OAUTH_CLIENT_ID"   : _context.DefaultEnvironment["IGL_JURISDICTION_OAUTH_CLIENT_ID"]!"",
            "IGL_JURISDICTION_OAUTH_CLIENT_SECRET"   : _context.DefaultEnvironment["IGL_JURISDICTION_OAUTH_CLIENT_SECRET"]!"",
            "IGL_JURISDICTION_OAUTH_SCOPES"      : _context.DefaultEnvironment["IGL_JURISDICTION_OAUTH_SCOPES"]!"",
            "IGL_JURISDICTION_OAUTH_WELLKNOWN_URL" : _context.DefaultEnvironment["IGL_JURISDICTION_OAUTH_WELLKNOWN_URL"]!"",
            "IGL_JURISDICTION_DOCUMENT_REPORTS"  : _context.DefaultEnvironment["IGL_JURISDICTION_DOCUMENT_REPORTS"]!"",
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

        [#if env?starts_with("DB") && env?ends_with("NAME") ]

            [#assign envvar = (env?remove_beginning("DB_"))?remove_ending("_NAME") ]
            [#assign host = (_context.DefaultEnvironment[ (env?remove_ending("_NAME")?ensure_ends_with("_FQDN"))])!"" ]
            [#assign user = (_context.DefaultEnvironment[ (env?remove_ending("_NAME")?ensure_ends_with("_USERNAME"))])!"" ]
            [#assign password = (_context.DefaultEnvironment[ (env?remove_ending("_NAME")?ensure_ends_with("_PASSWORD"))])!""]
            [@Settings
                {
                    envvar + "_HOST"            : host,
                    envvar + "_USER"            : user,
                    envvar + "_PASSWORD"        : password,
                    envvar + "_DBNAME"          : value
                }
            /]
        [/#if]

        [#if env == "IGL_PROC_BCH_MESSAGE_RX_API_URL" ]
            [@Settings
                [
                    "IGL_PROC_BCH_MESSAGE_RX_API_URL"
                ]
            /]
        [/#if]

        [#if env == "IGL_PROC_BCH_MESSAGE_API_URL" ]
            [@Settings
                {
                    "IGL_PROC_BCH_MESSAGE_API_ENDPOINT" : formatRelativePath( value, "message", "{sender}:{sender_ref}" )
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

    [#-- docker command overrides --]
    [#assign pythonPath = {
        "PYTHONPATH" : "/src/"
    }]

    [#switch (_context.Mode)!"" ]
        [#case "MSG"]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/message_processor/__init__.py" ] /]
            [#break]
        [#case "CALLBDEL"]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/callback_deliver/__init__.py" ] /]
            [#break]
        [#case "CALLBSPD"]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/callbacks_spreader/__init__.py" ] /]
            [#break]
        [#case "REJSTAT" ]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/rejected_status_updater/__init__.py" ] /]
            [#break]
        [#case "CHANNELROUTER" ]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/multichannel_router/__init__.py" ] /]
            [#break]
        [#case "DOCSPIDER"]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/obj_spider/__init__.py" ] /]
            [#break]
        [#case "CHANNELPOLLER"]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/channel_poller/__init__.py" ] /]
            [#break]
        [#case "MSGUPDATER" ]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/message_updater/__init__.py" ] /]
            [#break]
        [#case "SUBHANDLER" ]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/subscription_handler/__init__.py" ] /]
            [#break]
        [#case "CHNMSGRET"]
            [@Settings pythonPath /]
            [@Command [ "python", "intergov/processors/channel_message_retriever/__init__.py" ] /]
            [#break]
    [/#switch]

[/#macro]
