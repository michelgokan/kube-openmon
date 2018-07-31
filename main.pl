#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(time);
use WWW::Curl::Easy;   
use InfluxDB;

my $GLOBAL_TIMESTAMP;

sub validateEnvironmentVariables(){
   if(!defined $ENV{'KUBERNETES_TOKEN'} || !defined $ENV{'KUBERNETES_ADDRESS'} || !defined $ENV{'KUBERNETES_PORT'}){
      die("Kubernetes environment variables are not set correctly!");
   }

   if(!defined $ENV{'INFLUXDB_ADDRESS'} || !defined $ENV{'INFLUXDB_PORT'} || !defined $ENV{'INFLUXDB_USERNAME'} || !defined $ENV{'INFLUXDB_PASSWORD'} || !defined $ENV{'INFLUXDB_DATABASE'}){
      die("InfluxDB environment variables are not set correctly!");
   }

   if(!defined $ENV{'NODE_NAME'}){
      die("\$NODE_NAME is not set!"); 
   }

   return 1;
}

sub getMetrics(){
   my $curl = WWW::Curl::Easy->new;

   my @headers  = ("Authorization: Bearer $ENV{'KUBERNETES_TOKEN'}");

   $curl->setopt(CURLOPT_HEADER,1);
   $curl->setopt(CURLOPT_HTTPHEADER, \@headers);
   $curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
   $curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);
   $curl->setopt(CURLOPT_URL, "https://$ENV{'KUBERNETES_ADDRESS'}:$ENV{'KUBERNETES_PORT'}/api/v1/nodes/kubernetes3/proxy/metrics/cadvisor");

   my $response_body;
   $curl->setopt(CURLOPT_WRITEDATA,\$response_body);


# Starts the actual request
   my $retcode = $curl->perform;
   $GLOBAL_TIMESTAMP=sprintf("%.9f",time);
   $GLOBAL_TIMESTAMP=~s/\.//g;
      
   if ($retcode == 0) {
      print("Transfer went ok\n");
      my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
# judge result and next action based on $response_code

      if( $response_code != 200 ){
         die("Error with response code: $response_code\n");
      }
   } else {
# Error code, type of error, error message
      die("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
   }

   return $response_body;
}

sub generateQuery{
   my $response_body = $_[0];
   
   #my %variables;
   #my %pods;
   #container_scrape_error

   my $query = "CREATE DATABASE IF NOT EXISTS $ENV{'INFLUXDB_DATABASE'}\n";
   $query .= "USE $ENV{'INFLUXDB_DATABASE'}\n";

   foreach my $line (split /\n/ ,$response_body) {
      for ($line) {
#      if (/^#\sTYPE\s(.*?)\s(.*?)$/){
#         $variables{$1} = $2;
         #if (/^(container_.*?)\{container_name="(.*?)",(?:device=")?(.*?)?"?.*?(?:cpu=")?(.*?)?"?.*?id="(.*?)",image="(.*?)",name="(.*?)",namespace="(.*?)",pod_name="(.*?)".*?\s(.*)$/) {
#print ("$1\[\"$2\"\]\[\"$10\"\]\[\"$11\"\]\[\"$9\"\]\[\"$8\"\]\[\"$7\"\]=$12\n"); 
#            $query .= "INSERT $1,";
 #           $query .= "node_name=$ENV{NOD_NAME}";
  #          $query .= $2 eq "" ? "" : ",container_name=$2";
   #         $query .= $3 eq "" ? "" : ",device=$3";
    #        $query .= $4 eq "" ? "" : ",cpu=$4";
     #       $query .= $7 eq "" ? "" : ",id=$7";
      #      $query .= $8 eq "" ? "" : ",image=$8";
       #     $query .= $9 eq "" ? "" : ",name=$9";
        #    $query .= $10 eq "" ? "" : ",namespace=$10";
         #   $query .= $10 eq "" ? "" : ",pod_name=$11";
          #  $query .= " value=$12;";
   #} elsif(/^(machine_.*?)\s(.*?)$/){
    #  $query .= "INSERT $1,node_name=$ENV{NOD_NAME} value=$2;";
   #} elsif(/^(container_scrape_error)\s(.*?)$/){
    #     $query .= "INSERT $1,node_name=$ENV{NOD_NAME},container_name=-,device=-,cpu=-,id=-,image=-,name=-,namespace=-,pod_name=- value=$2;";
     #       } 
           # print("\$1=$1");
         #}
         
         if (/^([A-Za-z0-9_-]+?)\{(.*?)\}\s+(.*?)$/) {
            my $val = sprintf("%.20g", $3);
            $query .= "INSERT $1,node_name=$ENV{NODE_NAME},$2 value=$val $GLOBAL_TIMESTAMP\n";
         } elsif(/^([A-Za-z0-9_-]+?)\s+(.*?)$/) {
            my $val = sprintf("%.20g", $2);
            $query .= "INSERT $1,node_name=$ENV{NODE_NAME} value=$val $GLOBAL_TIMESTAMP\n";
         }
      }
   }
   return $query;
}

if( validateEnvironmentVariables() ){
   my $response_body = getMetrics();
   my $query = generateQuery($response_body);
   print $query;
}
#print Dumper \%pods;

#$query .= "INSERT container,container_name=$2,device=$4,cpu=$6,id=$7,image=$8,name=$9,namespace=$10,pod_name=$11 value=$12;"

#print Dumper \%variables;
#my @keys = keys %variables;
#print Dumper \@keys;
         #print $line;

#my @test = grep { $_ =~ /container_cpu_usage_seconds_total/ } $response_body;
#print Dumper \@test;

#my @response_body_filtered = grep { $_ =~ /container_cpu_usage_seconds_total/ } @lines;
#print Dumper \@response_body_filtered;
#print Dumper \@lines;
