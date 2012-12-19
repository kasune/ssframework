#!/usr/bin/perl
BEGIN { push @INC,"../src";}
#use warnings;
#use strict;

use configurator;
use network;
use Schedule::Cron;
use Net::Ping;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

Log::Log4perl::init('../conf/log4p.conf');
$logger = Log::Log4perl->get_logger('HMS.GR.server_main');
                 
Log::Log4perl.$logger->debug('Main server initializing....');

my $cron = new Schedule::Cron(\&dispatcher);
my @agent_list;

# Load a crontab file
#$cron->load_crontab("/tmp/perl");

# Add dynamically  crontab entries
# $cron->add_entry("3 4  * * *",ROTATE => "apache","sendmail");

my $ip_check_cron= configurator->get_cron_ip_check() ;
#$cron->add_entry("* * * * *",\&check_main);

$cron->add_entry($ip_check_cron,\&check_main);

$cron->add_entry("5 00 * * *",\&log_rotate);

$logger->debug('Main server started');
# Run scheduler 
$cron->run();


# Subroutines to be called
sub dispatcher { 
       print "ID:   ",shift,"\n"; 
       print "Args: ","@_","\n";
}
sub log_rotate{
	my @mytime=localtime (time - 86400);
	my $month=@mytime[4]+1;
	my $year=@mytime[5]+1900;
	my $prev_day=$year."-".$month."-".@mytime[3];
        $logger->debug('log rotating');	
	system("cp ../logs/grframework.log ../logs/grframework.log.$prev_day");
	system("cat /dev/null > ../logs/grframework.log");
	$logger->debug('log rotation completed.');
}
             
sub check_main {
#system("uname", "-a");
my @ip_list= configurator->get_ping_ip_list() ;
@agent_list= configurator->get_agent_list() ;
my $reg_expression= configurator->get_reg_expression() ;
my $remote_server_ip = configurator-> get_server_main_ip();
my $remote_server_port = configurator-> get_server_main_port();
my $retry_count = configurator-> get_server_main_retry_count();
my $server_ping_wait = configurator-> get_server_ping_wait();
my $server_ping_next_wait = configurator-> get_server_ping_next_wait();
my $check_remote_flag = eval configurator-> get_check_remote_state();
#my $network_imp = network->new;

 $logger->debug('failover logic '.$reg_expression);
 foreach my $ip_data(@ip_list){
   my @values = split(',', $ip_data);
   #print "$values[0]";
   #print "$values[1]\n";

   @ip_array = ($values[1],$retry_count,$server_ping_wait,$server_ping_next_wait);
   $logger->debug($values[0]);
   $logger->debug($values[1].' '.$retry_count.' '.$server_ping_wait.' '.$server_ping_next_wait);
   
   #my $ip_status= $network_imp->ping_ip(@ip_array);
   
   my $ip_status= network->ping_ip(@ip_array);
   #$logger->debug($values[1].$remote_server_ip." ".$remote_server_port);
   if ($ip_status eq 0 && $check_remote_flag eq 1){
	network->send_snmp("ping failed-".$values[1]);
	$logger->debug("connecting to remote server ... - ,".$remote_server_ip."-".$remote_server_port);
	$ip_status=eval network->check_via_remote_server($values[1],$remote_server_ip,$remote_server_port,$retry_count,$server_ping_wait,$server_ping_next_wait);

	if ($ip_status ne 0 && $ip_status ne 1){
		$logger->debug("remote server in error mode - ".$ip_status);
		network->send_snmp("remote server in error mode -".$remote_server_ip);
		 $ip_status=0;	
	}

   }
   $logger->debug("final server status - ".$ip_status);
   #my $ip_status= networkImpl->ping_ip($values[1],$retry_count,$server_ping_wait,$server_ping_next_wait);
   $reg_expression =~ s/$values[0]/$ip_status/g;
   
#  foreach my $val (@values) {
#    print "$val";
#  }
 }

$logger->debug('faiover logic final - '.$reg_expression);

 if (eval $reg_expression){
	$logger->debug("no failover");
 }else{
	$logger->debug("falling to FailOver mode");
	failover(@agent_list);
 }
}

sub failover{
	network->send_snmp("Mode change - FailOver");
	
	foreach my $agent_data(@agent_list){
		my @agent_conf = split(',', $agent_data);	
   		@agent_array = ($agent_conf[0],$agent_conf[1]);
		$logger->debug("trigger startup procedure to ".$agent_conf[0]."-".$agent_conf[1]);
		my $state = network->send_agent_startup(@agent_array);
		if ($state eq 0 ){
			network->send_snmp("failure on startup ".$agent_conf[0]."-".$agent_conf[1]);
		}
	}
}
