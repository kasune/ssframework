#!/usr/bin/perl

package configurator;

use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);Log::Log4perl::init('../conf/log4pMainServer.conf');
$logger = Log::Log4perl->get_logger('HMS.GR.Main.configurator');

$Mode = 066;     # Test for writeability; use 066 for read or write

my $server_host= "";
my $server_port= "";
my $temp_location= "";
my $no_clients= "";
my $mail_host= "";
my $mail_port= "";

%server_details=&read_config('../conf/remote_server.conf');
while (($key, $value) = each(%server_details)){
			 if($key eq "server_host"){
                     $server_host=$value;
             }
             if($key eq "server_port"){
                     $server_port=$value;
             }
             if($key eq "temp_location"){
                     $temp_location=$value;
             }
             if($key eq "no_of_clients"){
                     $no_clients=$value;
             }
             if($key eq "mail_host"){
                     $mail_host=$value;
             }
             if($key eq "mail_port"){
                     $mail_port=$value;
             }
}

my $server_main_ip = "";
my $server_main_port= "";
my $ping_ip_retry = "";
my $ping_wait = "";
my $next_ping_wait= "";
my $cron_ip_ping_schedule = "";
my $check_remote_state ="";
my $startup_agent_check_service = "";
my $ping_check= "";

%config=&read_config('../conf/main.conf');
while (($key, $value) = each(%config)){
		#logit $key.$value."\n";
		if($key eq "remote_server_main_ip"){
			$server_main_ip=$value;
		}
		if($key eq "remote_server_main_port"){
            $server_main_port=$value;
        }
		if($key eq "server_ping_ip_retry"){
            $ping_ip_retry=$value;
        }
		 if($key eq "server_ping_wait"){
            $ping_wait=$value;
         }
		if($key eq "server_next_ping_timeout"){
            $next_ping_wait=$value;
        }
		if($key eq "ip_ping_schedule"){
            $cron_ip_ping_schedule=$value;
        }
		if($key eq "check_remote_state"){
            $check_remote_state=$value;
        }
		 if($key eq "startup_agent_check_service"){
			$startup_agent_check_service=$value;
		}
		if($key eq "ping_check"){
			$ping_check=$value;
		}

}

%ip_list_config=&read_config('../conf/server_list.conf');
my $regular_expression_failover;
my @ip_list;

while (($key, $pingip,$startupagentip,$startupagentport,$checkremotestat) = each(%ip_list_config)){
		if($key eq "regular_expression_failover"){
                        $regular_expression_failover=$pingip;
                }else{
			my $temp = $key.','.$pingip.','.$startupagentip.','.$startupagentport.','.$checkremotestat;
        		push(@ip_list,$temp);
                }
		
}

%start_agents=&read_config('../conf/startup_agents.conf');
my @agent_list;

while (($key, $value) = each(%start_agents)){
                        my $temp = $key.','.$value;
                        push(@agent_list,$temp);
}

%script_location=&read_config('../conf/script.conf');
my @script_list;
my $regular_expression_service;

while (($key, $value) = each(%script_location)){
		if($key eq "regular_expression_service"){
            $$regular_expression_service=$value;
        }else{
            my $temp = $key.','.$value;
            push(@script_list,$temp);
		}
}

my $startup_host="";
my $startup_port="";
my $startup_mode="";

%config=&read_config('../conf/startup_agent_server.conf');
while (($key, $value) = each(%config)){
		#logit $key.$value."\n";
		if($key eq "startup_agent_host"){
			$startup_host=$value;
		}
		if($key eq "startup_agent_port"){
			$startup_port=$value;
		}
		if($key eq "startup_mode"){
			$startup_mode=$value;
		}
}
		
#$logger->debug('ping_ip_retry '.$ping_ip_retry);
#$logger->debug('ping_wait '.$ping_wait);
#$logger->debug('next_ping_wait '.$next_ping_wait);
#$logger->debug('ip ping schedule '.$cron_ip_ping_schedule);
#$logger->debug('server ip '.$server_host);
#$logger->debug('server port '.$server_port);
#$logger->debug('no of clients '.$no_clients);
#$logger->debug('temp location '.$temp_location);

sub read_config {          # parse file with "var=value" format
    my ($file) = @_;
    $logger->debug("reading configuration from ".$file);	
    my %hash = ();           # left side of = will be key
         open(FH, $file) or die "Can't open $file: $!\n";
         while (<FH>) {
              next if /^#/;  # ignore comments
              s/#.*//;       # remove trailing comments
              s/^\s*//;      # remove leading space
              s/\s*$//;      # remove trailing space
              $hash{$1}=$2 if (/(.*)\s*=\s*(.*)/);
         }
         close FH;
  return %hash;              # return this to the caller
}

sub get_server_main_port{
   return $server_main_port;
}
sub get_server_main_ip{
   return $server_main_ip;
}
sub get_server_main_retry_count{
   return $ping_ip_retry;
}
sub get_server_ping_wait{
   return $ping_wait;
}
sub get_server_ping_next_wait{
   return $next_ping_wait;
}
sub get_check_remote_state{
   return $check_remote_state;
}
sub get_startup_agent_check_service{
   return $startup_agent_check_service;
}   
sub get_ping_check{
	return $ping_check;
}
sub get_ping_ip_list{
   return @ip_list;
}
sub get_agent_list{
   return @agent_list;
}
sub get_script_list{
   return @script_list;
}
sub get_reg_expression{
   return $regular_expression_failover;
}
sub get_cron_ip_check{
   return $cron_ip_ping_schedule;
}
sub get_server_ip{
   return $server_host;
}
sub get_server_port{
   return $server_port;
}
sub get_no_of_clients{
   return $no_clients;
}
sub get_temp_location{
   return $temp_location;
}
sub get_startup_agent_check{
   return $startup_agent_check;
}	
sub get_startup_host{
   return $startup_host;
}
sub get_startup_port{
   return $startup_port;
}
sub get_startup_mode{
   return $startup_mode;
}
sub get_regular_expression_service{
   return $regular_expression_service;
}
1;
