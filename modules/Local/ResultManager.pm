# ---------------------------------------------------------------------------
#
# --------------------------------PURPOSE------------------------------------
#
# Local::Logger is a package used for writing logs
#
# -------------------------HISTORY OF DEVELOPMENT----------------------------
#
# Current Version 1.0.0
#
# v1.0.0 (04/08/2015, prbldeb)
#  original implementation
#
# ---------------------------------------------------------------------------

# Result Manager
package Local::ResultManager;

# Settings
$echo = 0;

# Module Usage
use strict;
use vars qw( $echo );
use Local::Time;

# Pre declarations of subroutines
sub new();
sub appenderrorlog($);
sub appendlog($);
sub clearlogs();
sub fetchalllog();
sub status();
sub toggleecho();

# Subroutine new
sub new() {
	my $self = {};
	$self->{alllog} = "";
	$self->{errorlog} = "";
	$self->{log} = "";
	$self->{status} = 1;
	$self->{echo} = $echo;
	bless($self);
	return($self);
}

# Subroutine appenderrorlog
sub appenderrorlog($) {
	my $self = shift;
	my $input = shift;
	unless ( $input ) {
		return;
	}
	chomp($input);
	if ( $input =~ m/\n/ ) {
		my $timestamp = "\n" . Local::Time::thetime() . " - ";
		$input =~ s/\n/$timestamp/g;
	}
	$self->{alllog} .= Local::Time::thetime() . " - " . $input . "\n";
	$self->{errorlog} .= Local::Time::thetime() . " - " . $input . "\n";
	$self->{status} = 0;
	if ( $self->{echo} == 1 ) {
		print(Local::Time::thetime() . " - " . $input . "\n");
	}
}

# Subroutine appendlog
sub appendlog($) {
	my $self = shift;
	my $input = shift;
	unless ( $input ) {
		return;
	}
	chomp($input);
	if ( $input =~ m/\n/ ) {
		my $timestamp = "\n" . Local::Time::thetime() . " - ";
		$input =~ s/\n/$timestamp/g;
	}
	$self->{alllog} .= Local::Time::thetime() . " - " . $input . "\n";
	$self->{log} .= Local::Time::thetime() . " - " . $input . "\n";
	if ( $self->{echo} == 1 ) {
		print(Local::Time::thetime() . " - " . $input . "\n");
	}
}

# Subroutine clearlogs
sub clearlogs() {
	my $self = shift;
	$self->{alllog} = "";
	$self->{errorlog} = "";
	$self->{log} = "";
}

# Subroutine fetchalllog
sub fetchalllog() {
	my $self = shift;
	return($self->{alllog});
}

# Subroutine status
sub status() {
	my $self = shift;
	return($self->{status});
}

# Subroutine toggleecho
sub toggleecho() {
	my $self = shift;
	if ( $self->{echo} == 1 ) {
		$self->{echo} = 0;
	} else {
		$self->{echo} = 1;
	}
}

return 1;