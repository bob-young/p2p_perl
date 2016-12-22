#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Cwd;
print "User_Data:\n";
my $CWD=Cwd::cwd();
my $db=$CWD."/DBfile.txt";

open DB ,"<$db" or die("can not open $db");
my $counter=0;
while(<DB>){
	$counter++;
	chomp($_);
	if($counter%3==1){
		print "USER_ID:",$_,"\t";
		}
	if($counter%3==2){
		print "PASSWORD:",$_,"\t";
		}
	if($counter%3==0){
		print "PHONE_NUMBER:",$_,"\n";
		}
	}
close DB;
