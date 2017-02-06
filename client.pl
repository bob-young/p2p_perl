#!/usr/bin/perl -w
# tcp_socket_cli.pl

use Socket;
use Tk;
use Tk::LabFrame;
use Tk::LabEntry;
use Tk::DirTree;
use Tk::Table;
use Cwd;

#&connect_to_server();

 my $mw = MainWindow->new;
        $mw->geometry("400x200");
        $mw->title("P2P CLIENT");
        my $top_frame = $mw->Frame(-background => 'green')->pack(-side => 'top',-fill => 'x');
        my $bot_frame = $mw->LabFrame(-labelside => 'top')->pack(-side => 'bottom',-fill => 'x');
        my $top_label = $top_frame->LabFrame(-label => 'Welcome to use p2p file transmission',-labelside => 'acrosstop',-background => 'green')->pack();
        
        $mw->LabFrame(-label => 'Login',-labelside => 'top',-background => 'green')->pack();
        $bot_frame->Label(-text => "Create by Bob\t",-background => 'yellow')->pack(-side => 'right');
        $bot_frame->Label(-text => 'test 1.1',,-background => 'yellow')->pack(-side => 'left');
        my $n1=$mw->LabEntry(-label => "  account:",-labelPack =>[-side => 'left'],-background => 'white',-textvariable => \$name)->pack();
	my $n2=$mw->LabEntry(-label => "password:",-labelPack =>[-side => 'left'],-background => 'white',-textvariable => \$pwd)->pack();
        
        $mw->Button(-text => "Login", -command => \&Login)->pack();
        $mw->Button(-text => "Regist",-background => 'green', -command => \&Regist)->pack(-side => 'right');
        
        MainLoop;
        
sub Regist{
	our $reg= MainWindow->new;
	$reg->geometry("400x200");
        $reg->title("P2P CLIENT");
        my $top_regframe = $reg->Frame(-background => 'green')->pack(-side => 'top',-fill => 'x');
        my $reg_label = $top_regframe->LabFrame(-label => 'Welcome to regist p2p file transmission',-labelside => 'acrosstop',-background => 'green')->pack();
	$reg_label->Label(-text => "please input your information")->pack();
	our $nr1=$reg->LabEntry(-label => "  account:",-labelPack =>[-side => 'left'],-background => 'white',-textvariable => \$nv1)->pack();
	our $nr2=$reg->LabEntry(-label => "password:",-labelPack =>[-side => 'left'],-background => 'white',-textvariable => \$nv2)->pack();
	our $nr3=$reg->LabEntry(-label => "phone   #:",-labelPack =>[-side => 'left'],-background => 'white',-textvariable => \$nv3)->pack();
	$reg->Button(-text => "submit",-background => 'red',-command => \&reg_ok)->pack();
}

sub reg_ok{
	my $reg_name = $nr1->get();
	my $reg_pwd = $nr2->get();
	my $reg_tel = $nr3->get();
	print $reg_name,$reg_pwd,$reg_tel;
	my $reg_info=$reg_name."&".$reg_pwd."&".$reg_tel;
	my $flag=&connect_to_server("REG",$reg_info);
	if($flag==1){
		$reg->messageBox(-message => "regist success!\n you can login now!" ,-type => 'OK');
		#$reg->destory;
	}else{
		$reg->messageBox(-message => "regist failure!\n please use another name account!",-type => 'OK');
	}
}

sub Login{
	my $get_acc=$n1->get();
	chomp($get_acc);
	my $get_pwd=$n2->get();
	chomp($get_pwd);
	#
	if($get_acc eq "" || $get_pwd eq ""){
		
		$mw->messageBox(-message => "please input your ID and Password!", -type => "OK");
		$mw->destroy;
		&user_in($get_acc);
	}else{
		my $log_info=$get_acc."&".$get_pwd;
		my $flag=&connect_to_server("LOGIN",$log_info);
		chomp($flag);
		if($flag>0){
			#check password
			if($flag==2){
				#check ok
				$mw->destroy;
				&user_in($get_acc);
				
			}else{
				$mw->message(-message => "wrong password!",-type => "OK");
			}
		}else{
			$mw->messageBox(-message => "user do not exist!",-type => "OK");
		}
		
	}
}


