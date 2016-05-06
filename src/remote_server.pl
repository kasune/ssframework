#!/usr/bin/perl
#$gr_home=$ENV{'GRFRAMEWORK_HOME'};

BEGIN { push @INC,"../src";}

use IO::Socket;
use Try::Tiny;

use configurator;
use network;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

Log::Log4perl::init('../conf/log4pRemoteServer.conf');
$logger = Log::Log4perl->get_logger('HMS.GR.remote_server');
#use Net::SMTP;
#use SendMail 2.09;

my $host_ip= configurator->get_server_ip();
my $host_port= configurator->get_server_port();
my $no_of_clients= configurator->get_no_of_clients();
my $agent_service_check = configurator->get_startup_agent_check();
$| = 1;
my $sock ;

try{
	 $sock = new IO::Socket::INET ( 
        LocalHost => $host_ip, 
        LocalPort => $host_port, 
        Proto => 'tcp', 
        Listen => 1, 
        Reuse => 1, 
) || die; 
}catch {
	$logger->debug("Server didn't started ".$_);
	exit 1;
};

$logger->debug("--------------Remote server started---------------");

my $q=0;
my $rhostname;
my $i=0;

while ($q != -999){
	$logger->debug('remote server waiting for socket....');
        my $new_sock = $sock->accept();
#	sleep(5);
        $i++;   
	$logger->debug($i.' accept');
        while(<$new_sock>) {
		chomp;
	#	print $_;
		$logger->debug("received command - ".$_);
                #@input=grep {/^Content/} $_;
                #$size = scalar @input;
                my $ip_status = 2;

		@input_command = split(':', $_);

		$command = @input_command[0];
		$server_ip = @input_command[1];
		$retry_count= @input_command[2];
		$wait_time = @input_command[3];
		$next_ping_wait = @input_command[4];
		$client_ip = @input_command[5];
		$client_port = @input_command[6];

		@ping_array=($server_ip,$retry_count,$wait_time,$next_ping_wait);
		$logger->debug("received request ".@input_command);
		$logger->debug($command);
                if ($command eq "START"){
            #$logger->debug($command." received");
			$ip_status = network->ping_ip(@ping_array);
			$logger->debug("ping status - ".$ip_status);
#			$logger->debug($client_ip.$client_port);
			sleep(2);
			print $new_sock "$ip_status\n";

                }else{
                        #@input = split(/\&/,$_);
                        #$rhostname=$input[1];
                        #$command=$input[3];
                        #$logfilename=$input[4];      
						#$logger->debug($command." received"); 
						my @agent_array = ($server_ip,$retry_count);
						$ip_status = network->send_service_check(@agent_array );
						#$logger->debug("send service check ".$ip_status); 
						sleep(2);
						print $new_sock "$ip_status\n";
			}
                }
}

close($sock);
exit 0;
