## Monster-Jobr - Software Engineer coding challenge.
I implemented this project as a POC and it was an amazing learning experience. I would like to thank you for this opportunity.  

### Installation requirements
* Terraform 0.11+ (https://www.terraform.io/intro/getting-started/install.html)
* python 3.6+ (https://www.python.org/downloads/release/python-360/)
* ssh and scp tools should be installed and running.
* aws-cli (https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

### Other configuration requirements
* This program is compatible with Unix and Mac like file systems and might not work for Windows.
* You should run it from an account which has aws credentials in *`~/.aws/credentials`*. It should have secret key and access key.
* You should have a public key at location *`~/.ssh/id_rsa.pub`*. This will be used as ec2 key pair for all aws ec2 instances. Instructions to create a public key can be found at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html under 'Importing Your Own Public Key to Amazon EC2'. 
* Change the permissions for pem key file *`$chmod 400 ~/.ssh/id_rsa.pub`*
* Run command *$ eval `ssh-agent -s`*
* Run command *$`ssh-add ~/.ssh/id_rsa`*

### Running the project (Post-prerequisites)
* Navigate to the root directory of the project.
* Run *`$terraform init`*
* *`$python automation.py`*   (in the root directory of the project)

### Info
* By default, the code sets up everything in eu-west-1 (Ireland) region. In order to change that, changes are required in two places: provider in main.tf and availability zones in network.tf (you would have to change the availability zone according to availability zones in the region.).
* I have implemented the project such that you would not have to change the ami ids anywhere. 
* The program is automated such that it does the following:
	* Sets up the network requirements on AWS. 
	* Initiates ec2 instance for jumstation and webserver host.
	* Creates rds with mysql and creates tables and feeds data to it. 
	* Installs Docker and starts docker daemon on the webserver host. 
	* Builds docker image for the Node.js web app and runs the image. 
	* Opens a web browser and connects to the application.
	* The application is setup to run by itself on reboot.

### Future work based on learnings
* I would want to use Ansible to make this code more robust and to be OS and environment agnostic.
* In the beginning, I was hardening the webserver AMI with Node.js installed using Packer but I realized that running the application as a docker container was much more efficient and simple. Therefore, I went that way. 
* I would want to make the code aws region agnostic using maps for availability zones so that it could be run on any environments.
* I could have use ECR registry to push Docker images and pulling it on webserver host but this seemed easier because I would have had to install aws client and setup credentials on webserver.