sub user_in{
	our $ts=0;
	my $user=shift @_;
	our $CWD=Cwd::cwd();
	my $file_list=&connect_to_server("GETLIST","return a list");
	our @files = split /&/,$file_list;
	my $file_num = @files;
	our $mw1 = MainWindow->new;
        $mw1->geometry("600x400");
        $mw1->title("P2P CLIENT");
        my $top_frame = $mw1->Frame(-background => 'green')->pack(-side => 'top',-fill => 'x');
        my $bot_frame = $mw1->LabFrame(-labelside => 'top')->pack(-side => 'bottom',-fill => 'x');
        my $top_label = $top_frame->LabFrame(-label => 'Welcome to use p2p file transmission',-labelside => 'acrosstop',-background => 'green')->pack();
        
        $bot_frame->Label(-text => "Create by Bob\t",-background => 'yellow')->pack(-side => 'right');
        $bot_frame->Label(-text => 'test 1.1',,-background => 'yellow')->pack(-side => 'left');
        #top
        $top_label->LabFrame(-label => "Hello $user",-labelside => 'top',-background => 'green')->pack();
        #left
        my $l_frame=$mw1->LabFrame(-background => 'white',-labelside => 'right',-width => 150)->pack(-side => 'left',-fill => 'y');
        my $r_frame=$mw1->Frame(-background => 'white')->pack(-side => 'right',-ipadx => 200,-fill => 'y');
        #my $br_e=$l_frame->Button(-text => "sss",-command => \&show_path)->pack();
        #
        my $local_lab=$l_frame->Label(-text => "choose you path for down load:")->pack(-side => 'top');
        my $dir_label=$l_frame->Label(-text => "select:$CWD")->pack(-side => 'bottom');
        my $dir_tree=$l_frame->Scrolled(
					'DirTree',
					-scrollbars => "osoe",
					-width => 30,
					-height => 25,
					-exportselection => 1,
					-browsecmd => sub{$CWD=shift},
					-command => \&show_cwd)->pack(-fill => both,-expand => 1);
	#$dir_tree->chdir($CWD);
	#print $CWD;
	our $selected_path=$CWD;
	
        #right
        my $r_bottom=$r_frame->Label(-text => "ts:$ts")->pack(-side => 'bottom');
        my $n_label=$r_frame->Label(-text => "p2p files:")->pack(-side => 'top');
        my $table_frame=$r_frame->Table(-columns => 2,
					-rows => 8,
					-scrollbars => 'oe',
					-relief => 'raised',
					-width => 200,
					-height=>300,
					);
	my @d_button;
	my @d_label;
	#---download list
	for(0..($file_num-1)){
		my $tmp=$_;
		$d_label[$_]=$table_frame->Label(-text => "file # $files[$_]",-anchor => 'w',-relief => "groove");
		$d_button[$_]=$table_frame->Button(-text => "Download$_",-command => sub{download($d_button[$tmp])});
		
		$table_frame->put($_,1,$d_label[$_]);
		$table_frame->put($_,2,$d_button[$_]);
		}
        $table_frame->pack(-side => 'right');
        
        #$mw->Button(-text => "Login", -command => \&Login)->pack();
        MainLoop;
}

sub download{
	$ts++;
	my $event_source;
	foreach (@_){
		#print ($_->configure(-text));
		my @tm=($_->configure(-text));
		#print $tm[0]."1\t";
		#print $tm[1]."2\t";
		#print $tm[2]."3\t";
		#print $tm[3]."4\t";
		$tm[4] eq "";
		$event_source = $tm[4];
		print $event_source;
		our $f_n=$files[substr($event_source,8)];
		}
	print $CWD;
	my $yesno_button=$mw1->messageBox(-message => "Download $f_n to $CWD", -type => "yesno",-icon => "question");
	if($yesno_button eq "Yes"){
		$mw1->messageBox(-message => "Downloading", -type => "ok");
		}else{
		$mw1->messageBox(-message => "Ok, Exiting.", -type => "ok");
	}
	
}

sub show_path{
	print $CWD;
}

sub show_cwd {
  $mw1->messageBox(-message => "Directory Selected: $CWD", -type => "ok");
  print $CWD;
}

#client command LOGIN REG GETLIST GETFILE quit
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
	my $Data=shift @_;
	chomp($Data);
	print SOCK $Data;
	SOCK->autoflush(1);
	#receive result
	$bs = sysread(SOCK,$buf,2048);
	SOCK->autoflush(1);
	print "\n result :$buf\n";
	close SOCK;
	chomp($buf);
	return $buf;
}

