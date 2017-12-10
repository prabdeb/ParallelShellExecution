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

# Time
package Local::Time;

# Module Usage
use strict;
use POSIX qw(strftime);

# Pre declarations of subroutines
sub thetime();
sub thetime_file();


# Subroutine thetime
sub thetime() {
	return(strftime("%Y%m%d %H:%M:%S",localtime()));
}

# Subroutine thetime_file
sub thetime_file() {
	return(strftime("%Y%m%d_%H%M%S",localtime()));
}

return 1;