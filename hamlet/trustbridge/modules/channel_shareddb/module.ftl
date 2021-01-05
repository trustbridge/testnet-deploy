[#ftl]

[@addModule
    name="channel_shareddb"
    description="A shared db channel for document sharing - generally used for testing"
    provider=TRUSTBRIDGE_PROVIDER
    properties=[
        {
            "Names" : "instance",
            "Description" : The id of the api instance",
            "Type" : STRING_TYPE,
            "Mandatory" : true
        },
        {
            "Names" : "jurisdiction",
            "Description" : The code of the local jurisdiction",
            "Type" : STRING_TYPE,
            "Mandatory" : true
        },
        {
            "Names" : "sentryDSN",
            "Description" : "The Sentry DSN for exception reporting",
            "Type" : STRING_TYPE,
            "Mandatory" : true
        },
        {
            "Names" : "kmsPrefix",
            "Description" : "The Sentry DSN for exception reporting",
            "Type" : STRING_TYPE,
            "Default" : "kms+base64"
        }
    ]
/]


[#macro trustbridge_module_channel_api
        instance
        sentryDSN
        kmsPrefix
    ]

    [@loadModule

        settingSets=[
            {
                "Type" : "Settings",
                "Scope" : "Products",
                "Namespace" : formatName( namespace, "sharedchannel", instance),
                "Settings" : {
                    "SENTRY_DSN" : sentryDSN,
                    "KMS_PREFIX" : kmsPrefix,
                    "JURISDICTION" : jurisdiction
                }
            },
            {
                "Type" : "Settings",
                "Scope" : "Products",
                "Namespace" : formatName( namespace, "sharedchannel-api", instance),
                "Settings" : {
                    "apigw" : {
                        "Internal" : true,
                        "Value" : {
                            "Type" : "lambda",
                            "Proxy" : false,
                            "BinaryTypes" : ["*/*"],
                            "ContentHandling" : "CONVERT_TO_TEXT",
                            "Variable" : "LAMBDA_API_LAMBDA",
                            "SecuritySchemes" : {
                                "oidc" : {
                                    "Type" : "openIdConnect",
                                    "Authorizer" : {
                                        "Type" : "cognito_user_pools",
                                        "Default" : true
                                    }
                                }
                            },
                            "OptionsSecurity" : "disabled",
                            "Security" : {
                                "auth" : {
                                    "Enabled" : true,
                                    "Scopes" : [ "https://sharedchannel" + instance + "/full" ]
                                }
                            }
                        }
                    }
                }
            }
        ]

        blueprint={
            "Tiers" : {
                "api" : {
                    "Components" : {
                        "sharedchannel" : {
                            "Title" : "Shared Channel API",
                            "APIGateway" : {
                                "Instances" : {
                                    instance : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : [ "sharedchannel-api-" + instance ]
                                            }
                                        }
                                    }
                                },
                                "Certificate" : {
                                    "IncludeInDomain" : {
                                        "Environment" : true
                                    },
                                    "IncludeInHost" : {
                                        "Product" : false,
                                        "Environment" : false,
                                        "Tier" : false,
                                        "Component" : true,
                                        "Instance" : true,
                                        "Version" : false,
                                        "Host" : false
                                    }
                                },
                                "EndpointType" : "REGIONAL",
                                "Mapping" : {
                                    "IncludeStage" : true
                                },
                                "WAF" : {
                                    "IPAddressGroups" : ["_global"]
                                },
                                "Links" : {
                                    "lambda" : {
                                        "Tier" : "api",
                                        "Component" : "sharedchannel-lambda",
                                        "Function" : "api"
                                    },
                                    "auth" : {
                                        "Tier" : "dir",
                                        "Component" : "auth-userpool",
                                        "Instance" : "",
                                        "Version" : ""
                                    }
                                }
                            }
                        },
                        "sharedchannel-lambda" : {
                            "Title" : "Lambda to support API",
                            "Lambda" : {
                                "Instances" : {
                                    instance : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : [ "sharedchannel-api-imp-" + instance]
                                            }
                                        },
                                        "Profiles" : {
                                            "Deployment" : [ "C1Endpoint"]
                                        }
                                    }
                                },
                                "RunTime" : "python3.6",
                                "MemorySize" : 256,
                                "Timeout" : 30,
                                "Profiles" : {
                                    "Deployment" : [ "SharedChannel"]
                                },
                                "Functions" : {
                                    "api" : {
                                        "Handler" : "wsgi_handler.handler",
                                        "PredefineLogGroup" : true,
                                        "Extensions" : [ "channel_shareddb" ],
                                        "Links"  : {
                                            "api" : {
                                                "Tier" : "api",
                                                "Component" : "sharedchannel",
                                                "Direction" : "inbound"
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "sharedutils-lambda" : {
                            "Title" : "Utility functions for shared channel deploy",
                            "Lambda" : {
                                "Instances" : {
                                    "default" : {
                                        "DeploymentUnits" : ["sharedchannel-utilities"]
                                    }
                                },
                                "RunTime" : "python3.6",
                                "MemorySize" : 256,
                                "Timeout" : 30,
                                "Functions" : {
                                    "dbupgrade" : {
                                        "Handler" : "manage_production.dbupgrade_handler",
                                        "PredefineLogGroup" : true,
                                        "Extensions" : [ "channel_shareddb" ],
                                        "Links"  : {
                                            "database" : {
                                                "Tier" : "db",
                                                "Component" : "sharedchannel-db",
                                                "Version" : ""
                                            },
                                            "api" : {
                                                "Tier" : "api",
                                                "Component" : "sharedchannel",
                                                "Instance" : "c1",
                                                "Version" : "v1"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "app" : {
                    "Components" : {
                        "app-ecs" : {
                            "Instances" : {
                                "default" : {
                                    "DeploymentUnits" : [ "app-ecs" ]
                                }
                            },
                            "Profiles" :{
                                "Processor" : "fargate"
                            },
                            "Services" : {
                                "sharedchannel-processor" : {
                                    "Instances" : {
                                        "delv" : {
                                            "Name" : "delivery",
                                            "Versions" : {
                                                "c1" : {
                                                    "DeploymentUnits" : [ "sharedchannel-delivery-c1" ],
                                                    "Profiles" : {
                                                        "Deployment" : [  "QueueWorker", "C1Endpoint"]
                                                    },
                                                    "ScalingPolicies" : {
                                                        "numberOfMessages" : {
                                                            "TrackingResource" : {
                                                                "Link" : {
                                                                    "Tier" : "msg",
                                                                    "Component" : "sharedchannel-sqs",
                                                                    "Instance" : "outbox",
                                                                    "Version" : "c1"
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "Profiles" : {
                                                "Deployment" : [  "QueueWorker"]
                                            },
                                            "Containers" : {
                                                "_processor-delv" : {
                                                    "Extensions" : [ "channel_shareddb" ],
                                                    "Cpu" : 256,
                                                    "Memory" : 512,
                                                    "MaximumMemory" : 512,
                                                    "Links" : {

                                                    }
                                                }
                                            }
                                        },
                                        "sprd" : {
                                            "Name" : "spreader",
                                            "Versions" : {
                                                "c1" : {
                                                    "DeploymentUnits" : [ "sharedchannel-spreader-c1" ],
                                                    "Profiles" : {
                                                        "Deployment" : [  "QueueWorker", "C1Endpoint"]
                                                    },
                                                    "ScalingPolicies" : {
                                                        "numberOfMessages" : {
                                                            "TrackingResource" : {
                                                                "Link" : {
                                                                    "Tier" : "msg",
                                                                    "Component" : "sharedchannel-sqs",
                                                                    "Instance" : "notifications",
                                                                    "Version" : "c1"
                                                                }
                                                            }
                                                        }
                                                    }

                                                }
                                            },
                                            "Profiles" : {
                                                "Deployment" : [  "QueueWorker"]
                                            },
                                            "Containers" : {
                                                "_processor-sprd" : {
                                                    "Extensions" : [ "channel_shareddb" ],
                                                    "Cpu" : 256,
                                                    "Memory" : 512,
                                                    "MaximumMemory" : 512,
                                                    "Links" : {

                                                    }
                                                }
                                            }

                                        },
                                        "obsv" : {
                                            "Name" : "observer",
                                            "Versions" : {
                                                "c1" : {
                                                    "DeploymentUnits" : [ "sharedchannel-observer-c1" ],
                                                    "Profiles" : {
                                                        "Deployment" : [  "C1Endpoint"]
                                                    }
                                                }
                                            },
                                            "Profiles" : {
                                                "Deployment" : [ "SharedChannel"],
                                                "Processor" : "default"
                                            },
                                            "Engine" : "fargate",
                                            "NetworkMode" : "awsvpc",
                                            "Containers" : {
                                                "_processor-obsv" : {
                                                    "Extensions" : [ "channel_shareddb" ],
                                                    "Cpu" : 256,
                                                    "Memory" : 512,
                                                    "MaximumMemory" : 512
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "msg" : {
                    "Components" : {
                        "sharedchannel-s3" : {
                            "s3" : {
                                "DeploymentUnits" : [ "sharedchannel-stage"],
                                "Instances" : {
                                    "sub" : {
                                        "Versions" : {
                                            instance : {}
                                        }
                                    },
                                    "chn" : {
                                        "Versions" : {
                                            instance : {}
                                        }
                                    }
                                }
                            }
                        },
                        "sharedchannel-sqs" : {
                            "sqs" : {
                                "Instances" : {
                                    "notifications" : {
                                        "Versions" : {
                                            instance : {
                                                "DeploymentUnits" : [ "sharedchannel-queues-" + instance ]
                                            }
                                        }
                                    },
                                    "outbox" : {
                                        "Versions" : {
                                           instance : {
                                                "DeploymentUnits" : [ "sharedchannel-queues-" + instance ]
                                            }
                                        }
                                    }
                                },
                                "DeadLetterQueue" : {
                                    "MaxReceives" : 10
                                }
                            }
                        }
                    }
                },
                "db" : {
                    "Components" : {
                        "sharedchannel-db" : {
                            "db" : {
                                "Instances" : {
                                    "default" : {
                                        "DeploymentUnits" : [ "sharedchannel-db"]
                                    }
                                },
                                "Engine" : "aurora-postgresql",
                                "EngineVersion" : "10",
                                "Size" : 20,
                                "GenerateCredentials" : {
                                    "Enabled" : true,
                                    "EncryptionScheme" : kmsPrefix
                                },
                                "Backup" : {
                                    "RetentionPeriod" : 14,
                                    "SnapshotOnDeploy" : true,
                                    "DeletionPolicy" : "Delete",
                                    "UpdateReplacePolicy" : "Delete",
                                    "DeleteAutoBackups" : true
                                },
                                "Cluster" : {
                                    "Parameters" : {
                                        "ClientSSL" : {
                                            "Name" : "rds.force_ssl",
                                            "Value" : 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "dir" : {
                    "Components" : {
                        "auth-userpool" : {
                            "Title" : "API Authentication using oAuth",
                            "userpool" : {
                                "Instances" : {
                                    "default" : {
                                        "DeploymentUnits" : [ "auth-userpool"]
                                    }
                                },
                                "MFA" : true,
                                "UnusedAccountTimeout" : 7,
                                "AdminCreatesUser" : true,
                                "VerifyEmail" : true,
                                "VerifyPhone" : true,
                                "MFAMethods" : [ "SMS" ],
                                "Username" : {
                                    "CaseSensitive" : false,
                                    "Attributes" : [ "email" ],
                                    "Aliases" : []
                                },
                                "Schema" : {
                                    "email" : {
                                        "DataType" : "String",
                                        "Mutable" : true,
                                        "Required" : true
                                    },
                                    "phone_number" : {
                                        "DataType" : "String",
                                        "Mutable" : true,
                                        "Required" : false
                                    }
                                },
                                "HostedUI" : {},
                                "PasswordPolicy" : {
                                    "MinimumLength" : 10,
                                    "Lowercase" : false,
                                    "Uppercase" : false,
                                    "Numbers" : false,
                                    "SpecialCharacters" : false
                                },
                                "Security" : {
                                    "UserDeviceTracking" : true,
                                    "ActivityTracking" : "enforced"
                                },
                                "DefaultClient" : false,
                                "Resources" : {
                                    "sharedchannel" + instance : {
                                        "Server" : {
                                            "Link" : {
                                                "Tier" : "api",
                                                "Component" : "sharedchannel",
                                                "Instance" : instance,
                                                "Version" : "v1"
                                            }
                                        },
                                        "Scopes" : {
                                            "full" : {
                                                "Name" : "full",
                                                "Description" : "Full access to the API"
                                            }
                                        }
                                    }
                                },
                                "Clients" : {
                                    "developer" : {
                                        "Profiles" : {
                                            "Deployment" : [ "apiClient" ]
                                        },
                                        "ResourceScopes" : {
                                            "sharedchannel" + instance : {
                                            "Name" : "sharedchannel" + instance,
                                            "Scopes" : [ "full" ]
                                            }
                                        }
                                    },
                                    "intergov" : {
                                        "Instances" : {
                                            instance : {
                                                "ResourceScopes" : {
                                                    "sharedchannel" + instance : {
                                                        "Name" : "sharedchannel" + instance,
                                                        "Scopes" : [ "full" ]
                                                    }
                                                }
                                            }
                                        },
                                        "Profiles" : {
                                            "Deployment" : [ "apiClient" ]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            "DeploymentProfiles" : {
                "Endpoint" + instance : {
                    "Modes" : {
                        "*" : {
                            "*" : {
                                "Links" : {
                                    "QUE_IGL_NOTIFICATIONS_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "sharedchannel-sqs",
                                        "Instance" : "notifications",
                                        "Version" : instance,
                                        "Role" : "all"
                                    },
                                    "QUE_IGL_DELIVERY_OUTBOX_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "sharedchannel-sqs",
                                        "Instance" : "outbox",
                                        "Version" : instance,
                                        "Role" : "all"
                                    },
                                    "BKT_IGL_SUBSCRIPTIONS_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "sharedchannel-s3",
                                        "Instance" : "sub",
                                        "Version" : instance,
                                        "Role" : "all"
                                    },
                                    "HUB" : {
                                        "Tier" : "api",
                                        "Component" : "sharedchannel",
                                        "Instance" : instance,
                                        "Version" : "v1"
                                    },
                                    "BKT_IGL_CHANNEL_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "sharedchannel-s3",
                                        "Instance" : "chn",
                                        "Version" : instance,
                                        "Role" : "all"
                                    },
                                    "DATABASE" : {
                                        "Tier" : "db",
                                        "Component" :"sharedchannel-db",
                                        "Instance" : "",
                                        "Version" : ""
                                    }
                                },
                                "SettingNamespaces" : {
                                    instance : {
                                        "Name" : "sharedchannel-" + instance,
                                        "Match" : "partial",
                                        "IncludeInNamespace" : {
                                            "Tier" : false,
                                            "Component" : false,
                                            "Type" : false,
                                            "SubComponent" : false,
                                            "Instance" : false,
                                            "Version" : false,
                                            "Name" : true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


[/#macro]
