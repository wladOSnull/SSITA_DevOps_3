# Milestone 3

## Nexus Sonatype 

### Presettings

Create new GCP compute instance with static public IP, with Rocky Linux, >=2*CPU and >=2GB of ROM. Also, provide Firewall with inbound SSH (22) and Nexus (8081) rules for IP of your machine. 

Create for *nexus* instance separate disk (SSD, 10GB, schedule backup...) and attach it to instance. Further configuration and mounting this disk to the Linux system -> [phoenixnap](https://phoenixnap.com/kb/linux-create-partition)

Add disk to automount -> [linuxbabe](https://www.linuxbabe.com/desktop-linux/how-to-automount-file-systems-on-linux)

### Installation

Simple guide to install Nexus on Linux -> [devopscube](https://devopscube.com/how-to-install-latest-sonatype-nexus-3-on-linux/)

  - in my case was created */media/nexus-disk* and mounted additional GCP disk to this folder
  - then in this folder was created *nexus3* as store-folder for *Nexus* (*-Dkaraf.data* variable in *???/nexus/bin/nexus.vmoptions*)

Install Nginx for Nexus as revers proxy -> [kifarunix](https://kifarunix.com/run-nexus-repository-behind-nginx-reverse-proxy/)

### Configuring

For Geo Citizen there are already default *maven-shapshot* and *maven-release* repositories. Turn off the other repos (optionally). 

Create 2 *Role*s with full *view* access to *maven-releases* and *maven-snapshots*. Create 2 *User*s wiht and grand this *Role*s.

## Jenkins + Maven

### Maven

Setup JDK and Maven on Jenkins -> [toolsqa](https://www.toolsqa.com/jenkins/jenkins-maven/#:~:text=Jenkins-,Maven,management%20and%20creating%20automated%20builds.)

For this you need to install Java and Maven plugins for Jenkins. Then install JDK and configure path to it in *Gloval Tools Configuration* of Jenkins.

**IMPORTANT**: 
  - something like *java-11-openjdk.x86_64* - only JRE ! (we need it for Jenkins work)
  - something like *java-11-openjdk-devel.x86_64* - only JDK ! (we need it for Maven work)
  - example of path for Jenkins to JDK - */usr/lib/jvm/java-11-openjdk-11.0.14.0.9-2.el8_5.x86_64/* (this one contain *bin* folder with *java, javac, javadoc ...*)

### Maven + Nexus (deploy by pom.xml)

To deploy artefacts (*.war* files in case of Geo Citizen) automatically by *Maven* (*Jenkins* actually is not need for this) in *pom.xml* must be entrypoint for deploying repository:

  ```xml
  # xml block for deploying artefact on to storage
  <distributionManagement>
      # description of repo for releases
      <repository>
        # id of credentials in settings.xml
        <id>maven-releases</id>
        # just name
        <name>Releases</name>
        # URL of remote/local releases repository
        <url>http://35.223.40.57:8081/repository/maven-releases/</url>
      </repository>
      # description of repo for snapshots
      <snapshotRepository>
        # id of credentials in settings.xml
        <id>maven-snapshots</id>
        # just name
        <name>Snapshot</name>
        # URL of remote/local snapshots repository
        <url>http://35.223.40.57:8081/repository/maven-snapshots</url>
      </snapshotRepository>
  </distributionManagement>
  ```

**TIP**: *Maven* needs credentials to *Nexus* storage for *release* and *snapshot* reposotories (creds of user were created in previous chapter). This credentials must be written in *settings.xml* file in *.m2* folder (global, local ...).

Guide to store Nexus credentials safetly -> [maven.apache](https://maven.apache.org/guides/mini/guide-encryption.html)

  - **TIP**: for correct work of encryption tool of *Maven* the file *settings-security.xml* must to be in *user-home/.m2/* folder **BUT** for correct usage encrypted credentials by *Jenkins* the file *settings-security.xml* must to be in */var/lib/jenkins/.m2/* folder also !!!

  - **USEFUL**: third-party decryptor for *Maven* credentials -> [github](https://github.com/jelmerk/maven-settings-decoder)

More explains -> [stackoverflow](https://stackoverflow.com/questions/51503336/generate-settings-security-xml-file-for-maven-password-encryption)

Also in *pom.xml* must be header with neccesary inforamtion about app:

  ```xml
  <modelVersion>4.0.0</modelVersion>
	
  <groupId>com.softserveinc</groupId>
	<artifactId>geo-citizen</artifactId>
  <version>1.0.5-SNAPSHOT</version>
  
  <packaging>war</packaging>
  ```

**TIP**: if there is *SNAPSHOT*-word in `<version>` - artefact will be deployed to *snapshot* type of repository on Nexus storage, OTHERWISE (if *SNAPSHOT* is missed) - to *release* type of repo.

Short description of impoprtant tags of *pom.xml* -> [examclouds](https://www.examclouds.com/java/java-core-russian/pom-xml)

### Maven + Nexus (separately with plugins)

Guide for building a project by *Maven* and deploy to *Nexus* with using special plugins *Nexus Artifact Uploader* (for Nexus uploading) and *Pipeline Utility Steps* (for reading *pom.xml* file and dynamic pulling info for artefact):
  - video 1 -> [youtube](https://www.youtube.com/watch?v=p_Wo3aqUJto)
  - video 2 -> [youtube](https://www.youtube.com/watch?v=iegXZUGVkL8)
  - video 3 -> [youtube](https://www.youtube.com/watch?v=Unsa7Ax6kQA)

## GCP load balancing

### Manual

Simple guide for manual creating load balancer -> [youtube](https://www.youtube.com/watch?v=304n_19cdoc)

### Terraform

Manual for creating template of instance -> [registry.terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template)
Manual for usage/log *autostart-script* -> [cloud.google](https://cloud.google.com/compute/docs/instances/startup-scripts/linux#rerunning)

### Bound autoscaler & Jenkins job

Webhook plugin with ability to pass parameters -> [plugins.jenkins](https://plugins.jenkins.io/generic-webhook-trigger/)

Install this plugin on Jenkins, setup *Post content parameters* in job - *Variable* and *Expression*. 

Manual of usage JSONPath and JSONPath Expressions -> [github](https://github.com/json-path/JsonPath).
Also there is validator for JSONPath Expressions in *Appendix*.

Also use *Token* or *Token Credential* for safe triggering Jenkins by this webhooks plugin.

Example of triggering Jenkins by *Generic Webhook Trigger*:

  ```bash
  ~ curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"host": "0.0.0.0", "label": "test"}' \
    http://ip.of.your.Jenkins:8080/generic-webhook-trigger/invoke?token=tester
  ```

**TIP**: If you want to use parameters from *-d '{...}'* block you have to setup *This project is parameterised -> String parameter -> Name* same as in *Post content parameters -> Variable* ! 

## Containerization

### Manually

Basic guide about containerisation -> [linuxhint](https://linuxhint.com/create_docker_image_from_scratch/)

Firstly get base docker image *tomcat*.

**TIP**: tomcat image must be 9 version !!! (due to dropped support of Java servlet in Tomcat 10)

Then create *Dockerfile*:

  ```dockerfile
  # citizen.war - geo-app
  FROM tomcat:9
  MAINTAINER wlad1324
  COPY ./citizen.war /usr/local/tomcat/webapps/
  ```

Now you can execute next Docker commands:

  ```bash
  # build docker image from Dockerfile
  ~ docker image build -t wlad1324/geocitizen:1 ./

  # run container
  ~ docker run -it -p 80:8080 test/tomcat9
  # OR for auto-start
  ~  docker run --restart unless-stopped -p 8080:8080 wlad1324/geocitizen:1
  ```

### Jenkins pipeline

Integration Docker into Jenkins -> [coachdevops](https://www.coachdevops.com/2020/05/docker-jenkins-integration-building.html)

Jenkins - Docker - Nexus -> [coachdevops](https://www.coachdevops.com/2021/02/automate-docker-builds-using-jenkins.html)

Command fot parsing the latest *citizen* (Docker image) tag:

  ```bash
  ~ curl --user "user:pass" -sX GET http://ip:port/v2/citizen/tags/list | jq '.tags[-1]' | awk -F[\"\"] '{print $2}'
  ```

## Prometheus

Main guide to install *Prometheus* on premise -> [fosslinux](https://www.fosslinux.com/10398/how-to-install-and-configure-prometheus-on-centos-7.htm)

**TIP**: disabling of *SELinux* is necessarily !!! Otherwise *prometheus.service* won't start. Also, disabling *SELinux* is a very bad approach to managing Linux OS, so maybe you need to use Docker image version of *Prometheus* ...

Dashboard for Prometheus node_exporter -> [grafana](https://grafana.com/grafana/dashboards/1860)

Dynamic 'hosts' file (prometheus.yml):

- example of correct file -> [github](https://github.com/prometheus/prometheus/blob/release-2.34/config/testdata/conf.good.yml)
- manual with types of dynamic configs -> [prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#file_sd_config)

## Grafana

Main guide to installing *Grafana* (Enterprise edition) -> [grafana](https://grafana.com/docs/grafana/latest/installation/rpm/)

## Grafana + Prometheus

Guide for establishing connection *Grafana* with *Prometheus* -> [linuxhint](https://linuxhint.com/connect-grafana-with-prometheus/)

## SensuGO

Main guide for installation -> [computingforgeeks](https://computingforgeeks.com/install-sensu-monitoring-tool-on-centos-linux/)  

Installation of *SensuGO* was made on instance with *Jenkins, Prometheus, Grafana ...*, so default config file 'backend.yaml' of *SensuGo* must be changed due to ports conflicts:

  ```md
  # change all configs to these ports

  - api-listen-address: "[::]:8090" 
  - api-url: "http://localhost:8090"
  - agent-port: 8091
  - dashboard-port: 3010
  ```

Visit *SensuGo* on http://ip:dashboard-port, input login/pass from *sensu-backend init* command. Also you can check *SensuGO* healthby:

  ```bash
  # default port is 8080 but in our case 8090
  ~ curl http://127.0.0.1:8090/health
  ```

Install *sensu-go-cli*:

  ```bash
  # installation
  ~ sudo yum install sensu-go-cli

  # configure/init
  ~ sensuctl configure
  ```

Install *sensu-go-agent*  :

  ```bash
  # installation
  ~ sudo yum install sensu-go-agent

  # get deafault config  file (like for sensu-go-backend)
  ~ sudo curl -L https://docs.sensu.io/sensu-go/latest/files/agent.yml -o /etc/sensu/agent.yml
  ```

Due to changes in 'backend.yml' for sensu backend we have to change 'agent.yml' also:

  ```md
  # uncomment this !
  - backend-url:
  # change this as 'agent-port' in backend.yml
  - "ws://127.0.0.1:8091"
  ```

Start sertvice unit of *sensu-agent* as well:

  ```bash
  ~ sudo systemctl enable --now sensu-agent
  ```

Check status of *sensu-agent* service. 

**TIP**: if *sensu-agent* service failed to start:

  - check ports in configs files (backend.yml and agent.yml) - if you changed them of course ...
  - check owner (must be 'sensu' user, he was created automatically) of folder and content for:
    - backend - /var/cache/sensu/sensu-backend/
    - agent - /var/cache/sensu/sensu-agent/

... then try to restart unit and check again.

When all services are installed (backend+WEB, cli, agent), visit web console again and check some info:

  - Main menu - Dasboard
  - Main menu - Select name - select 'default' (as setted in backend configs) - Entitites - select 'your entity name (hostname + OS name)' - select 'keepalive'

For runnig dockerized *sensu-agent*:

  ```bash
  # this image contain backend and agent
  ~ docker pull surian/sensu-go:latest

  # run only agent with backend parameter
  ~ docker run surian/sensu-go:latest \
    sensu-agent start \
    --backend-url ws://35.226.240.92:8091
  ```

If all ports are specified ports are open - check new entity in *SensuGO* web console.

## Grafana + SensuGO

Main installation guide -> [sensu](https://sensu.io/blog/visualizing-sensu-go-data-in-grafana):

  - check the latest release here -> [github](https://github.com/sensu/grafana-sensu-go-datasource/)

**TIP**: due to old state of this plugin, *Grafana* won't load this plugin - 'sens-sensugo-datasource' isn't signed !
  - after installation find conf file of *Grafana* 'default.ini' (in this case /usr/share/grafana/conf/defaults.ini)
  - change the key 'allow_loading_unsigned_plugins'

    ```ini
    # append name of installed SensuGO plugin to =
    allow_loading_unsigned_plugins = sensu-sensugo-datasource
    ```

  - restart *Grafana* unit

  - check list of 'data sources' on *Grafana* dashboard, there must appear 'Sensu Go' with *unsigned* label (in my case in the bottom of the list)

... info about this and the other keys in 'default.ini' -> [grafana](https://grafana.com/docs/grafana/latest/administration/configuration/#allow_loading_unsigned_plugins)

This repository contain sample dashboards for *SensuGO* also -> [github](https://github.com/sensu/grafana-sensu-go-datasource/tree/master/sample-dashboards):

  - some sample dashboards use old version of 'pie-chart' -> [grafana](https://grafana.com/grafana/plugins/grafana-piechart-panel/?tab=installation)
  - this chart can be installed from Grafana - Configuration - Plugins - serch 'pie' - one chart is already installed (new), choose the other (old) and install

## GO

First test + first app -> [digitalocean](https://www.digitalocean.com/community/tutorials/how-to-write-unit-tests-in-go-using-go-test-and-the-testing-package)

GO marathon -> [github]([github]
https://github.com/GolangUA/workshops/tree/master/easy-cystom-json-parsing
)

GO core course on SSITA ...

## Supervisorctl

Use Supervisor with Dockerfiles -> 
  
  - [gdevillele](https://gdevillele.github.io/engine/admin/using_supervisord/)

  - [advancedweb](https://advancedweb.hu/supervisor-with-docker-lessons-learned/)

Configuring Tomcat under Supervisor -> [programmer](https://programmer.group/supervisor-s-installation-and-management-of-tomcat-process-under-centos7.html)

Configuring *tzdata* and time zones (for some servers) by Dockerfile -> [rtfm](https://rtfm.co.ua/en/docker-configure-tzdata-and-timezone-during-build/)

### Commands

Main commands for building and managing Geo Citizen Docker image:

- for **ubuntu** based:

  ```bash
  # build Docker image
  ~ DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t geo-supervisor .
  # run dockerized Geo Citizen infrastructure
  ~ docker run -d -p 80:8080 -p 9000:80 -p 9005:5432 -p 9999:9001 geo-supervisor
  # interaction with Geo Citizen container
  ~ docker exec -it ??? bash
  ```

- for **alpine** based:

  ```bash
  # build Docker image; add 'BUILDKIT_PROGRESS=plain' for full logs
  ~ time DOCKER_BUILDKIT=1 docker build -t geo-alpine-supervisor .
  # create volume for PostgreSQL
  ~ docker volume create geovolume
  # run dockerized Geo Citizen infrastructure:
  # - first -p: for Tomcat
  # - second -p: for Supervisor web interface
  ~ docker run -d -p 80:8080 -p 9999:9001 geo-alpine-supervisor
  ~ docker run -d -p 80:8080 -p 9999:9001 --mount source=geovolume,destination=/var/lib/postgresql/data geo-alpine-supervisor
  # interaction with Geo Citizen container
  ~ docker exec -it ??? bash
  ```  

- for Docker volume:

  ```bash
  ~ docker volume create geovolume
  ~ docker volume list
  ~ docker run -it --mount source=test,destination=/var/lib/postgresql/data alpine
  ```

Additional commands: 

  ```bash
  # check size of running container 
  ~ docker container ls -s

  # check info about certain image
  ~ docker images geo-alpine-supervisor

  # deply Geo Citizen .war in running container
  ~ docker cp ./citizen.war ???:/opt/tomcat/latest/webapps/citizen.war

  # copy to/from docker container
  ~ docker cp foo.txt container_id:/foo.txt
  ~ docker cp container_id:/foo.txt foo.txt
  
  # PostgreSQL has own CLI with start/stop/restart ... options !
  ~ /etc/init.d/postgresql restart

  # connect to PostgreSQL remotelly
  ~ psql -h 35.226.240.92 -p 9005 -d postgres -U postgres -W

  # exporting Java variable for mvn
  ~ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.14.1.1-2.el8_5.x86_64
  ```

### Web interface

Web interface of Supervisord is configured in */etc/supervisord/supervisord.conf* by '[inet_http_server]' block. Then you can visit the page by http://public-ip-of-vm:port -> http://35.226.240.92:9999/ (in my case)


## ELK stack

Main guide to install -> [phoenixnap](https://phoenixnap.com/kb/install-elk-stack-centos-8)

## Appendix

### Nexus

List of disks/file system type/mount point on system:

  ```bash
  ~ lsblk -f
  ```

Jenkins publishes artefacts to Nexus -> [appfleet](https://appfleet.com/blog/publishing-artifacts-to-nexus-using-jenkins-pipelines/#:~:text=To%20create%20a%20new%20user,%2C%20it%20is%20jenkins%2Duser%20.)

If you are run out of space, delete some artefacts (manually/API/policy) -> this ONLY MARK these assets as *deleted*. If you want to free up space *literally* - create new *Task* with type *Compact blob store* with manual *Task frequency* and run this task. This task would delete all assets marked as *deleted*. Check logs if there are no errors and space info. 

### Maven

Maven uses Nexus -> [terasolunaorg](https://terasolunaorg.github.io/guideline/5.0.x/en/Appendix/Nexus.html)

### Miscellaneous

Diagram -> [stackoverflow](https://stackoverflow.com/questions/22569710/how-can-i-automatically-deploy-a-war-from-nexus-to-tomcat)

JSONPath validator online -> [jsonpath](https://jsonpath.curiousconcept.com/#)

### Commands

wget:

  ```bash
  # donwload certain version of .war file
  ~ wget \
    --user=$nexus_snap_user \
    --password=$nexus_snap_pass \
    http://ip:8081/repository/maven-snapshots/com/softserveinc/geo-citizen/1.0.5-SNAPSHOT/geo-citizen-1.0.5-20220313.234831-3.war
  ```

cURL:

  ```bash
  # download the latest snapshot
  ~ curl -L  \
    --output "citizen.war" \
    --user "$nexus_snap_user:$nexus_snap_pass" \
    "http://ip:8081/service/rest/v1/search/assets/download?sort=version&direction=desc&repository=maven-snapshots&maven.groupId=com.softserveinc&maven.artifactId=geo-citizen&maven.baseVersion=1.0.5-SNAPSHOT&maven.extension=war"

  # get location (URL) of latest snapshot
  ~ curl -L --head --silent 
    --user "$nexus_snap_user:$nexus_snap_pass" \
    "http://ip:8081/service/rest/v1/search/assets/download?sort=version&direction=desc&repository=maven-snapshots&maven.groupId=com.softserveinc&maven.artifactId=geo-citizen&maven.baseVersion=1.0.5-SNAPSHOT&maven.extension=war" \
    | grep 'Location' \
    | sed 's/Location: //g'

  # get default name for .war  from pom.xml file
  ~ curl -s -L \
    --user "$nexus_snap_user:$nexus_snap_pass" \
    "http://ip:8081/service/rest/v1/search/assets/download?sort=version&repository=maven-snapshots&maven.baseVersion=1.0.5-SNAPSHOT&maven.extension=pom" \
    | grep '<project.fileName>' \
    | awk -F[\>\<] '{print $3}'
  ```

gcloud:

  ```bash
  # get public IP of 'server' instance by 'describe' subcommand
  ~ gcloud compute instances describe db \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)' \
    --zone=us-central1-a

  # get public IP of 'server' instance by 'list' subcommand
  ~ gcloud compute instances list  \
    --format="value(networkInterfaces.accessConfigs.natIP)" \
    --filter=name:server \
    --zones=us-central1-a \
    | awk -F[\'\'] '{print $2}'

  # get public IP of instances (from default/setted zone)
  ~ gcloud compute instances list \
    --format="value(networkInterfaces[0].accessConfigs[0].natIP)"

  # get private IP of instances (from default/setted zone)
  ~ gcloud compute instances list \
    --format="value(networkInterfaces[0].networkIP)"
  ```

gcloud (lb variant):

  ```bash
  # get public IP of 'server' instances by 'list' subcommand
  ~ gcloud compute instances list \
    --format="value(networkInterfaces.accessConfigs.natIP)" \
    --filter=labels.instance_type:server \
    --zones=us-central1-a \
    | awk -F[\'\'] '{print $2}'

  # self-description
  ~ gcloud compute instances list \
    --filter=name:$(hostname) \
    --format="value(networkInterfaces.accessConfigs.natIP)" \
    | awk -F[\'\'] '{print $2}'    
  ```

webhookrelay:

  ```bash
  # to test webhooks on https://bin.webhookrelay.com/
  ~ curl -X POST  \
    -H "Content-Type: application/json" \
    -d "{'host': $(hostname), 'label': 'test'}" \
    https://bin.webhookrelay.com/autogenarated-id-of-bin
  ```

Generic Webhook Trigger:

  ```bash
  ~ curl -X POST \
    -H "Content-Type: application/json" \
    -d "{'host': $(hostname), 'label': 'test'}" \
    https://name.hooks.webhookrelay.com/invoke?token=tester
