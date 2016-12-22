#!/usr/bin/perl -w

use strict;
use Socket;
use IO::Handle;
use POSIX qw(WNOHANG);
use Cwd;

our $CWD=Cwd::cwd();
my $port     = $ARGV[0] || '3000';
my $proto    = getprotobyname('tcp');
$SIG{'CHLD'} = sub {
     while((my $pid = waitpid(-1, WNOHANG)) >0) {
          print "Reaped child $pid\n";
      }
};
socket(SOCK, AF_INET, SOCK_STREAM, getprotobyname('tcp'))
    or die "socket() failed: $!";
setsockopt(SOCK,SOL_SOCKET,SO_REUSEADDR,1)
    or die "Can't set SO_REUSADDR: $!" ;
my $my_addr = sockaddr_in($port,INADDR_ANY);
bind(SOCK,$my_addr)    or die "bind() failed: $!";
listen(SOCK,SOMAXCONN) or die "listen() failed: $!";
warn "Starting server on port $port...\n";
while (1) {
     next unless my $remote_addr = accept(SESSION,SOCK);
     defined(my $pid=fork) or die "Can't fork: $!\n";

     if($pid==0) {
          my ($port,$hisaddr) = sockaddr_in($remote_addr);
          warn "Connection from [",inet_ntoa($hisaddr),",$port]\n";
          
          SESSION->autoflush(1);
          my $cmd;

          #print SESSION (my $s = localtime);
          #while(<SESSION>){
          #    print $_;
          #    if($_=~/^quit/i){
          #      close SESSION;
          #      exit 0;
          #      }
          #    }
          #receive cmd

          my $bs=sysread(SESSION,$cmd,2048);
          warn "Connection from [",inet_ntoa($hisaddr),",$port] .For msg:$cmd\n";
          SWITCH: {
            $cmd eq "LOGIN" && do { print "cmd=$cmd\n"; &Login;last SWITCH; };
            $cmd eq "REG" && do { print "cmd=$cmd\n"; &Reg;last SWITCH; };
            $cmd eq "GETLIST" && do { print "cmd=$cmd\n"; &GetList ;last SWITCH; };
            $cmd eq "GETFILE" && do {print "cmd=$cmd\n"; &Getfile;last SWITCH; };
            $cmd eq "UPLOAD" && do {print "cmd=$cmd\n";&Upload; last SWITCH; };
            print "$cmd is not a command";
            } 
          
          close SESSION;
          close SOCK;
          exit 0;
      }else {
          print "Forking child $pid\n";
      }
}
close SOCK;


sub GetList
{
          SESSION->autoflush(1);
          print "logging\n";
          #send ok
          print SESSION (my $s = localtime);
          SESSION->autoflush(1);
          #receive DATA
          my $buf;
          my $bs=sysread(SESSION,$buf,2048);
          SESSION->autoflush(1);
          my $share_dir=$CWD."/share";
          my @dir_file=<$share_dir/*>;
          foreach(@dir_file){
              $_=substr($_,length($share_dir));
              }
          my $list=join "&",@dir_file;
          #send result
              print SESSION $list;
          SESSION->autoflush(1);
}

sub Reg
{
          SESSION->autoflush(1);
          print "Register\n";
          #send ok
          print SESSION (my $s = localtime);
          SESSION->autoflush(1);
          #receive DATA
          my $buf;
          my $bs=sysread(SESSION,$buf,2048);
          SESSION->autoflush(1);
          my @info = split /&/ ,$buf;
          print $info[0],"\t",$info[1],"\t",$info[2];
          my $flag=&search($info[0],$info[1]);
          if($flag!=0){
              $flag=-1;
              }else{
              $flag=&add($info[0],$info[1],$info[2]);
            }
          SESSION->autoflush(1);
          print $flag,"is the flag\n";
          #send result
          print SESSION $flag;
          SESSION->autoflush(1);
}


sub Login
{
          SESSION->autoflush(1);
          print "logging\n";
          #send ok
          print SESSION (my $s = localtime);
          SESSION->autoflush(1);
          #receive DATA
          my $buf;
          my $bs=sysread(SESSION,$buf,2048);
          SESSION->autoflush(1);
          my @info = split /&/ ,$buf;
          print $info[0],"\n",$info[1];
          my $flag=&search($info[0],$info[1]);
          SESSION->autoflush(1);
          print $flag,"is the flag\n";
          #send result
              print SESSION $flag;
          SESSION->autoflush(1);
}


#find id & match return 2;
#find id & not match return 1;
#not find id 0;
sub search
{
        my $user=shift @_;
        chomp($user);
        my $pwd=shift @_;
        chomp($pwd);
        my $DBfile=$CWD."/DBfile.txt";
        print $DBfile;
        open DBF ,"<$DBfile" or die("can not open DB!\n");
        my $counter=0;
        my $find_flag=0;
        while(<DBF>){
            chomp($_);
            if($find_flag==1){
                if($pwd eq $_){
                    $find_flag=2;
                    last;
                    }else{
                        last;
                        }
                }
            if($counter%3==0){
                if($user eq $_){
                    $find_flag=1;
                    next;
                    }else{
                        next;
                    }
                }else{
                next;
                }
            }
        close DBF;
        return $find_flag;
}

sub Upload{

}

sub Getfile{

}

sub add
{
        my $user=shift @_;
        chomp($user);
        my $pwd=shift @_;
        chomp($pwd);
        my $tel=shift @_;
        chomp($tel);
        
        my $DBfile=$CWD."/DBfile.txt";
        print "in $DBfile $user\n";
        open DBF ,">>$DBfile" or die("can not open DB!\n");
        print DBF "$user\n";
        print DBF "$pwd\n";
        print DBF "$tel\n";
        close DBF;
        return 1;
}

