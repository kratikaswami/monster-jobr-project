import json, sys
import subprocess, webbrowser


def do_cmd_statusoutput(cmd):
    print(cmd)
    (status, output) = subprocess.getstatusoutput(cmd)
    return status, output


print("\n\n\n\n")
print("****************************************************")
print("*************  RUNNING TERRAFORM INIT  *************")
print("****************************************************")
status, output = do_cmd_statusoutput('terraform init')
print("Status of terraform init: " + str(status))
if status != 0:
    sys.exit(1)


# terraform plan to see the changes which shall be done infrastructure -- can add
# flag to skip output and the plan itself
print("\n\n\n\n")
print("****************************************************")
print("*************  RUNNING TERRAFORM PLAN  *************")
print("****************************************************")
status, output = do_cmd_statusoutput('terraform plan')
print("Status of terraform plan: " + str(status))
print("Output for terraform plan: \n" + output)
if status != 0:
    sys.exit(1)


# terraform apply to set up the AWS environment on which we run our app
print("\n\n\n\n")
print("****************************************************")
print("************  RUNNING TERRAFORM APPLY  *************")
print("****************************************************")
status, output = do_cmd_statusoutput('terraform apply -auto-approve')
print("Status of terraform apply: " + str(status))
print("Output for terraform apply: \n" + output)
if status != 0:
    sys.exit(1)


# retrieve the DB endpoint, username, password and db name from the outputs field in json
# we will use config.json to run the container with our leaderboard application in it.
with open("./terraform.tfstate", "r") as input_file:
    d = json.load(input_file)

v = d['modules'][0]['outputs']
mysql_endpoint = v['mysql_endpoint']['value'].split(":3306")[0]
mysql_username = v['mysql_username']['value']
mysql_password = v['mysql_password']['value']
webserver_ip_address = v['webserver_ip_address']['value']
jumphost_ip_address = v['jumphost_ip_address']['value']
mysql_dbname = v['mysql_db']['value']

mysql_install_cmd = "sudo yum -y install mysql"

mysql_cmd = "mysql -h" + mysql_endpoint + " -u" + mysql_username + " -p" + mysql_password + " " + mysql_dbname + "< ~/queries.sql > ~/mysql.txt "

table_queries = "\"create table if not exists team (id varchar(20), name varchar(20), date_created date, date_updated date); \
create table if not exists user (id varchar(20), name varchar(20),team_id varchar(20), date_created date, date_updated date); \
create table if not exists points (id varchar(20), user_id varchar(20), points int, reason varchar (50),date_created date); \
insert into team (id, name, date_created, date_updated) values (\"\\\"1\"\\\", \"\\\"team red\"\\\", \"\\\"2018-10-06\"\\\", \"\\\"2018-10-07\"\\\"), (\"\\\"2\"\\\", \"\\\"team blue\"\\\", \"\\\"2018-10-08\"\\\", \"\\\"2018-10-09\"\\\"); \
insert into user(id, name, team_id, date_created, date_updated) values (\"\\\"100\"\\\", \"\\\"John\"\\\" , \"\\\"1\"\\\" , \"\\\"2018-10-06\"\\\", \"\\\"2018-10-07\"\\\"),(\"\\\"200\"\\\", \"\\\"Harry\"\\\" ,\"\\\"1\"\\\", \"\\\"2018-10-16\"\\\", \"\\\"2018-10-17\"\\\"),(\"\\\"300\"\\\",\"\\\"Andy\"\\\",\"\\\"2\"\\\", \"\\\"2018-10-9\"\\\", \"\\\"2018-10-17\"\\\"),(\"\\\"400\"\\\",\"\\\"Joseph\"\\\",\"\\\"2\"\\\", \"\\\"2018-10-26\"\\\", \"\\\"2018-10-27\"\\\"); \
insert into points(id, user_id, points, reason, date_created) values (\"\\\"1000\"\\\", \"\\\"100\"\\\", 5, \"\\\"goal\"\\\", \"\\\"2018-10-12\"\\\"), (\"\\\"1001\"\\\", \"\\\"200\"\\\", 15, \"\\\"goal and fouls\"\\\", \"\\\"2018-10-22\"\\\"), (\"\\\"1002\"\\\", \"\\\"300\"\\\", 0,  \"\\\"bad player\"\\\", \"\\\"2018-10-11\"\\\"), (\"\\\"1003\"\\\", \"\\\"400\"\\\", 10, \"\\\"goals\"\\\", \"\\\"2018-10-19\"\\\"); \""


