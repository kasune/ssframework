#!/usr/bin/perl
BEGIN { push @INC,"../src";}
#use warnings;
#use strict;

use configurator;
use network;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

Log::Log4perl::init('../conf/log4p.conf');

#Log::Log4perl.$logger->debug($time_stamp_file_path);

$logger = Log::Log4perl->get_logger('Start removing last 3 records from timestamp.amp');

Log::Log4perl.$logger->debug('Timestamp line remover is starting... ');
#$logger->debug($time_stamp_file_path);
my $timestamp_file_path= configurator->get_time_stamp_file_path();
$logger->debug("Timestamp.ama file location = ". $timestamp_file_path);

my $backup_timestamp_file_name= configurator->get_backup_time_stamp_file_path();
$logger->debug("Backup location = ".$backup_timestamp_file_name); 

my $number_of_removing_lines= configurator->get_number_of_lines_to_be_remove();
$logger->debug("Lines to be remove =  ". $number_of_removing_lines);	


	if (-e $timestamp_file_path) {
               
 		$logger->debug($timestamp_file_path . " is exsists");
		$logger->debug($timestamp_file_path . " is going to backup");
		system ("cp $timestamp_file_path $backup_timestamp_file_name");
			
			if (-e $backup_timestamp_file_name) {		
			
			$logger->debug($timestamp_file_path . " is successfully backuped to  ". $backup_timestamp_file_name);

			 $line_count_before_remove=`cat $timestamp_file_path |wc -l`;
							
				open(FH,$timestamp_file_path);
				@array = <FH>;
				close FH;
				system ("rm $timestamp_file_path");
				open(OUT,'>',$timestamp_file_path);
				print OUT @array[$number_of_removing_lines..$#array];
				close OUT;
			
			 	$line_count_after_removed=`cat $timestamp_file_path |wc -l`;
			
				if (($line_count_before_remove-$line_count_after_removed)==$number_of_removing_lines){
				
					$logger->debug("Last ".number_of_removing_line." lines has been removed successfully");  
			
				}
				else {
					$logger->error("Line removing failed");
					network->send_snmp("Line removing failed from $timestamp_file_path ");
				}			
			}
			else {

				$logger->error($timestamp_file_path . " backuped fail");
				network->send_snmp("$timestamp_file_path file backuped fail");
			}			
		
 	} 
	else {
		
		$logger->error($timestamp_file_path. " is not exsists");
		network->send_snmp("$timestamp_file_path is not exists in side the server");
	}


