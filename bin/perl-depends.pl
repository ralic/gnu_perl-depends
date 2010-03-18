#!/usr/bin/perl
#
#   perl-depends.pl -- Roughly find out module depends from perl file(s)
#
#   Copyright information
#
#       Copyright (C) 2009-2010 Jari Aalto
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.


# ****************************************************************************
#
#   Standard perl modules
#
# ****************************************************************************

use strict;

use autouse 'Pod::Text'     => qw( pod2text );
use autouse 'Pod::Html'     => qw( pod2html );

use English qw( -no_match_vars );
use Getopt::Long;
use File::Basename;

# ****************************************************************************
#
#   GLOBALS
#
# ****************************************************************************

use vars qw ( $VERSION );

#   This is for use of Makefile.PL and ExtUtils::MakeMaker
#
#   The following variable is updated by custom Emacs setup whenever
#   this file is saved.

my $VERSION = '2010.0318.0919';

my $inject = << 'EOF';

# ****************************************************************************
#
#   DESCRIPTION
#
#	By Jari Aalto <jari.aalto@cante.net>
#
#       The inject code instrumented into perl files. The idea is to
#       examine %INC for all loaded modules that aren't in the standard
#       Perl installation list Module::CoreList
#
#       The results are a crude approximation: paths are simply converted
#       into module '::' notation. The reader's job is to examine the listing.
#
#	An example: the external module depends here is 'Regexp::Common'
#	and the rest of them can be ignored.
#
#		Regexp::Common                 Regexp/Common.pm
#		Regexp::Common::CC             Regexp/Common/CC.pm
#		...
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ****************************************************************************

sub __print_depends ()
{
    my @files = sort grep !/5.10|^[\w.]+$/, split ' ', join ' ', %INC;

    eval "use Module::CoreList";

    my $header;
    my %hash;

    for my $lib ( @files )
    {
        print "# MODULE DPENDENCY LIST\n" unless $header++;

	next if $lib =~ m,^/tmp/,;	#  /tmp/tLSYhLFqhj/

	my $name = $lib;
	$name =~ s,/usr/share/perl5/,,;
	$name =~ s/\..*//;		# *.pm
	$name =~ s,/,::,g;		# Regexp/Common => Regexp::Common

	my @a = Module::CoreList->find_modules(qr/$name/);

	next if @a;

        $hash{$name} = $lib;		# Filter duplicates
    }

    for my $key ( sort keys %hash )
    {
	printf "%-30s %s\n", $key, $hash{$key};
    }
}
EOF

my $end = << 'EOF';

END
{
    __print_depends();
}
EOF


# ****************************************************************************
#
#   DESCRIPTION
#
#       Set global variables for the program
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ****************************************************************************

sub Initialize ()
{
    use vars qw
    (
        $LIB
        $PROGNAME
        $CONTACT
	$LICENSE
        $URL
    );

    $LICENSE	= "GPL-2+";
    $LIB        = basename $PROGRAM_NAME;
    $PROGNAME   = $LIB;

    $CONTACT     = "Jari Aalto";
    $URL         = "http://freshmeat.net/projects/perl-depends";

    $OUTPUT_AUTOFLUSH = 1;
}


# ****************************************************************************
#
#   DESCRIPTION
#
#       Help function and embedded POD documentation
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ****************************************************************************

=pod

=head1 NAME

perl-depends - Roughly find out module depends from perl file(s)

=head1 SYNOPSIS

  perl-depends [options] FILE [FILE ...]

=head1 DESCRIPTION

Find out roughly the modules the program uses. This is based on the
idea, that Perl evaluates the C<use> commands at compile time and
stored the loaded module information into the I<%INC> variable. By
examining the loaded modules and comparing them against the standard
Perl modules, the extenal module dpendencies can be roughly estimated.

The original files need to be instrumented for this to work and the
modifications are stored in a temporary file.

In order to see the depends, user must run the instrumented files.
This is because, the program cannot know what possible options needs
to passed to the program to trigger "no behavior", that is, something
that doesn't actually run the program. Such options would be
--version, --dry-run, --generate-syntax-error-now etc.

An example of output: the external module depends here is 'Regexp::Common'
and the rest of them can be ignored.

    Regexp::Common                 Regexp/Common.pm
    Regexp::Common::CC             Regexp/Common/CC.pm
    ...

=head1 OPTIONS

=over 4

=item B<-e, --extension=EXT>

Use extension EXT for instrumented files. The defaul is C<.tmp>.

=item B<-h, --help>

