data "aws_partition" "current" {}

resource "awscc_qbusiness_web_experience" "example" {
  application_id              = awscc_qbusiness_application.eks_amazonq_int.application_id
  role_arn                    = awscc_iam_role.webexample.arn
  sample_prompts_control_mode = "ENABLED"
  subtitle                    = "Drop a file and ask questions"
  title                       = "Sample Amazon Q Business App"
  welcome_message             = "Welcome, please enter your questions"

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "awscc_iam_role" "webexample" {
  role_name   = "Amazon-QBusiness-WebExperience-Role"
  description = "Grants permissions to AWS Services and Resources used or managed by Amazon Q Business"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "QBusinessTrustPolicy"
        Effect = "Allow"
        Principal = {
          Service = "application.qbusiness.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnEquals = {
            "aws:SourceArn" = awscc_qbusiness_application.eks_amazonq_int.application_arn
          }
        }
      }
    ]
  })

  policies = [{
    policy_name = "qbusiness_policy"
    policy_document = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "QBusinessConversationPermission"
          Effect = "Allow"
          Action = [
            "qbusiness:Chat",
            "qbusiness:ChatSync",
            "qbusiness:ListMessages",
            "qbusiness:ListConversations",
            "qbusiness:DeleteConversation",
            "qbusiness:PutFeedback",
            "qbusiness:GetWebExperience",
            "qbusiness:GetApplication",
            "qbusiness:ListPlugins",
            "qbusiness:GetChatControlsConfiguration",
            "qbusiness:ListRetrievers"
          ]
          Resource = awscc_qbusiness_application.eks_amazonq_int.application_arn
        },      
        {
            "Sid": "QBusinessRetrieverPermission",
            "Effect": "Allow",
            "Action": [
                "qbusiness:GetRetriever"
            ],
            "Resource": [
                "${awscc_qbusiness_application.eks_amazonq_int.application_arn}",
                "${awscc_qbusiness_application.eks_amazonq_int.application_arn}/retriever/*"
            ]
        },
        {
            Sid: "QBusinessKMSDecryptPermissions",
            Effect: "Allow",
            Action: [
                "kms:Decrypt"
            ],
            Resource: [
                "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/key_id"
            ],
            Condition: {
                "StringLike": {
                    "kms:ViaService": [
                        "qbusiness.us-east-1.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "QAppsResourceAgnosticPermissions",
            "Effect": "Allow",
            "Action": [
                "qapps:CreateQApp",
                "qapps:PredictQApp",
                "qapps:PredictProblemStatementFromConversation",
                "qapps:PredictQAppFromProblemStatement",
                "qapps:ListQApps",
                "qapps:ListLibraryItems",
                "qapps:CreateSubscriptionToken"
            ],
            "Resource": "${awscc_qbusiness_application.eks_amazonq_int.application_arn}"
        },
        {
            "Sid": "QAppsAppUniversalPermissions",
            "Effect": "Allow",
            "Action": [
                "qapps:DisassociateQAppFromUser"
            ],
            "Resource": "${awscc_qbusiness_application.eks_amazonq_int.application_arn}/qapp/*"
        },
        {
            "Sid": "QAppsAppOwnerPermissions",
            "Effect": "Allow",
            "Action": [
                "qapps:GetQApp",
                "qapps:CopyQApp",
                "qapps:UpdateQApp",
                "qapps:DeleteQApp",
                "qapps:ImportDocument",
                "qapps:ImportDocumentToQApp",
                "qapps:CreateLibraryItem",
                "qapps:UpdateLibraryItem",
                "qapps:StartQAppSession"
            ],
            "Resource": "${awscc_qbusiness_application.eks_amazonq_int.application_arn}/qapp/*",
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "qapps:UserIsAppOwner": "true"
                }
            }
        },
        {
            "Sid": "QAppsPublishedAppPermissions",
            "Effect": "Allow",
            "Action": [
                "qapps:GetQApp",
                "qapps:CopyQApp",
                "qapps:AssociateQAppWithUser",
                "qapps:GetLibraryItem",
                "qapps:CreateLibraryItemReview",
                "qapps:AssociateLibraryItemReview",
                "qapps:DisassociateLibraryItemReview",
                "qapps:StartQAppSession"
            ],
            "Resource": "${awscc_qbusiness_application.eks_amazonq_int.application_arn}/qapp/*",
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "qapps:AppIsPublished": "true"
                }
            }
        },
        {
            "Sid": "QAppsAppSessionModeratorPermissions",
            "Effect": "Allow",
            "Action": [
                "qapps:ImportDocument",
                "qapps:ImportDocumentToQAppSession",
                "qapps:GetQAppSession",
                "qapps:GetQAppSessionMetadata",
                "qapps:UpdateQAppSession",
                "qapps:UpdateQAppSessionMetadata",
                "qapps:StopQAppSession"
            ],
            "Resource": "${awscc_qbusiness_application.eks_amazonq_int.application_arn}/qapp/*/session/*",
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "qapps:UserIsSessionModerator": "true"
                }
            }
        },
        {
            "Sid": "QAppsSharedAppSessionPermissions",
            "Effect": "Allow",
            "Action": [
                "qapps:ImportDocument",
                "qapps:ImportDocumentToQAppSession",
                "qapps:GetQAppSession",
                "qapps:GetQAppSessionMetadata",
                "qapps:UpdateQAppSession"
            ],
            "Resource": "${awscc_qbusiness_application.eks_amazonq_int.application_arn}/qapp/*/session/*",
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "qapps:SessionIsShared": "true"
                }
            }
        }
       ]
    })
  }]
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

