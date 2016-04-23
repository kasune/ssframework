#!/usr/bin/perl

package network;

use Net::Ping;
use IO::Socket;
use Try::Tiny;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);Log::Log4perl::init('../conf/log4p.conf');
$logger = Log::Log4perl->get_logger('HMS.GR.Main.network');

$Mode = 066;     # Test for writeability; use 066 for read or write

my $main_ip= "";
my $retry_count= 0;
my $ping_wait = "";
my $ping_next_wait= "";

sub ping_ip {
#my ($main_ip,$retry_count,$ping_wait,$ping_next_wait) = @_;

my $main_ip=$_[1];
my $retries = 0;
my $retry_count=$_[2];
my $ping_wait=$_[3];
my $ping_next_wait=$_[4];

my $result=0;
$p = Net::Ping->new( 'icmp');

   if ($p->ping($main_ip,$ping_wait)){
        $result=1;
        $logger->debug($main_ip.' is alive');
   }
   else{
        $logger->debug($main_ip.' ping failed');
        my $retries = 1;

        while ($retry_count >= $retries) {
           sleep($ping_next_wait);
           if($p->ping($main_ip,$ping_wait)){
                $result=1;
                $logger->debug('retry count '.$retries.'-'.$main_ip.' is alive');
                break;
           }
           else{
                $result=0;
                $logger->debug('retry count '.$retries.'-'.$main_ip.' ping failed');
           }
                $retries++;
        }
   }
$p->close();

return $result;	
}

sub check_via_remote_server{
        my $check_server=$_[1];
        my $rhostname=$_[2];
        my $port=$_[3];
        #$rhostname='192.168.0.181';
        #$port = '7071';
        my $retry=eval $_[4];
        my $ping_w=eval $_[5];
        my $wait_n=eval $_[6];
	my $data = 2;
	my $error_code=0;
	my $client_sock ;	

        #$logger->debug($check_server);
        #$logger->debug($rhostname.$port.$retry.$ping_w.$wait_n);

try{
	$client_sock = new IO::Socket::INET (
        PeerAddr => $rhostname,
        PeerPort => $port,
        Proto => 'tcp',
) || die ;
	$client_sock->autoflush(1);
        my $query = "START:".$check_server.":".$retry.":".$ping_w.":".$wait_n;

        $logger->debug("sending ".$query);
        print $client_sock "$query\n";

        $data = <$client_sock>;
        ##$sock->recv($buf2,1);
        close($client_sock);
}catch {

	$logger->debug("caught error:".$_);
	$error_code = 1;
};	
        return $data;
}

sub send_agent_startup{
	my $agent_ip=$_[1];
        my $agent_port=$_[2];
        my $agent_sock ;
	my $status=0;

	try{
        	$agent_sock = new IO::Socket::INET (
        	PeerAddr => $agent_ip,
        	PeerPort => $agent_port,
        	Proto => 'tcp',
	) || die ;
       		$agent_sock->autoflush(1);
        	my $query = "FAILOVER-ENABLE";
			$status =1;
        	$logger->debug("sending ".$query);
        	print $agent_sock "$query\n";

        	$response = <$agent_sock>;
		$logger->debug($response);
        	close($agent_sock);
		$logger->debug("socket to startup agent closed");
	}catch {
        	$logger->debug("caught error:".$_);
        	$status = 0;
	}; 
	return $status;
}

sub send_service_check{
	my $agent_ip=$_[1];
    my $agent_port=$_[2];
    my $agent_sock ;
	my $status=0;

	try{
        	$agent_sock = new IO::Socket::INET (
        	PeerAddr => $agent_ip,
        	PeerPort => $agent_port,
        	Proto => 'tcp',
	) || die ;
       		$agent_sock->autoflush(1);
        	my $query = "STATUS-CHECK";
			$status =1;
        	$logger->debug("sending ".$query);
        	print $agent_sock "$query\n";
        	$response = <$agent_sock>;
			$logger->debug($response);
        	close($agent_sock);
			$logger->debug("socket to startup agent closed");
	}catch {
        	$logger->debug("caught error:".$_);
        	$status = 0;
	}; 
	return $status;
}

sub send_snmp{
	my $message=$_[1];
	$logger->debug("sent snmp - ".$message);
	system("sh ../bin/snmp_send.sh '2021.10.1.1|1|$message'");
}

1;
