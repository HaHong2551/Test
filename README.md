# Infra Terraform IAC guideline

## Summary: 
- [1. Flow](#1-flow)
- [2. Structure](#2-structure)
- [3. Presiquired](#3-presiquired)
    - [3.1. Use OIDC for connect from Github Action to AWS](#31-use-oidc-for-connect-from-github-action-to-aws)
    - [3.2. Use Slack notification](#32-use-slack-notification)
    - [3.3. Request running github action in IFU portal for project repository](#33-request-running-github-action-in-ifu-portal-for-project-repository)
    - [3.4. Checking and summary Environments and variables in github repository](#34-checking-and-summary-environments-and-variables-in-github-repository)
- [4. How to uses](#4-how-to-uses)

## 1. Flow
![Workflow](assets/workflow.png)

## 2. Structure
<pre>
├── .github
│   └── workflows
│       ├── apply.yml
│       ├── init-environemnt.sh
│       ├── plan.yml
│       ├── trigger-apply.yml
│       └── trigger-plan.yml
├── .gitignore
├── .terraform-version
├── README.md
├── assets
│   ├── secrets_role.png
│   ├── secrets_slack.png
│   ├── secrets_slack_2.png
│   ├── variables.png
│   └── workflow.png
└── terraform
    ├── Makefile
    └── envs
        └── dev
            ├── 1.general
            │   ├── _backend.tf
            │   └── sg.tf
            ├── 2.api
            │   ├── _backend.tf
            │   └── sg.tf
            ├── _variables.tf
            └── terraform.dev.tfvars

8 directories, 20 files
</pre>

Explain:
1. **.github/workflow**: include workflow file 
    - **init-environment.sh**: file script install library
    - **trigger-plan.yml**: workflow when create pull request to master branch:
        - filter environment with folder change:
            + terraform/envs/dev/** -> dev environment
            + terraform/envs/stg/** -> stg environment
            + terraform/envs/prd/** -> prod environment
        - trigger workflow plan in file plan.yml
    - **plan.yml**: workflow for terraform plan include these steps:
        - checkout
        - init environment
        - install tfenv
        - authen aws with role OIDC
        - symlink all variables target
        - terraform init 
        - terraform check format
        - terraform check validate
        - terraform plan
        - output terraform plan
        - notify slack
    - **trigger-apply.yml**: workflow when merged pull request:
        - filter environment with folder change:
            + terraform/envs/dev/** -> dev environment
            + terraform/envs/stg/** -> stg environment
            + terraform/envs/prd/** -> prod environment
        - trigger workflow apply in file apply.yml
    - **apply.yml**: workflow for terraform apply include these steps:
        - checkout
        - init environment
        - install tfenv
        - authen aws with role OIDC
        - symlink all variables target
        - terraform init
        - terraform apply
        - notify slack

2. **terraform** folder: include code for terraform with the same structure in terraform infra iac 
3. **.terraform-version** file: version terraform want to installed (1.3.9)
4. **assets** folder: include image for README.md

## 3. Presiquired

### 3.1. Use OIDC for connect from Github Action to AWS
Link refer: https://aws.amazon.com/blogs/security/se-iam-roles-to-connect-github-actions-to-actions-in-aws/

#### 3.1.1. Create an OIDC provider

    1. Open the IAM console.
    2. In the left navigation menu, choose Identity providers.
    3. In the Identity providers pane, choose Add provider.
    4. For Provider type, choose OpenID Connect.
    5. For Provider URL, enter the URL of the GitHub OIDC IdP for this solution: https://token.actions.githubusercontent.com
    6. Choose Get thumbprint to verify the server certificate of your IdP. To learn more about OIDC thumbprints, see Obtaining the thumbprint for an OpenID Connect Identity Provider.
    7. For Audience, enter **sts.amazonaws.com**. This will allow the AWS Security Token Service (AWS STS) API to be called by this IdP.

![Workflow](https://d2908q01vomqb2.cloudfront.net/22d200f8670dbdb3e253a90eee5098477c95c23d/2023/04/12/img1-2-1024x580.png) 

#### 3.1.2. Create IAM Role
- Create IAM role: **github_action_cicd_role** with **AdministratorAccess** (Change the permission accordingly -> but recommend is Administrator)

- Change Trust relationship
    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::<account_id>:oidc-provider/token.actions.githubusercontent.com"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    },
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": "repo:<organization>/<repository>:*"
                    }
                }
            }
        ]
    }
    ```
    replace **<account_id>** and **repo:organization/repository** with yours

Note: Copy your IAM role ARN when you created IAM role.

#### 3.1.3. Create environment for github action 
- Create Repository variables: 
    - **AWS_REGION**: region in AWS
![Variable Github action](assets/variables.png)

- Create Environment secrets: 
    - **ASSUME_ROLE_ARN**: the role for OIDC above that you created
![Secret Github action](assets/secrets_role.png)

- Create Repository secrets: 
    - **DEPLOY_KEY**: for step init terraform. This key need to add to repository: https://github.com/framgia/sun-infra-iac-release for pull all Infra Sun's release terraform module. This value here is base64 value. So when you create new ssh key pair, get it by this below command and copy its value. 
        ```
        $ base64 private_ssh_key > base_64.txt
        ```
        Send **public_ssh_key** to develop team for adding to repo https://github.com/framgia/sun-infra-iac-release

### 3.2. Use Slack notification
Note: Can use with Slack token or Slack webhook. Please select the option that matches yours choices

#### 3.2.1. Use Slack notification with Slack token

#### 3.2.1.1. Create Slack app and token
1. Go to https://api.slack.com/apps and click on the **Create New App** button to create a new slack application.
2. Select the Token Scopes:
    - **chat:write**
    - **files:write**
    - **incoming-webhook**
3. Install the Application in the Workspace
4. Request via IFU portal to approve for install it
5. Copy OAuth Access Token
![Access Token](https://raw.githubusercontent.com/kasunkv/slack-notification/master/screenshots/slack-tokens/7-copy-and-use-token.png)

#### 3.2.1.2. Prepare for environments in github

Create Environment secrets:
- **SLACK_BOT_TOKEN**: in step 3.2.1.1. Example: xoxb-2581xxxx-xxxxxx
- **SLACK_CHANNEL_ID**: slack ID channel for notification. Example: C03SAXXXXXX
- **SLACK_USER**: mention user in slack. Example: <@U02APXXXXXX>, <@U02AFXXXXXX>
![Secret Github action](assets/secrets_slack.png)

#### 3.2.2. Use Slack notification with Slack webhook

#### 3.2.2.1. Create Slack app and webhook
1. Create a Slack app (the same step 3.2.1.1 above)
2. Enable incoming webhooks
    - Check app in https://api.slack.com/apps
    - Select **Incoming Webhooks**, and toggle **Activate Incoming Webhooks** to on
3. Create an incoming webhook
    - Click on **Add New Webhook to Workspace**
    - Select channel to post notification
4. Copy the Webhook URL

#### 3.2.2.2. Prepare for environments in github
Create Environment secrets: 
- **SLACK_WEBHOOK_URL**: in step 3.2.2.1. Example: https://hooks.slack.com/services/xxxxxxx
- **SLACK_USER**: mention user in slack. Example: <@U02APXXXXXX>, <@U02AFXXXXXX>
![Secret Github action](assets/secrets_slack_2.png)

#### 3.2.3. Change interactivity for slack app
- Go to https://api.slack.com/apps/ and Click to app that you created above.
- Click **Interactivity & Shortcuts** -> Toggle **Interactivity** On
- Set the **Request URL** to https://httpstat.us/200
- Save config
![Secret Github action](assets/slack_app_interactivity.png)

Note: This step used for fix Slack message with button, a warning "This app has not been configured this feature"

### 3.3. Request running github action in IFU portal for project repository

1. Go to https://ifu-portal.sun-asterisk.com/ and request github action

2. Because our workflow used public action, so need request these: 
    - dorny/paths-filter@v3: for filter environment
    - actions/checkout@v4: for checkout/clone source code
    - aws-actions/configure-aws-credentials@v4: for authen AWS with OIDC 
    - actions/github-script@v7: for writing output terraform plan in comment PR
    - slackapi/slack-github-action@v1.25.0: for slack notification

3. Get approve and we can go next step to know how to use github action workflow.

### 3.4. Checking and summary Environments and variables in github repository
- Repository secrets:
    - **DEPLOY_KEY** (must have)
- Environment secrets: for each environment like dev, stg, prod ...
    - **ASSUME_ROLE_ARN** (must have)
    - **SLACK_USER** (must have)
    - SLACK_BOT_TOKEN (if choose token slack)
    - SLACK_CHANNEL_ID (if choose token slack)
    - SLACK_WEBHOOK_URL (if choose webhook slack)
- Repository variables:
    - **AWS_REGION** (must have)

## 4. How to uses

### 4.1. Clone this repository
    $ git clone git@github.com:framgia/infra-iac-workflow.git
### 4.2. Copy the necessary files to your project repository
    $ cp -r infra-iac-workflow/.github my-project-iac-folder
    $ tree -a my-project-iac-folder
    my-project-iac-folder
    └── .github
        └── workflows
            ├── apply.yml
            ├── init-environemnt.sh
            ├── plan.yml
            ├── trigger-apply.yml
            └── trigger-plan.yml

    2 directories, 5 files

### 4.3. Change source module to repo https://github.com/framgia/sun-infra-iac-release
Note: 
- https://github.com/framgia/sun-infra-iac have module, source code and releases from infra member during the development phase 
- https://github.com/framgia/sun-infra-iac-release have only releases module

So need change all source module from repo **sun-infra-iac** to repo **sun-infra-iac-release**

Example: file **terraform/envs/dev/1.general/sg.tf** -> change source:
```
module "sg_general" {
  source = "git@github.com:framgia/sun-infra-iac-release.git//modules/security-group?ref=terraform-aws-security-group_v0.0.1"
  #basic
  ...
}  
```

### 4.4. Now push code to project repository
    $ git checkout -b infra_workflow
    $ git add .
    $ git commit -m "add workflow github action file"
    $ git push origin infra_workflow

### 4.5. Create PR from branch **infra_workflow** to **master** and wait result. 

### 4.6. Good Luck !!!!

If you have any problems or issues, pls contact with develop team:
- Mr Cuong: @cuongtv-0172
- Mr Trung: @trungtt-1545
- Mr Thien: @thienpnx-3219
- Mr Quyet: @quyettv-1583

♥♥♥ From IFU with love ♥♥♥