[#ftl]

[@addModule
    name="channel_api"
    description="A API based document sharing implementation"
    provider=TRUSTBRIDGE_PROVIDER
    properties=[
        {
            "Names" : "foreignEndpointUrl",
            "Description" : "The Url of the foreign API to send documents to",
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


[#macro trustbridge_module_channel_api foreignEndpointUrl]
    [@loadModule

        settingSets=[
            {
                "Type" : "Settings",
                "Scope" : "Products",
                "Namespace" : formatName( namespace, "apichannel"),
                "Settings" : {
                    "FOREIGN_ENDPOINT_URL" : foreignEndpointUrl,
                    "Testing" : "False,
                    "SENTRY_DSN" : sentryDSN,
                    "KMS_PREFIX" : kmsPrefix
                }
            },
            {
                "Type" : "Settings",
                "Scope" : "Products",
                "Namespace" : formatName( namespace, "apichannel-api"),
                "Settings" : {
                    "apigw" : {
                        "Internal" : true,
                        "Value" : {
                            "Type" : "lambda",
                            "Proxy" : false,
                            "BinaryTypes" : ["*/*"],
                            "ContentHandling" : "CONVERT_TO_TEXT",
                            "Variable" : "LAMBDA_API_LAMBDA"
                        }
                    }
                }
            }
        ]

        blueprint={
            "Tiers" : {
                "api" : {
                    "Components" : {
                        "apichannel" : {
                            "Title" : "API Channel",
                            "APIGateway" : {
                                "Instances" : {
                                    "default" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["apichannel-api"]
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
                                "Profiles" : {
                                    "Deployment" : [ "APIChannel" ]
                                },
                                "Links" : {
                                    "lambda" : {
                                        "Tier" : "api",
                                        "Component" : "apichannel-lambda",
                                        "Function" : "api"
                                    }
                                }
                            }
                        },
                        "apichannel-lambda" : {
                            "Title" : "Lambda to support Ethereum Channel API",
                            "Lambda" : {
                                "Instances" : {
                                    "default" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["apichannel-api-imp"]
                                            }
                                        }
                                    }
                                },
                                "RunTime" : "python3.6",
                                "MemorySize" : 256,
                                "Timeout" : 30,
                                "Profiles" : {
                                    "Deployment" : [ "APIChannel" ]
                                },
                                "Functions" : {
                                    "api" : {
                                        "Handler" : "wsgi_handler.handler",
                                        "PredefineLogGroup" : true,
                                        "Extensions" : [ "_channel_api" ],
                                        "Links"  : {
                                            "API" : {
                                                "Tier" : "api",
                                                "Component" : "apichannel",
                                                "Direction" : "inbound"
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
                            "ecs" : {
                                "Instances" : {
                                    "default" : {
                                        "DeploymentUnits" : [ "app-ecs" ]
                                    }
                                },
                                "Profiles" : {
                                    "Processor" : "default"
                                },
                                "Services" : {
                                    "apichannel-processor" : {
                                        "Instances" : {
                                            "delv" : {
                                                "Name" : "delivery",
                                                "DeploymentUnits" : [ "apichannel-delivery" ],
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "apichannel-sqs",
                                                                "Instance" : "delvoutbox",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Profiles" : {
                                                    "Deployment" : [ "APIChannel", "QueueWorker"]
                                                },
                                                "Containers" : {
                                                    "_apichannelprocessor-delv" : {
                                                        "Extensions" : [ "_channel_api" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512
                                                    }
                                                }
                                            },
                                            "sendproc" : {
                                                "Name" : "sendprocessor",
                                                "DeploymentUnits" : [ "apichannel-sendproc" ],
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "apichannel-sqs",
                                                                "Instance" : "channel",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Profiles" : {
                                                    "Deployment" : [ "APIChannel", "QueueWorker"]
                                                },
                                                "Containers" : {
                                                    "_apichannelprocessor-sendproc" : {
                                                        "Extensions" : [ "_channel_api" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512
                                                    }
                                                }
                                            },
                                            "sprd" : {
                                                "Name" : "spreader",
                                                "DeploymentUnits" : [ "apichannel-spreader" ],
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "apichannel-sqs",
                                                                "Instance" : "notifications",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Profiles" : {
                                                    "Deployment" : [ "APIChannel", "QueueWorker"]
                                                },
                                                "Containers" : {
                                                    "_apichannelprocessor-sprd" : {
                                                        "Extensions" : [ "_channel_api" ]
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
                    }
                },
                "msg" : {
                    "Components" : {
                        "apichannel-s3" : {
                            "s3" : {
                                "DeploymentUnits" : [ "apichannel-s3"],
                                "Instances" : {
                                    "sub" : {},
                                    "channel": {}
                                }
                            }
                        },
                        "apichannel-sqs" : {
                            "sqs" : {
                                "DeploymentUnits" : [ "apichannel-sqs" ],
                                "Instances" : {
                                    "notifications" : { },
                                    "delvoutbox" : {},
                                    "channel" : {}
                                },
                                "DeadLetterQueue" : {
                                    "MaxReceives" : 20
                                }
                            }
                        }
                    }
                }
            },
            "DeploymentProfiles" : {
                "QueueWorker" : {
                    "Modes" : {
                        "*" : {
                            "service" : {
                                "Engine" : "fargate",
                                "NetworkMode" : "awsvpc",
                                "Profiles" : {
                                    "Processor" : "QueueWorker"
                                },
                                "ScalingPolicies" : {
                                    "numberOfMessages" : {
                                        "Type" : "Stepped",
                                        "TrackingResource" : {
                                            "Link" : {
                                                "Tier" : "msg",
                                                "Component" : "_REPLACEWITHLINK_",
                                                "Instance" : "_REPLACEWITHLINK_",
                                                "Version" : "_REPLACEWITHLINK_"
                                            },
                                            "MetricTrigger" : {
                                                "Namespace": "AWS/SQS",
                                                "Name" : "NumberOfMessages",
                                                "Metric" : "ApproximateNumberOfMessagesVisible",
                                                "Threshold" : 0,
                                                "Severity" : "info",
                                                "Statistic" : "Sum",
                                                "Operator" : "GreaterThanThreshold",
                                                "Periods" : 1,
                                                "Time" : 60,
                                                "Resource" : {
                                                    "Id" : "queue"
                                                }
                                            }
                                        },
                                        "Stepped" : {
                                            "CapacityAdjustment" : "Exact",
                                            "Adjustments": {
                                                "out1" : {
                                                    "LowerBound": 1,
                                                    "UpperBound": 1000,
                                                    "AdjustmentValue": 1
                                                },
                                                "out2" : {
                                                    "LowerBound": 1000,
                                                    "AdjustmentValue": 2
                                                },
                                                "in1" : {
                                                    "UpperBound": 1,
                                                    "AdjustmentValue": 0
                                                }
                                            }
                                        },
                                        "Cooldown" : {
                                            "ScaleOut" : 10,
                                            "ScaleIn" : 300
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "APIChannel" : {
                    "Modes" : {
                        "*" : {
                            "*" : {
                                "SettingNamespaces" : {
                                    "apichannel" : {
                                        "Name" : "apichannel",
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
                                },
                                "Links"  : {
                                    "API" : {
                                        "Tier" : "api",
                                        "Component" : "apichannel",
                                        "Instance" : "",
                                        "Version" : "v1"
                                    },
                                    "QUE_IGL_DELIVERY_OUTBOX_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "apichannel-sqs",
                                        "Instance" : "delvoutbox",
                                        "Version" : "",
                                        "Role" : "all"
                                    },
                                    "BKT_IGL_SUBSCRIPTIONS_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "apichannel-s3",
                                        "Instance" : "sub",
                                        "Version" : "",
                                        "Role" : "all"
                                    },
                                    "QUE_IGL_NOTIFICATIONS_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "apichannel-sqs",
                                        "Instance" : "notifications",
                                        "Version" : "",
                                        "Role" : "all"
                                    },
                                    "BKT_IGL_CHANNEL_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "apichannel-s3",
                                        "Instance" : "channel",
                                        "Version" : "",
                                        "Role" : "all"
                                    },
                                    "QUE_IGL_CHANNEL_QUEUE_REPO" : {
                                        "Tier" : "msg",
                                        "Component" : "apichannel-sqs",
                                        "Instance" : "channel",
                                        "Version" : "",
                                        "Role" : "all"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

[/#macro]
