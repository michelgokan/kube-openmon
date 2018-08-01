#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(time);
use WWW::Curl::Easy;   
use MIME::Base64 ();
use Proc::Daemon;

my $GLOBAL_TIMESTAMP;
my $KUBERNETES_TOKEN;
my $KUBERNETES_ADDRESS;
my $KUBERNETES_PORT;
my $LOG_LEVEL=1;

sub validateEnvironmentVariables{
   if(!defined $ENV{'KUBERNETES_CUSTOM_TOKEN'}){
      my $filename = '/var/run/secrets/kubernetes.io/serviceaccount/token';

      open(my $fh, '<', $filename)
        or die "Could not open file '$filename' $! Are you sure you are in a Kubernetes environment?";

      my $token = <$fh>;
      
      if( $token ne "" ){
         $KUBERNETES_TOKEN = $token;
      } else {
         die("Kubernetes environment variables are not set correctly and couldn't find any token in /var/run/secrets/kubernetes.io/serviceaccount/token!");
      }
   } else{
      $KUBERNETES_TOKEN = $ENV{'KUBERNETES_CUSTOM_TOKEN'};
   }

   if(!defined $ENV{'KUBERNETES_CUSTOM_ADDRESS'}){
      if(!defined $ENV{'KUBERNETES_PORT_443_TCP_ADDR'}){
         die("Both KUBERNETES_ADDRESS and KUBERNETES_PORT_443_TCP_ADDR is not set! Are you sure you are in a Kubernetes environment?");
      } else{
         $KUBERNETES_ADDRESS = $ENV{'KUBERNETES_PORT_443_TCP_ADDR'};
      }
   } else{
      $KUBERNETES_ADDRESS = $ENV{'KUBERNETES_CUSTOM_ADDRESS'};
   }

   if(!defined $ENV{'KUBERNETES_CUSTOM_PORT'}){
      if(!defined $ENV{'KUBERNETES_PORT_443_TCP_PORT'}){
         die("Both KUBERNETES_PORT and KUBERNETES_PORT_443_TCP_PORT is not set! Are you sure you are in a Kubernetes environment?");
      } else{
         $KUBERNETES_PORT = $ENV{'KUBERNETES_PORT_443_TCP_PORT'};
      }
   } else{
         $KUBERNETES_PORT = $ENV{'KUBERNETES_CUSTOM_PORT'};
   }

   if(!defined $ENV{'INFLUXDB_ADDRESS'} || !defined $ENV{'INFLUXDB_PORT'} || !defined $ENV{'INFLUXDB_USERNAME'} || !defined $ENV{'INFLUXDB_PASSWORD'} || !defined $ENV{'INFLUXDB_DATABASE'}){
      die("InfluxDB environment variables are not set correctly!");
   }

   if(!defined $ENV{'NODE_NAME'}){
      die("\$NODE_NAME is not set!"); 
   }

   return 1;
}

sub printKubernetesEnvironmentVariables{
   print("\$KUBERNETES_TOKEN=$KUBERNETES_TOKEN\n\$KUBERNETES_ADDRESS=$KUBERNETES_ADDRESS\n\$KUBERNETES_PORT=$KUBERNETES_PORT\n");
}

sub getMetrics{
   my $curl = WWW::Curl::Easy->new;

   my @headers  = ("Authorization: Bearer $KUBERNETES_TOKEN");
   my $URL = "https://$KUBERNETES_ADDRESS:$KUBERNETES_PORT/api/v1/nodes/$ENV{'NODE_NAME'}/proxy/metrics/cadvisor";

   $curl->setopt(CURLOPT_HEADER,1);
   $curl->setopt(CURLOPT_HTTPHEADER, \@headers);
   $curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
   $curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);
   $curl->setopt(CURLOPT_URL, $URL);

   my $response_body;
   $curl->setopt(CURLOPT_WRITEDATA,\$response_body);


   my $retcode = $curl->perform;
   $GLOBAL_TIMESTAMP=sprintf("%.9f",time);
   $GLOBAL_TIMESTAMP=~s/\.//g;
      
   if ($retcode == 0) {
      if( $LOG_LEVEL > 0 ){
         print("Transfer went ok\n");
      }
      my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);

      if( $response_code != 200 ){
         die("Error with response code: $response_code\n");
      }
   } else {
      die("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
   }

   return $response_body;
}

sub generateQuery{
   my $response_body = $_[0];
   
   my $query = "";

   foreach my $line (split /\n/ ,$response_body) {
      for ($line) {
         if (/^([A-Za-z0-9_-]+?)\{(.*?)\}\s+(.*?)$/) {
            my $measurement = $1;
            my $val = sprintf("%.20g", $3);
            my $metadata = $2;
            $metadata =~ s/\s/_/g;
            $query .= "$measurement,node_name=$ENV{NODE_NAME},$metadata value=$val $GLOBAL_TIMESTAMP\n";
         } elsif(/^([A-Za-z0-9_-]+?)\s+(.*?)$/) {
            my $val = sprintf("%.20g", $2);
            $query .= "$1,node_name=$ENV{NODE_NAME} value=$val $GLOBAL_TIMESTAMP\n";
         }
      }
   }
   return $query;
}

sub pushToInfluxDB{
   my $query = $_[0];
   my $curl = WWW::Curl::Easy->new;
   my $URL = "http://$ENV{'INFLUXDB_ADDRESS'}:$ENV{'INFLUXDB_PORT'}/write?db=$ENV{'INFLUXDB_DATABASE'}";
   
   if( $ENV{'INFLUXDB_USERNAME'} ne "" && $ENV{'INFLUXDB_PASSWORD'} ne "" ){
      my @headers  = ("Authorization: Basic ".MIME::Base64::encode($ENV{'INFLUXDB_USERNAME'}.":".$ENV{'INFLUXDB_PASSWORD'}));
      $curl->setopt(CURLOPT_HTTPHEADER, \@headers);
   }

   $curl->setopt(CURLOPT_POST,1);
   $curl->setopt(CURLOPT_POSTFIELDS,$query);
   $curl->setopt(CURLOPT_HEADER,1);
   $curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
   $curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);
   $curl->setopt(CURLOPT_URL, $URL);

   my $response_body;
   $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

   my $retcode = $curl->perform;
   $GLOBAL_TIMESTAMP=sprintf("%.9f",time);
   $GLOBAL_TIMESTAMP=~s/\.//g;
      
   if ($retcode == 0) {
      if( $LOG_LEVEL > 0 ){
         print("Transfer went ok\n");
      }
      my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);

      if( $response_code != 200 || $response_code != 204 ){
         die("Error with response code: $response_code\n");
      }
   } else {
      die("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
   }

   return $response_body;
}

if( validateEnvironmentVariables() ){
   if( $LOG_LEVEL > 0 ){
      printKubernetesEnvironmentVariables();
   }

   my $response_body = getMetrics();
   my $query = generateQuery($response_body);

   if( $LOG_LEVEL > 0 ){
      open(my $fh, '>', 'query.log');
      print $fh $query;
      close $fh;
   }
   
   pushToInfluxDB($query);
}
