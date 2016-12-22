#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Socket;

my $input = (<STDIN>);
chomp($input);
print $input,"\n";
&connect_to_server($input);
#&connect_to_server("quit");

sub connect_to_server{
	my $addr = $ARGV[0] || '127.0.0.1';
	my $port = $ARGV[1] || '3000';
	my $dest = sockaddr_in($port, inet_aton($addr));
	my $buf = undef;
	my $cmd=shift(@_);
	printf("$cmd");
	socket(SOCK,PF_INET,SOCK_STREAM,6) or die "Can't create socket: $!";
	connect(SOCK,$dest)                or die "Can't connect: $!";
	#send cmd
	print SOCK $cmd ;
	SOCK->autoflush(1);
	#receive ok
	my $bs = sysread(SOCK, $buf, 2048);
	print "Received $bs bytes, content $buf\n"; # actually get $bs bytes
	SOCK->autoflush(1);
	#send DATA
	my $Data=<STDIN>;
	chomp($Data);
	print SOCK $Data;
	SOCK->autoflush(1);
	#receive result
	$bs = sysread(SOCK,$buf,2048);
	SOCK->autoflush(1);
	print "\n result :$buf\n";
	close SOCK;
}


