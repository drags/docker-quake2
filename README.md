# Quake II via Docker
This repository can be used for quickly standing up Quake II servers using Docker. The repository includes only free resources, the data from the Quake II demo, along with the latest nightly build from q2pro for the server software. In order to play maps and content from the full Quake II single player mission copy the pak0.pak file from your client install media into the baseq2 directory.

## Creating a new server
To use the default settings (DM, Fraglimit 30, Timelimit 15mins) proceed to [building and deploying](#building-and-deploying).

### Customizing settings
In order to keep track of server configs long term it's recommended to fork this repo and create a branch for each server. The branches can be revisited (and updated from master), then the docker images rebuilt when updates are necessary.

#### Notable CVARs
For servers that will be used on an on-going (non-temporary) basis the following CVARs should be updated inside of the baseq2/server.cfg file:

	- hostname
	- sv_password (for private, password protected servers)
	- rcon_password (for remote administration)
	- maxclients
	- timelimit
	- fraglimit

**Note about IP:PORT** Do not modify *net_ip* or *net_port*. Docker provides a method for mapping public ports to the containers network which is explained below in [building and deploying](#building-and-deploying).


#### Adding content (maps/models/skins/sounds)
Add content as you normally would for a Quake II server, laying the files directly into this repository as if it was the root of a /opt/quake2 game directory.

**A note about adding mods** In order to run another mod besides baseq2 the "game" setting must be passed at startup. In this dockerized setup the command that is executed at startup is set in the *Dockerfile* file. Change the line that beings with 'CMD to add something '+set game <gamename>', then rebuild the image. Also be sure to base the mods server.cfg off the one found in baseq2/

### Making a public server
By default this server does not announce itself to the Quake II master servers. It is designed to be used for temporary games where the server address can be communicated among friends. In order to announce the server (so it will show up when random internet users browse the Quake II server list) uncomment and customize the lines under the heading "// FOR PUBLIC SERVERS" in server.cfg

### Building and deploying
Build the docker image and tag your server like so:

	docker build --rm -t quake2/server1 .

Building the image packs the current state of the repository into a Docker image. Store the different configurations for each server in a different git branch, then checkout that branch and execute another `docker build` command to update that server's image.

Start the server and map it to port 27910:

	# run in the foreground (useful for controlling the server from the server console)
	docker run -it -p 27910:27910/udp quake2/server1

	# run in daemon mode
	docker run -d -p 27910:27910/udp quake2/server1

**To run multiple servers**: configure each server as suggested above, but do not change the *net_ip* or *net_port* settings. Use different port arguments to the `docker run` command to put servers on different ports, for example to run *server1* on port 27910 and *server2* on port 27999:

	docker run -d -p 27910:27910/udp quake2/server1
	docker run -d -p 27999:27910/udp quake2/server2


## Remote administration
Quake II allows for remote administration (changing maps and settings, kicking players, etc.) via rcon. A quick prime on rcon:

	- Firstly the server must have an rcon_password set. If rcon_password is set to "" then rcon is disabled.
	- Clients then set the rcon_password setting on their client, it should match the value on the server.
	- With rcon_password set clients may issue 'rcon <command>' at their client console, and the command will run on the server console

	Ex:
		rcon gamemap q2dm2
		rcon fraglimit 100
		rcon kick Cheater

	Refer to the official Quake II server guide for more information.

## Web hosting content for faster download
*TODO*