print("\n\n\n\n\n")
print("****************************************************")
print("*****  INSTALLING AND RUNNING MYSQL QUERIES  *******")
print("****************************************************")
cmd_queries_file = "echo " + table_queries + " > " + " queries.sql"
mysql_cmds = mysql_install_cmd + "; " + mysql_cmd



# runs cmd on remote machine with ip address ip
def do_cmd_infra(ip, cmd):
    return do_subprocess_list(
        ['ssh', '-oStrictHostKeyChecking=no', '-i', '~/.ssh/id_rsa.pub', 'ec2-user@%s' % ip, '-t', '%s' % cmd])


# scp directory to remote host with ip
def scp_directory(ip, source, destination):
    return do_subprocess_list(
        ['scp', '-r', '-oStrictHostKeyChecking=no', '-i', '~/.ssh/id_rsa.pub', source, 'ec2-user@%s:%s' % (ip, destination)])


# scp file to remote host
def scp_file(ip, source, destination):
    return do_subprocess_list(
        ['scp', '-oStrictHostKeyChecking=no', '-i', '~/.ssh/id_rsa.pub', source, 'ec2-user@%s:%s' % (ip, destination)])


# utility command to run the command
def do_subprocess_list(cmdlist):
    output = ""
    try:
        output = subprocess.check_call(cmdlist)  # displays the live output on terminal
        return True, output
    except subprocess.CalledProcessError as e:
        print(e)
    return False, output


# func to populate the config.json with dbname, username, password and db endpoint in config.json
def write_to_config(v):
    file = "./leaderboard-dashboard-app/config.json"
    with open(file, "r") as jsonFile:
        data = json.load(jsonFile)

    data["host"]     = v['mysql_endpoint']['value'].split(":3306")[0]
    data["user"]     = v['mysql_username']['value']
    data["password"] = v['mysql_password']['value']
    data["database"] = v['mysql_db']['value']

    with open(file, "w") as jsonFile:
        json.dump(data, jsonFile)

# install mysql, set up tables and populate data
do_cmd_infra(jumphost_ip_address, cmd_queries_file)
do_cmd_infra(jumphost_ip_address, mysql_cmds)

# write db configs to config.json
write_to_config(v)

# scp the application to webserver host where the docker image will be built.
# a better way to do this would be to create the docker image here and push it to AWS ECR and pull from the webserver.
# That would be a better way to this but for now,
scp_directory(webserver_ip_address, './leaderboard-dashboard-app', '~')
do_cmd_infra(webserver_ip_address, 'sudo yum -y install docker; sudo groupadd docker; '
                                   'sudo usermod -aG docker $USER; sudo systemctl start docker.service')
do_cmd_infra(webserver_ip_address, 'cd ~/leaderboard-dashboard-app ; sudo docker build --no-cache -t node-app .; sudo docker run -d -p 8080:8080 node-app')
webbrowser.open("http://%s:8080" %(webserver_ip_address))

# configuring the application to be restarted automatically on reboot of webserver host.
scp_file(webserver_ip_address, "./leaderboard.service", "~")
do_cmd_infra(webserver_ip_address, "sudo mv ~/leaderboard.service /etc/systemd/system/leaderboard.service;"
                                   " sudo systemctl daemon-reload")
do_cmd_infra(webserver_ip_address, "sudo systemctl enable docker; sudo systemctl enable leaderboard")
do_cmd_infra(webserver_ip_address, "sudo systemctl start leaderboard")


print("\n\n\n\n")
print("*************************************************************")
print("*The application is available at: http://" + webserver_ip_address + ":8080*")
print("*************************************************************")
print("\n\n")
