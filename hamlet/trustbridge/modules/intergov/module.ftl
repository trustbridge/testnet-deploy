[#ftl]

[@addModule
    name="intergov"
    description="The intergov document store API services and their data stores"
    provider=TRUSTBRIDGE_PROVIDER
    properties=[

    ]

/]


[#macro trustbridge_module_intergov]

    [@loadModule

        blueprint={
            "Tiers" : {
                "api" : {
                    "Components" : {
                        "api" : {
                            "Title" : "external facing apis",
                            "APIGateway" : {
                                "Instances" : {
                                    "document" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["document-api"]
                                            }
                                        }

                                    },
                                    "message" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["message-api"]
                                            }
                                        }

                                    },
                                    "messagerx" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["messagerx-api"]
                                            }
                                        }

                                    },
                                    "subscriptions" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["subscriptions-api"]
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
                                        "Component" : false,
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
                                    "IPAddressGroups" : ["_global"],
                                    "OWASP" : false
                                },
                                "AccessLogging" : {
                                    "aws:KinesisFirehose" : true
                                },
                                "Links" : {
                                    "lambda" : {
                                        "Tier" : "api",
                                        "Component" : "api-lambda",
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
                        "api-lambda" : {
                            "Lambda" : {
                                "Instances" : {
                                    "document" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["document-api-imp"]
                                            }
                                        },
                                        "Links"  : {
                                            "BKT_IGL_DOCAPI_OBJ_LAKE" : {
                                                "Tier" : "db",
                                                "Component" : "repo-s3",
                                                "Instance" : "objlake",
                                                "Version" : "",
                                                "Role" : "all"
                                            },
                                            "BKT_IGL_DOCAPI_OBJ_ACL" : {
                                                "Tier" : "db",
                                                "Component" : "repo-s3",
                                                "Instance" : "objacl",
                                                "Version" : "",
                                                "Role" : "all"
                                            },
                                            "api" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Direction" : "inbound",
                                                "Version" : "v1"
                                            }
                                        }
                                    },
                                    "message" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["message-api-imp"]
                                            }
                                        },
                                        "Links"  : {
                                            "BKT_IGL_MSGAPI_MESSAGE_LAKE" : {
                                                "Tier" : "db",
                                                "Component" : "repo-s3",
                                                "Instance" : "msglake",
                                                "Version" : "",
                                                "Role" : "all"
                                            },
                                            "QUE_IGL_MSG_RX_API_BC_INBOX" : {
                                                "Tier" : "msg",
                                                "Component" : "repo-sqs",
                                                "Instance" : "bcin",
                                                "Version" : "",
                                                "Role" : "produce"
                                            },
                                            "QUE_IGL_MSG_RX_API_OUTBOX_REPO" : {
                                                "Tier" : "msg",
                                                "Component" : "repo-sqs",
                                                "Instance" : "pubout",
                                                "Version" : "",
                                                "Role" : "produce"
                                            },
                                            "api" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Direction" : "inbound",
                                                "Version" : "v1"
                                            }
                                        }
                                    },
                                    "messagerx" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["messagerx-api-imp"]
                                            }
                                        },
                                        "Profiles" : {
                                            "Deployment" : [ "Processor" ]
                                        },
                                        "Links"  : {
                                            "QUE_IGL_MSG_RX_API_BC_INBOX" : {
                                                "Tier" : "msg",
                                                "Component" : "repo-sqs",
                                                "Instance" : "bcin",
                                                "Version" : "",
                                                "Role" : "produce"
                                            },
                                            "QUE_IGL_CHANNEL_NOTIFICATION_REPO" : {
                                                "Tier" : "msg",
                                                "Component" : "repo-sqs",
                                                "Instance" : "chnnot",
                                                "Version" : "",
                                                "Role" : "all"
                                            },
                                            "api" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Direction" : "inbound",
                                                "Version" : "v1"
                                            }
                                        }
                                    },
                                    "subscriptions" : {
                                        "Versions" : {
                                            "v1" : {
                                                "DeploymentUnits" : ["subscriptions-api-imp"]
                                            }
                                        },
                                        "Links" : {
                                            "BKT_IGL_SUBSCR_API_REPO" : {
                                                "Tier" : "db",
                                                "Component" : "repo-s3",
                                                "Instance" : "sub",
                                                "Version" : "",
                                                "Role" : "all"
                                            },
                                            "api" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Direction" : "inbound",
                                                "Version" : "v1"
                                            }
                                        }
                                    }
                                },
                                "RunTime" : "python3.6",
                                "MemorySize" : 256,
                                "Timeout" : 30,
                                "Functions" : {
                                    "api" : {
                                        "Handler" : "wsgi_handler.handler",
                                        "PredefineLogGroup" : true,
                                        "Fragment" : "_intergov_srv",
                                        "Environment" : {
                                            "Json" : {
                                                "Prefix" : ""
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
                            "ECS" : {
                                "Instances" : {
                                    "default" : {
                                        "DeploymentUnits" : ["app-ecs"]
                                    }
                                },
                                "Profiles" : {
                                    "Processor" : "fargate"
                                },
                                "Services" : {
                                    "processor" : {
                                        "Instances" : {
                                            "msg" : {
                                                "Name" : "message",
                                                "DeploymentUnits" : ["proc-msg"],
                                                "Profiles" : {
                                                    "Deployment" : [ "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "bcin",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-msg" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_PROC_BC_INBOX" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "bcin",
                                                                "Version" : "",
                                                                "Role" : "consume"
                                                            },
                                                            "QUE_IGL_PROC_OBJ_RETR_REPO" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "objret",
                                                                "Version" : "",
                                                                "Role" : "produce"
                                                            },
                                                            "QUE_IGL_PROC_OBJ_OUTBOX_REPO" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "pubout",
                                                                "Version" : "",
                                                                "Role" : "produce"
                                                            },
                                                            "BKT_IGL_PROC_MESSAGE_LAKE" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-s3",
                                                                "Instance" : "msglake",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            },
                                                            "BKT_IGL_PROC_OBJECT_ACL_REPO" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-s3",
                                                                "Instance" : "objacl",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            },
                                                            "DB_IGL_PROC_BCH_OUTBOX_REPO" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-rds",
                                                                "Instance" : "apiout",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                }

                                            },
                                            "callbdel" : {
                                                "Name" : "callbackdeliver",
                                                "DeploymentUnits" : ["proc-callbdel"],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "dlvout",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-callbdel" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_PROC_DELIVERY_OUTBOX_REPO" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "dlvout",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "callbspd" : {
                                                "Name" : "callbackspread",
                                                "DeploymentUnits" : [ "proc-callbspd"],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "pubout",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-callbspd" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_PROC_OBJ_OUTBOX_REPO" :{
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "pubout",
                                                                "Version" : "",
                                                                "Role" : "consume"
                                                            },
                                                            "QUE_IGL_PROC_DELIVERY_OUTBOX_REPO" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "dlvout",
                                                                "Version" : "",
                                                                "Role" : "produce"
                                                            },
                                                            "BKT_IGL_PROC_SUB_REPO" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-s3",
                                                                "Instance" : "sub",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "rejstat" : {
                                                "Name" : "rejectedstatus",
                                                "DeploymentUnits" : ["proc-rejstat"],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "rejmsg",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-rejstat" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_PROC_REJECTED_MESSAGES_REPO" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "rejmsg",
                                                                "Version" : "",
                                                                "Role" : "consume"
                                                            },
                                                            "BKT_IGL_PROC_MESSAGE_LAKE_REPO" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-s3",
                                                                "Instance" : "msglake",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            }
                                                        }
                                                    }
                                                }

                                            },
                                            "channelrouter" : {
                                                "Name" : "channelrouter",
                                                "DeploymentUnits" : [ "proc-channelrouter" ],
                                                "Profiles" : {
                                                    "Deployment" : [ "Processor" ]
                                                },
                                                "Containers" : {
                                                    "_processor-channelrouter" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "DB_IGL_PROC_BCH_OUTBOX" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-rds",
                                                                "Instance" : "apiout",
                                                                "Version" : ""
                                                            },
                                                            "QUE_IGL_PROC_BCH_CHANNEL_PENDING_MESSAGE" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "chnpendmsg",
                                                                "Version" : "",
                                                                "Role" : "produce"
                                                            },
                                                            "QUE_IGL_BCH_MESSAGE_UPDATES" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "msgups",
                                                                "Version" : "",
                                                                "Role" : "produce"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "docspider" : {
                                                "Name" : "docspider",
                                                "DeploymentUnits" : [ "proc-docspider" ],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "objret",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-docspider" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "BKT_IGL_PROC_OBJ_SPIDER_OBJ_LAKE" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-s3",
                                                                "Instance" : "objlake",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            },
                                                            "QUE_IGL_PROC_OBJ_SPIDER_OBJ_RETRIEVAL" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "objret",
                                                                "Version" : "",
                                                                "Role" : "consume"
                                                            },
                                                            "BKT_IGL_PROC_OBJ_SPIDER_OBJ_ACL" : {
                                                                "Tier" : "db",
                                                                "Component" : "repo-s3",
                                                                "Instance" : "objacl",
                                                                "Version" : "",
                                                                "Role" : "all"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "channelpoller" : {
                                                "Name" : "channelpoller",
                                                "DeploymentUnits" : [ "proc-channelpoller" ],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "chnpendmsg",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-channelpoller" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_PROC_BCH_CHANNEL_PENDING_MESSAGE" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "chnpendmsg",
                                                                "Role" : "consume"
                                                            },
                                                            "QUE_IGL_BCH_MESSAGE_UPDATES" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "msgups",
                                                                "Role" : "produce"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "msgupdater" : {
                                                "Name" : "msgupdater",
                                                "DeploymentUnits" : [ "proc-msgupdater" ],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor", "QueueWorker"]
                                                },
                                                "ScalingPolicies" : {
                                                    "numberOfMessages" : {
                                                        "TrackingResource" : {
                                                            "Link" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "msgups",
                                                                "Version" : ""
                                                            }
                                                        }
                                                    }
                                                },
                                                "Containers" : {
                                                    "_processor-msgupdater" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_BCH_MESSAGE_UPDATES" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "msgups",
                                                                "Role" : "all"
                                                            },
                                                            "IGL_PROC_BCH_MESSAGE_API" : {
                                                                "Tier" : "api",
                                                                "Component" : "api",
                                                                "Instance" : "message",
                                                                "Version" : "v1"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "subhandler" : {
                                                "Name" : "subhandler",
                                                "DeploymentUnits" : [ "proc-subhandler" ],
                                                "Profiles" : {
                                                    "Deployment" : [  "Processor" ]
                                                },
                                                "Containers" : {
                                                    "_processor-subhandler" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "IGL_PROC_BCH_MESSAGE_RX_API" : {
                                                                "Tier" : "api",
                                                                "Component" : "api",
                                                                "Instance" : "messagerx",
                                                                "Version" : "v1"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "chnmsgret" : {
                                                "Name" : "chnmsgretriever",
                                                "DeploymentUnits" : [ "proc-chnmsgret" ],
                                                "Profiles" : {
                                                    "Deployment" : [ "Processor" ]
                                                },
                                                "Containers" : {
                                                    "_processor-chnmsgret" : {
                                                        "Extensions" : [ "_intergov_srv" ]
                                                        "Cpu" : 256,
                                                        "Memory" : 512,
                                                        "MaximumMemory" : 512,
                                                        "Links" : {
                                                            "QUE_IGL_CHANNEL_NOTIFICATION_REPO" : {
                                                                "Tier" : "msg",
                                                                "Component" : "repo-sqs",
                                                                "Instance" : "chnnot",
                                                                "Role" : "all"
                                                            },
                                                            "QUE_IGL_PROC_BC_INBOX": {
                                                                "Tier": "msg",
                                                                "Component": "repo-sqs",
                                                                "Instance": "bcin",
                                                                "Version": "",
                                                                "Role": "produce"
                                                            }
                                                        }
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
                        "repo-sqs" : {
                            "SQS" : {
                                "Instances" : {
                                    "apiin" :{
                                        "Name" : "apiinbox",
                                        "DeploymentUnits" : [ "repo-sqs-a"]
                                    },
                                    "bcin" : {
                                        "Name" : "bcinbox",
                                        "DeploymentUnits" : [ "repo-sqs-a"]
                                    },
                                    "dlvout" : {
                                        "Name" : "deliveryoutbox",
                                        "DeploymentUnits" : [ "repo-sqs-a"]
                                    },
                                    "objret" : {
                                        "Name" : "objectretrieval",
                                        "DeploymentUnits" : [ "repo-sqs-b"]
                                    },
                                    "pubout" : {
                                        "Name" : "publishoutbox",
                                        "DeploymentUnits" : [ "repo-sqs-b"]
                                    },
                                    "rejmsg" : {
                                        "Name" : "rejectedmessage",
                                        "DeploymentUnits" : [ "repo-sqs-b"]
                                    },
                                    "chnpendmsg" : {
                                        "Name" : "channelpendingmessage",
                                        "DeploymentUnits" : [ "repo-sqs-c"]
                                    },
                                    "msgups" : {
                                        "Name" : "messageupdates",
                                        "DeploymentUnits" : [ "repo-sqs-c" ]
                                    },
                                    "chnnot" : {
                                        "Name" : "channelnotifications",
                                        "DeploymentUnits" : [ "repo-sqs-c"]
                                    }
                                },
                                "MessageRetentionPeriod" : 345600,
                                "VisibilityTimeout" : 90,
                                "DeadLetterQueue" : {
                                    "MaxReceives" : 20
                                },
                                "Alerts": {
                                    "delays": {
                                        "Resource": {
                                            "Id": "queue"
                                        },
                                        "Name": "ProcessingDelays",
                                        "Severity": "warn",
                                        "Description": "Messages are being retried",
                                        "Metric": "ApproximateAgeOfOldestMessage",
                                        "Threshold": 900,
                                        "Statistic": "Maximum",
                                        "Time": 300
                                    },
                                    "failures": {
                                        "Resource": {
                                            "Id": "dlq"
                                        },
                                        "Name": "ProcessingFailures",
                                        "Severity": "error",
                                        "Description": "Messages are being rejected",
                                        "Metric": "ApproximateNumberOfMessagesVisible",
                                        "Threshold": 1,
                                        "Statistic": "Minimum",
                                        "Time": 300
                                    }
                                }
                            }
                        }
                    }
                },
                "db" : {
                    "Components" : {
                        "repo-s3" : {
                            "S3" : {
                                "Instances" : {
                                    "msglake" : {
                                        "Name" : "messagelake",
                                        "DeploymentUnits" : [ "repo-s3-a"]
                                    },
                                    "objacl" : {
                                        "Name" : "objectacl",
                                        "DeploymentUnits" : [ "repo-s3-a"]
                                    },
                                    "objlake" : {
                                        "Name" : "objectlake",
                                        "DeploymentUnits" : [ "repo-s3-a"]
                                    },
                                    "sub" : {
                                        "Name" : "subscriptions",
                                        "DeploymentUnits" : [ "repo-s3-b"]
                                    }
                                }
                            }
                        },
                        "repo-rds" : {
                            "RDS" : {
                                "Instances" : {
                                    "apiout" : {
                                        "Name" : "apioutbox",
                                        "DeploymentUnits" : [ "repo-rds-apiout"]
                                    }
                                },
                                "Engine" : "aurora-postgresql",
                                "EngineVersion" : "10",
                                "GenerateCredentials" : {
                                    "Enabled" : true,
                                    "EncryptionScheme" : "kms+base64"
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
                                "MFAMethods" : [ "SMS", "SoftwareToken" ],
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
                                "AuthProviders" : {
                                    "GlobalAuth" : {
                                        "Profiles" : {
                                            "Deployment" : [ "federatedAuth" ]
                                        }
                                    }
                                },
                                "Resources" : {
                                    "document" : {
                                        "Server" : {
                                            "Link" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Instance" : "document",
                                                "Version" : "v1"
                                            }
                                        },
                                        "Scopes" : {
                                            "full" : {
                                                "Name" : "full",
                                                "Description" : "Full access to the API"
                                            }
                                        }
                                    },
                                    "message" : {
                                        "Server" : {
                                            "Link" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Instance" : "message",
                                                "Version" : "v1"
                                            }
                                        },
                                        "Scopes" : {
                                            "full" : {
                                                "Name" : "full",
                                                "Description" : "Full access to the API"
                                            }
                                        }
                                    },
                                    "messagerx" : {
                                        "Server" : {
                                            "Link" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Instance" : "messagerx",
                                                "Version" : "v1"
                                            }
                                        },
                                        "Scopes" : {
                                            "full" : {
                                                "Name" : "full",
                                                "Description" : "Full access to the API"
                                            }
                                        }
                                    },
                                    "subscriptions" : {
                                        "Server" : {
                                            "Link" : {
                                                "Tier" : "api",
                                                "Component" : "api",
                                                "Instance" : "subscriptions",
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
                                            "document" : {
                                            "Name" : "document",
                                            "Scopes" : [ "full" ]
                                            },
                                            "message" : {
                                            "Name" : "message",
                                            "Scopes" : [ "full" ]
                                            },
                                            "messagerx" : {
                                            "Name" : "messagerx",
                                            "Scopes" : [ "full" ]
                                            },
                                            "subscriptions" : {
                                            "Name" : "subscriptions",
                                            "Scopes" : [ "full" ]
                                            }
                                        }
                                    },
                                    "trade" : {
                                        "Profiles" : {
                                            "Deployment" : [ "apiClient" ]
                                        },
                                        "ResourceScopes" : {
                                            "document" : {
                                            "Name" : "document",
                                            "Scopes" : [ "full" ]
                                            },
                                            "message" : {
                                            "Name" : "message",
                                            "Scopes" : [ "full" ]
                                            },
                                            "messagerx" : {
                                            "Name" : "messagerx",
                                            "Scopes" : [ "full" ]
                                            },
                                            "subscriptions" : {
                                            "Name" : "subscriptions",
                                            "Scopes" : [ "full" ]
                                            }
                                        }
                                    },
                                    "docspider" : {
                                        "Instances" : {
                                            "c1" : {},
                                            "c2" : {}
                                        },
                                        "Profiles" : {
                                            "Deployment" : [ "apiClient" ]
                                        },
                                        "ResourceScopes" : {
                                            "document" : {
                                            "Name" : "document",
                                            "Scopes" : [ "full" ]
                                            }
                                        }
                                    }
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
                "Processor" : {
                    "Modes" : {
                        "*" : {
                            "*" : {
                                "SettingNamespaces" : {
                                    "processor" : {
                                        "Name" : "intergov-processor",
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
                            },
                            "service" : {
                                "Engine" : "fargate",
                                "NetworkMode" : "awsvpc",
                                "Profiles" : {
                                    "Deployment" : [ "Processor" ]
                                }
                            }
                        }
                    }
                },
                "apiClient" : {
                    "Modes" : {
                    "*" : {
                        "userpoolclient" : {
                        "OAuth" : {
                            "Scopes" : [],
                            "Flows" : [ "client_credentials"]
                        },
                        "ClientGenerateSecret" : true,
                        "AuthProviders" : [ ]
                        }
                    }
                    }
                },
                "apiFullAccess" : {
                    "Modes" : {
                        "*" : {
                            "userpoolclient" : {
                                "ResourceScopes" : {
                                    "document" : {
                                    "Name" : "document",
                                    "Scopes" : [ "full" ]
                                    },
                                    "message" : {
                                    "Name" : "message",
                                    "Scopes" : [ "full" ]
                                    },
                                    "messagerx" : {
                                    "Name" : "messagerx",
                                    "Scopes" : [ "full" ]
                                    },
                                    "subscriptions" : {
                                    "Name" : "subscriptions",
                                    "Scopes" : [ "full" ]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    /]
[/#macro]
