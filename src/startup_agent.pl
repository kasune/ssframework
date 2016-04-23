#!/usr/bin/perl
#$gr_home=$ENV{'GRFRAMEWORK_HOME'};

BEGIN { push @INC,"../src";}

use IO::Socket;
use Try::Tiny;

use configurator;
use network;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

Log::Log4perl::init('../conf/log4p.conf');
$logger = Log::Log4perl->get_logger('HMS.GR.startup_agent');
#use Net::SMTP;
#use SendMail 2.09;

my $agent_ip    = configurator->get_startup_host();
my $agent_port  = configurator->get_startup_port();
my @script_list = configurator->get_script_list();
my $agent_mode  = configurator->get_startup_mode();
my $regular_expression_service  = configurator->get_regular_expression_service();

$| = 1;
my $sock ;
my $service_state;

try{
	$sock = new IO::Socket::INET ( 
        LocalHost => $agent_ip, 
        LocalPort => $agent_port, 
        Proto => 'tcp', 
        Listen => 1, 
        Reuse => 1, 
		Type => SOCK_STREAM,
) || die; 
}catch {
	$logger->debug("Server didn't started ".$_);
	exit 1;
};

$logger->debug("--------------Startup Agent started---------------");

my $q=0;
my $rhostname;
my $i=0;

while ($q != -999){
	$logger->debug('startup agent waiting for socket....');
        my $new_sock = $sock->accept();
        $i++;   
	$logger->debug($i.' times accepted');
        while(<$new_sock>) {
		chomp;
		$logger->debug("received command - ".$_);
               
                my $ip_status = 2;

		@input_command = split(':', $_);

		$command = $_;

		$logger->debug("received request ".$command);
		
        if ($command eq "FAILOVER-ENABLE"){
            $logger->debug($command." received. failover trigering to modules");
			if ( $agent_mode eq "start"){
				$logger->debug("starting modules");
				start_module();		
			}else{
				$logger->debug("stoping modules");
				stop_module();
			}
		#	sleep(2);
			print $new_sock "1\n";
			sleep(2);
        }else{   
			if ($command eq "STATUS-CHECK"){
				$logger->debug($command." received. status check starting ...");
				check_service();
				print $new_sock "$service_state\n";
			sleep(2);
			}else{
				$logger->debug($command." received");          
				}
			}
			
        }
}

sub check_service {
	foreach my $script_data(@script_list){
        my @agent_conf = split(',', $script_data);
		my $module_state=1;
		$logger->debug("Checking Module - ".$agent_conf[0]." Script-".$agent_conf[1]);
		try { 
	        $module_state=system("sh $agent_conf[1] status");

		}catch{
			$logger->debug("Error on status ".$_);
			network->send_snmp("error in status check $agent_conf[0]");
		};
		$regular_expression_service==~ s/$agent_conf[0]/$module_state/g;
	}
	if (eval $regular_expression_service){
		$logger->debug("services are up");
		$service_state = 0;
	}else{
		$logger->debug("services failure detected");
		$service_state = 1;
		network->send_snmp("error in services $agent_conf[0]");
	}
}
sub start_module {
	
	foreach my $script_data(@script_list){
                my @agent_conf = split(',', $script_data);
		my $module_state=1;

		$logger->debug("Module - ".$agent_conf[0]." Script-".$agent_conf[1]);
	
		try { 
	                $module_state=system("sh $agent_conf[1] status");

		}catch{
			$logger->debug("Error on status ".$_);
			network->send_snmp("error in status check $agent_conf[0]");
		};
		$logger->debug("status return-".$module_state);        
	        if ($module_state ne 0 ){
                        $logger->debug("$agent_conf[0] is stoped ");

			try{			
				$module_state=system("sh $agent_conf[1] start");
			}catch{
				$logger->debug("Error on start ".$_);
				network->send_snmp("error in start $agent_conf[0]");
			};
			sleep(3);

			try{
				$module_new_state=system("sh $agent_conf[1] status");
			}catch{
				$logger->debug("Error on status ".$_);
				network->send_snmp("error in status check $agent_conf[0]");
			};
			if ($module_new_state eq 0 ){
				$logger->debug("Module $agent_conf[0] started");
			}else{
				$logger->debug("Module $agent_conf[0] failure on start");
				network->send_snmp("Module $agent_conf[0] fail permanently");		
			}

            }else{
			$logger->debug("$agent_conf[0] is active");
			$logger->debug("service start is not executed");
			network->send_snmp("Module $agent_conf[0] already active");
			}
        }
	
}

sub stop_module {
		foreach my $script_data(@script_list){
                my @agent_conf = split(',', $script_data);
                my $module_state=1;

                $logger->debug("Module - ".$agent_conf[0]." Script-".$agent_conf[1]);

                try { 
                        $module_state=system("sh $agent_conf[1] status");

                }catch{
                        $logger->debug("Error on status ".$_);
                        network->send_snmp("error in status check $agent_conf[0]");
                };
                $logger->debug("status return-".$module_state);
                if ($module_state eq 0 ){
                        $logger->debug("$agent_conf[0] is up ");

                        try{
                                $module_state=system("sh $agent_conf[1] stop");
                        }catch{
                                $logger->debug("Error on start ".$_);
                                network->send_snmp("error in stoping $agent_conf[0]");
                        };
                        sleep(3);

                        try{
                                $module_new_state=system("sh $agent_conf[1] status");
                        }catch{
                                $logger->debug("Error on status ".$_);
                                network->send_snmp("error in status check $agent_conf[0]");
                        };
                        if ($module_new_state ne 0 ){
                                $logger->debug("Module $agent_conf[0] stoped");
                        }else{
                                $logger->debug("Module $agent_conf[0] failure on stop");
                                network->send_snmp("Module $agent_conf[0] fail permanently on stoping");
                        }

                }else{
                        $logger->debug("$agent_conf[0] is stop already");
                        $logger->debug("service stop is not executed");
                        network->send_snmp("Module $agent_conf[0] already stop");
                }
        }

}

close($sock);
exit 0;
