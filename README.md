# smokeping-host
Docker container for SmokePing host based on phusion/baseimage container.  
Uses Ansible for SmokePing target generation and container build and run process.

### Pre-Requisites
Must have Ansible installed within Docker host.  Tested with 2.1 on OS X, but should work with earlier versions.  Future testing may include using a Docker container with Ansible to provision this SmokePing container

### Usage
Uses Ansible with jinja2 template to build Targets file for Smokeping.  Variables for hosts are stored within the `make_smokeping.yml` file.
Hosts to ping will need to be given a name and an ip address (could also use DNS name, but have not tried).  If adding additional hosts to either IPv4 or IPv6 sections, please use proper spaces, otherwise YAML will fail.  Do not use tabs unless editor has tab-to-space conversion

1. Clone repo
2. Edit `make_smokeping.yml` file with appropriate values based on deployment need
3. Execute `make_smokeping.yml`.  Ansible will generate the Targets file, build the Docker container, then copy the contents of the config.d folder into the appropriate locations in the container
4. Wait ~10 minutes.  access smokeping on localhost through `http://localhost:{{Docker.External_Port}}/cgi-bin/smokeping.cgi` or by accessing the IP address of the Docker host at the same URL and port.
5. SmokePing will generate plots based on 20 pings every 5 minutes, equally spaced.

### Editing `make_smokeping.yml`
Within the YAML file, there is a dictionary of values that is used to build or run the Docker container.  These values can be modified as follows

* `Container_Name`
  * Used to generate the final Docker container name.  Can be edited to whatever name desired.
* `TZ`
  * Used to shift the timezone of the Docker container and the subsequent SmokePing plots.  Requires valid Linux TZ location.  List of codes can be found at [this WikiPedia page](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) in the TZ column
* `Config`
  * Should be kept as-is, but was set as variable for consistency and if output directory ever changed
* `External_Port`
  * Change to any port that is wished to be exposed to public to access SmokePing page.  Will be remapped to 80 to speak with the SmokePing container
* `Smokeping_Config`
  * Same as `Config` above.  Should be kept as-is, as this is where SmokePing is looking for configuration data that will be copied to the container
* `Base_Container`
  * Name of base Docker container that will be built.  This container will be a "blank" SmokePing container and required data (targets, etc) will be copied into the container using the `docker run` command

### Modifying Hosts to Ping
The YAML file also contains `IPv4_Hosts` and `IPv6_Hosts` sections.  These variable sections are lists of dictionaries for each device that is to be pinged by the SmokePing container.  To edit these hosts, please use the following syntax

* Each member of the list will need to start (9) spaces in, to keep with formatting
* The name of the host can include spaces, numbers, etc -- but cannot include periods.  General "website username" rules apply
* The address portion of the list will need to be either the IP address (preferred) or possibly the DNS name.  Given that this may be run from a local laptop, DNS may not be available
* Formatting (use of `name:` and `address:`) is critical to SmokePing targets generation.  Please don't use capitals or omit one or the other keys
* Separate each key:value pair with a comma and a single space as in `- {name: Router1, address: 10.255.255.1}`
* IPv6 address entries will need to be encapsulated in "double quotes" (`"`) due to the colon interfering with the key:value pairs in the dictionary

### Errata or Bugs
[ ] Native Docker for Mac OS X does not actually perform a ping, therefore all hosts entered will be seen as reachable from the container's point of view.  Docker for Mac is tracking this issue (#1925).  Latest test running 1.12.0-rc4-beta20 still has this issue.
[ ] Actual IPv6 addressing support will need to be statically enabled on the host.  Further instructions will be linked at a later date
