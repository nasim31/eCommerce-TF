#CodePipeline
resource "aws_codepipeline" "eCommerce--codepipeline" {
  name = "eCommerce-codepipeline"
  role_arn = "${aws_iam_role.tf_codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.eCommerce-codepipeline-bucket.bucket}"
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = "eCommerce-codecommit-repo"
        BranchName     = "prod"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source"]
      output_artifacts = ["build"]
      version = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.eCommerce-codebuild.name}"
      }
    }
  }


  # stage {
  #   name = "Approval"

  #   action {
  #     category         = "Approval"
  #     owner = "AWS"
  #     # configuration    = {
  #     #   ApplicationName = ""
  #     #   EnvironmentName = ""
  #     # }
  #     # input_artifacts  = [
  #     #   "build",
  #     # ]
  #     version = "1"
  #     name             = "1st_Approval"
  #     provider         = "Manual"
  #   }
  # }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ElasticBeanstalk"
      input_artifacts = ["build"]
      version = "1"

      configuration = {
        ApplicationName = "eCommerce-eb-app"
        EnvironmentName = "eCommerce-eb-env"
      }
    }
  }
}


