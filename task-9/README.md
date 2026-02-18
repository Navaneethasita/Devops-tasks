**step-1: First create the project folder
mkdir terraform--scale-project
cd terraform-scale-project

**step-2: Create Provider.tf
provider "aws" {
  region = "us-east-1"
}

*Make sure AWS CLI is configured
aws configure

*by using security credentials of aws , we create the access key and secret access key

**step-3: Create Initial Single Instance(without count)
Create main.tf

resource "aws_instance" "app" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"

  tags = {
    Name = "single-instance"
  }
}

**step-4: Initialize the Terraform

terraform init

**step-5: Create the instance 

terraform apply

*to see the instances type command

terraform state list

one EC2 is running...

*Now requirement says:

Scale to 5 instances using count
Do NOT destroy existing instance

*Important Rule

If you just modify code and run apply — Terraform will DESTROY and recreate.

So we must migrate state safely.

**step-6: Update main.tf

resource "aws_instance" "app" {
  count         = 5
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "scaled-instance-${count.index}"
  }
}

*Do NOT run terraform apply now

**step-7: State Migration

*current state has 
aws_instance.app

*We need it to become
aws_instance.app[0]

**step-8: Backup state(mandatory)

terraform state pull > backup.tfstate

**step-9: Move state to index[0]

terraform state mv aws_instance.app aws_instance.app[0]

This tells Terraform:
The existing instance is index 0
No infrastructure changes happen here.

**step-10: verify the state

terraform state list
it shows
aws_instance.app[0]

**step-11: Now run the command

terraform apply

*it shows
 aws_instance.app[1]
 aws_instance.app[2]
 aws_instance.app[3]
 aws_instance.app[4]

Terraform will:

Keep existing instance as [0]

Create 4 new instances

🎉 You now have 5 instances total.
