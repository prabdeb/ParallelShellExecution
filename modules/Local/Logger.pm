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

# Logger
package Local::Logger;

# Module Usage
use strict;

# Pre declarations of subroutines
sub new($);
sub write;
sub writeneol;

# Subroutine new
sub new($) {
	my $self = {};
	shift;
	$self->{logfile} = shift;
	bless($self);
	return($self);
}

# Subroutine write
sub write {
	my $self = shift;
	if ( open(LOG,">>$self->{logfile}") ) {
		foreach my $line (@_) {
			if ( $line =~ m/\n$/ ) {
				print LOG ($line);
			} else {
				print LOG ($line . "\n");
			}
		}
		close(LOG);
		return(1);
	}
	return;
}

# Subroutine writeneol
sub writeneol {
	my $self = shift;
	if ( open(LOG,">>$self->{logfile}") ) {
		foreach my $line (@_) {
			print LOG ($line);
		}
		close(LOG);
		return(1);
	}
	return;
}

return 1;