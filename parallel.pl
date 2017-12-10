#!/usr/bin/env perl
# ---------------------------------------------------------------------------
#
# --------------------------------PURPOSE------------------------------------
#
# parallel.pl : For executing Linux Commands in Parallel
# using Parallel::ForkManager
#
# -------------------------HISTORY OF DEVELOPMENT----------------------------
#
# Current Version 1.0.0
#
# v1.0.0 (07/08/2015, prbldeb)
#  original implementation
#
# ---------------------------------------------------------------------------

# Add modules directory to @INC
BEGIN {
    my $eeModulepath = ( $0 =~ m/^(.*)\// )[0] . "/modules";
    my $cpanModulepath = ( $0 =~ m/^(.*)\// )[0] . "/modules/CPAN";
	push(@INC, $eeModulepath);
	push(@INC, $cpanModulepath);
}

# Flush Log
$| = 1;

# Module Usage
use strict;
use Local::Logger;
use Local::ResultManager;
use Local::Time;
use Parallel::ForkManager;
use POSIX qw(strftime);
use File::Path;

# Record start time of build
my $starttime = time();

# Create Result Manager Object
my $result = Local::ResultManager::new();
$result->toggleecho();

# Maximum parallel process
my $max_process = 5;

# Default Timeout, 0 means no timeout
my $time_out = 0;

# Check command line options
my $logspace = `pwd`;
chomp($logspace);
my $newMaxProcess;
my $commandFile;
my $commandsList;
if ( @ARGV != 0 ) {
	while (( @ARGV != 0 ) and ( $ARGV[0] =~ m/^-/ )) {
		if ( $ARGV[0] =~ m/l/ ) {
            $logspace = $ARGV[1];
			shift(@ARGV);
			shift(@ARGV);
			next;
	    } elsif ( $ARGV[0] =~ m/m/ ) {
            $newMaxProcess = $ARGV[1];
			shift(@ARGV);
			shift(@ARGV);
			next;
        } elsif ( $ARGV[0] =~ m/f/ ) {
            $commandFile = $ARGV[1];
			shift(@ARGV);
			shift(@ARGV);
			next;
        } elsif ( $ARGV[0] =~ m/c/ ) {
            $commandsList = $ARGV[1];
			shift(@ARGV);
			shift(@ARGV);
			next;
        } elsif ( $ARGV[0] =~ m/t/ ) {
			$time_out = $ARGV[1];
			shift(@ARGV);
			shift(@ARGV);
			next;
        } else {
			print "WARNING: Invalid Option " . $ARGV[1];
			shift(@ARGV);
			shift(@ARGV);
			next;
		}
	}
} else {
	print "ERROR: Invalid command line options - Check below Usage\n\n";
	print "USAGE:   $0 -l [Log Directory] -f [File Containing All Commands] -c [Commands Seprated by (,)]\n\n\n";
	print "            -l   :   Log Directory where all logs will be dumped, default $logspace\n\n";
	print "            -f   :   File Containing All Commands, separated by new line,\n";
	print "                     to provide unique log file name to command, appaned -> commandLogFileName end of each command,\n";
	print "                     else it will create the log with command sequence number\n\n";
	print "            -c   :   Provide all the commands separated by (,) useful in case of few small commands\n\n";
	print "            -m   :   Maximum Number of Process, which should be executed parallel, default and highest: $max_process\n\n";
	print "            -t   :   Specify Timeout in second, example 1800 for 30 Mintues, default: $time_out\n\n";
	exit (1);
}

# Validate Inputs
if (!-d $logspace) {
	File::Path::mkpath $logspace or die ("ERROR: Can not create $logspace, permission denied"); 
}
unless ( (($commandFile) && (-r $commandFile)) || ($commandsList) ) {
	die ("ERROR: A command file containing all the commands or a list of commands separated by (,) is mandatory, check usgae with $0 -h\n");
}
if ( ($commandFile) && ($commandsList) ) {
	die ("ERROR: Both Command file and Command list must not be provided, you can choose only one option\n"); 
}
if ($newMaxProcess) {
	if ($newMaxProcess <= $max_process) {
		$max_process = $newMaxProcess;
	} elsif ($newMaxProcess > $max_process) {
		print "WARNING: You have given -m $newMaxProcess more than default $max_process, which is not allowed, considering the default value\n";
	}
}

# Get all Commands
my @commands;
if ($commandFile) {
	open(FILE, $commandFile) or die ("ERROR: Can not read $commandFile, permission denied\n");
	@commands = <FILE>;
	chomp(@commands);
	close(FILE);
} elsif ($commandsList) {
	@commands = split(",", $commandsList);
}

# Initiate Complete Log Creation
my $completeLogFile = $logspace . "/completeLog_" . Local::Time::thetime_file . ".txt"; 
my $logger = Local::Logger->new($completeLogFile);
$result->appendlog("Starting Parallel Execution of Commands below with Maximum Parallel Process of $max_process -");
foreach my $cmd (@commands) {
	$result->appendlog($cmd);
}
$result->appendlog("=================== START EXECUTION =======================");
$logger->write($result->fetchalllog());
$result->clearlogs();

# Start Parallel Execution
my $pm = new Parallel::ForkManager($max_process);
my @all_signals;
$pm->run_on_finish(
    sub { my ($pid, $exit_code, $ident) = @_;
        push(@all_signals,"${ident}:${exit_code}");
    }
);
my $index = 0;
foreach my $cmd (@commands) {
	$index++;
	$pm->start($cmd) and next;
	chomp($cmd);
	my $commandLogFile;
	if ($cmd =~ /->/) {
		my @tmpCmd = split("->", $cmd);
		$commandLogFile = pop(@tmpCmd);
		$commandLogFile =~ s/\s+//g;
		$cmd = join("->", @tmpCmd);
	} else {
		$commandLogFile = "cmd_${index}";
	}
    $commandLogFile = $logspace . "/" . $commandLogFile . "_log.txt";
    my $commandLogger = Local::Logger->new($commandLogFile);
    $result->appendlog("Executing " . $cmd);
	my $pid = open(PIPE, "$cmd 2>&1 |") or sub {
		$result->appenderrorlog($!);
		$result->appenderrorlog("[PIPE OPEN ERROR] Failed to execute " . $cmd);
		$result->appendlog("-"); $commandLogger->write($result->fetchalllog());
		$logger->write($result->fetchalllog());
		$result->clearlogs();
		$pm->finish(4)
	};
	eval {
		local $SIG{ALRM} = sub { die "TIMEDOUT\n" };
		alarm($time_out);
		while (<PIPE>) {
			$result->appendlog($_);
		}
		close(PIPE);
		unless ( $? == 0 ) {
			$result->appenderrorlog("[EXIT CODE $?] Failed to execute " . $cmd);
			$result->appendlog("-");
			$commandLogger->write($result->fetchalllog());
			$logger->write($result->fetchalllog());
        	$result->clearlogs();
			alarm(0);
			$pm->finish(1);
		}
		$result->appendlog("Successfully executed $cmd");
		$result->appendlog("-");
		$commandLogger->write($result->fetchalllog());
		$logger->write($result->fetchalllog());
		$result->clearlogs();
		alarm(0);
		$pm->finish(0);
	};
	if ($@) {
		if ($@ eq "TIMEDOUT\n") {
			kill 9, $pid;
			close(PIPE);
			$result->appenderrorlog("[TIMEDOUT] Failed to execute " . $cmd);
			$result->appendlog("-");
			$commandLogger->write($result->fetchalllog());
			$logger->write($result->fetchalllog());
        	$result->clearlogs();
			alarm(0);
			$pm->finish(2);
		} else {
			$result->appenderrorlog($@);
			$result->appenderrorlog("[UNEXPECTED ERROR] Failed to execute " . $cmd);
			$result->appendlog("-");
			$commandLogger->write($result->fetchalllog());
			$logger->write($result->fetchalllog());
        	$result->clearlogs();
			alarm(0);
			$pm->finish(3);
		}
	}
}
$pm->wait_all_children;
$result->appendlog("=================== FAILURE SUMMARY =======================");
my $exit_status = 0;
foreach my $line (@all_signals) {
	my @tmpCmd = split (":", $line);
	my $exit_code = pop(@tmpCmd);
	my $cmd = join(":", @tmpCmd);
    if ( $exit_code != 0 ) {
		$result->appenderrorlog("Failed to execute " . $cmd) if ( $exit_code == 1 );
		$result->appenderrorlog("[TIMEDOUT] Failed to execute " . $cmd) if ( $exit_code == 2 );
		$result->appenderrorlog("[UNEXPECTED ERROR] Failed to execute " . $cmd) if ( $exit_code == 3 );
		$result->appenderrorlog("[PIPE OPEN ERROR] Failed to execute " . $cmd) if ( $exit_code == 4 );
		$logger->write($result->fetchalllog());
		$result->clearlogs();
		$exit_status =1;
	}
}
$result->appendlog("=================== EXIT DICISSION ========================");
if ( $exit_status == 1 ) {
	$result->appenderrorlog("Failed to Executed any of Parallel Commands, Check the individual Log for details");
    $logger->write($result->fetchalllog());
	exit(1);
} else {
	$result->appendlog("Successfully executed All the Commands");
	$logger->write($result->fetchalllog());
	exit(0);
}