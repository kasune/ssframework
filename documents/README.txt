
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SSF <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Required
-------------------------------------------
	Perl 5
	Bash shell
	
	Below cpan libraries need to install. Its also inside lib/ folder. 
	Log-Log4perl-1.37
	Schedule-Cron-0.9.
	Time-modules-2003.0211
	Try-Tiny-0.11
	
	as root
		perl Makefile.perl
		make
		make install

Configurations
-------------------------------------------	
	bin/ has all the executables
	conf/ has all the configuration files
	src/ custom packages use by Framework
	lib/ extra dependant packages need to install
	documents/ all the docs 
	temp/ directory, use as temp location
	logs/ contain the log files
	
Running
-------------------------------------------	
	Remote_server.sh is to listen request from clients and proceed with ping check and reply back. Check server.conf for configurations. log4p.conf has logging configurations
	>Start as root

	start Main_server.sh is doing main ping check to servers and if fail it connect remote server(if it is allowed)and based on that do the failover. server_list.conf,startup_agent.conf
	and main.conf has the configurations. log4p.conf has logging configurations.
	>Start as root
	
	Startup_agent.sh is doing the service start/stop base when call by the main server. Change the Startup agent mode on start or stop mode.script.conf has the configurations start/stop services. server.conf has Startup agent listening IP/Port
	>Start as root
	
	set APP_HOME in above scripts by editing the file
	

1. Installation
-------------------------------------------
	Login as root
	<SSFramework home> = The directory of GR Framework

	1. Change configurations of conf files in <SSFramework home>/conf
	
	2. Start the necessary scripts in <SSFramework home>/bin