Print text help

=item B<--help-exclude>

Print default exclude path value when B<--exclude-vcs> is used.

=item B<--help-html>

Print help in HTML format.

=item B<--help-man>

Print help in manual page C<man(1)> format.

=item B<-v, --verbose LEVEL>

Print informational messages. Increase numeric LEVEL for more
verbosity.

=item B<-V, --version>

Print contact and version information.

=back

=head1 EXAMPLES

Intrument a file, run it to see results and delete instrumentation:

    perl-depends file.pl
    perl file.pl.tmp --version
    rm *.tmp

=head1 TROUBLESHOOTING

None.

=head1 EXAMPLES

None.

=head1 ENVIRONMENT

None.

=head1 FILES

None.

=head1 SEE ALSO

cloc(1)

=head1 COREQUISITES

Uses standard Perl modules.

=head1 AVAILABILITY

Homepage is at http://freshmeat.net/projects/perl-depends

=head1 AUTHORS

Copyright (C) 2009-2010 Jari Aalto.

=head1 LICENSE

This program is free software; you can redistribute and/or modify
program under the terms of GNU General Public license either version 2
of the License, or (at your option) any later version.

=cut

sub Help (;$$)
{
    my $id   = "$LIB.Help";
    my $type = shift;  # optional arg, type
    my $msg  = shift;  # optional arg, why are we here...

    if ( $type eq -html )
    {
        pod2html $PROGRAM_NAME;
    }
    elsif ( $type eq -man )
    {
	eval "use Pod::Man;";
        $EVAL_ERROR  and  die "$id: Cannot generate Man: $EVAL_ERROR";

        my %options;
        $options{center} = 'cvs status - formatter';

        my $parser = Pod::Man->new(%options);
        $parser->parse_from_file ($PROGRAM_NAME);
    }
    else
    {
	if ( $^V =~ /5\.10/ )
	{
	    # Bug in 5.10. Cant use string ("") as a symbol ref
	    # while "strict refs" in use at
	    # /usr/share/perl/5.10/Pod/Text.pm line 249.

	    system("pod2text $PROGRAM_NAME");
	}
	else
	{
	    pod2text $PROGRAM_NAME;
	}
    }

    defined $msg  and  print $msg;
    exit 0;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Read command line arguments and their parameters.
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       Globally set options.
#
# ****************************************************************************

sub HandleCommandLineArgs ()
{
    my $id = "$LIB.HandleCommandLineArgs";

    use vars qw
    (
        $test
        $verb
        $debug
        $OPT_EXTENSION
        $OPT_FILE
    );

    Getopt::Long::config( qw
    (
        require_order
        no_ignore_case
        no_ignore_case_always
    ));

    my ( $help, $helpMan, $helpHtml, $version ); # local variables to function
    my ( $helpExclude, $excludeVcs , $optDir, $optVcs );

    $debug = -1;
    $OPT_EXTENSION = ".tmp";

    GetOptions      # Getopt::Long
    (
	  "debug"		=> \$optDir
	, "extesion=s"          => \$OPT_EXTENSION
	, "help-exclude"	=> \$helpExclude
	, "help-html"		=> \$helpHtml
	, "help-man"	        => \$helpMan
	, "h|help"	        => \$help
	, "v|verbose:i"	        => \$verb
	, "V|version"	        => \$version
    );

    $version		and  die "$VERSION $CONTACT $LICENSE $URL\n";
    $helpExclude 	and  HelpExclude();
    $help		and  Help();
    $helpMan		and  Help(-man);
    $helpHtml		and  Help(-html);
    $version		and  Version();

    $debug = 1          if $debug == 0;
    $debug = 0          if $debug < 0;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Main function
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       None
#
# ****************************************************************************

sub Main ()
{
    Initialize();
    HandleCommandLineArgs();

    for my $file (@ARGV)
    {
	my $dest = "$file$OPT_EXTENSION";
	system("cp $file $dest");

	if ( -f $dest )
	{
	    open FILE, "<", $dest or next;
	    $_ = join '', <FILE>;
	    close FILE;

	    if ( /^END.*?{(?<c>.*)}/sm  and  not $+{c} =~ /print_depends/ )
	    {
		s/^(END.*?{)(.*})/$1\n __print_depends;\n$2/;
	    }
	    else
	    {
		s/^(#.*)|^$/$1\n$end$inject/;

		open FILE, ">", $dest or next;
		print FILE;
		close FILE;
		print "perl $dest\n";
	    }
	}
    }
}

Main();

# End of file