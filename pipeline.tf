/*resource "aws_codecommit_repository" "codecommitrepo" {
  repository_name = "aws-eks-springboot"
  description     = "This is the Sample App Repository"
  default_branch  = "master"
}


resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
           "Effect": "Allow",
            "Action": [
                "eks:Describe*",
                "sts:AssumeRole",
                "ssm:GetParameter"
            ],
            "Resource": [
                "*"
            ] 
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild-ecr-fullaccess" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    role       = aws_iam_role.codebuild_role.name
}


resource "aws_codebuild_project" "cdoebuildproject" {
  name          = "codebuildproject"
  description   = "codebuildproject"
  #build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.accountid
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
      type  = "PLAINTEXT"
    }
    
    environment_variable {
      name  = "ECR_REPO_URI"
      value = var.ecrrepouri
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.clustername
      type  = "PLAINTEXT"
    }
    
    environment_variable {
      name  = "masterrolearn"
      value = aws_iam_role.root_account_role.arn
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/codebuildprojectterraform"
    }
  }
  artifacts {
    type            = "CODEPIPELINE"
  }
  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yaml"
  }

  source_version = "master"
  tags = {
    Name = "aws-codebuild-terraform"
  }
}





resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}


resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "aws-terraform-s3-bucket-19-12-2022"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "aws-codepipeline-terraform"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.codecommitrepo.repository_name
        BranchName           = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.cdoebuildproject.name
      }
    }
  }

  
}


resource "aws_iam_role" "cloudwatcheventrole" {
  name = "cloudwatcheventrole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatcheventpolicy" {
  name = "codepipeline_policy"
  role = aws_iam_role.cloudwatcheventrole.id

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "codepipeline:StartPipelineExecution"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}


resource "aws_cloudwatch_event_rule" "codecommitcodepipeline" {
  name        = "codecommitcodepipeline"
  description = "codecommitcodepipeline event"

  event_pattern = <<EOF
{
              "detail-type":["CodeCommit Repository State Change"],
              "source": ["aws.codecommit"],
              "region": ["${var.region}"],
              "resources": [
                "arn:aws:codecommit:${var.region}:${var.accountid}:${aws_codecommit_repository.codecommitrepo.repository_name}"
              ],
              "detail": {
                "event":[
                    "referenceCreated",
                    "referenceUpdated"
                ],
                "referenceType":["branch"],
                "referenceName":["master"]
              }
              

}
EOF
}

resource "aws_cloudwatch_event_target" "codepipelinetarget" {
  target_id = "codepipeline"
  rule      = aws_cloudwatch_event_rule.codecommitcodepipeline.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.cloudwatcheventrole.arn
}

*/




