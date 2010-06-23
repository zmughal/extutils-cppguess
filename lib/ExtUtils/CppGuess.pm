package ExtUtils::CppGuess;

use strict;
use warnings;

=head1 NAME

ExtUtils::CppGuess - guess C++ compiler and flags

=head1 SYNOPSIS

With L<Extutils::MakeMaker>:

    use ExtUtils::CppGuess;
    
    my $guess = ExtUtils::CppGuess->new;
    
    WriteMakefile
      ( # MakeMaker args,
        $guess->makemaker_options,
        );

With L<Module::Build>:

    my $guess = ExtUtils::CppGuess->new;
    
    my $build = Module::Build->new
      ( # Module::Build arguments
        $guess->module_build_options,
        );
    $build->create_build_script;

=head1 DESCRIPTION

C<ExtUtils::CppGuess> attempts to guess the system's C++ compiler
that is compatible with the C compiler that your perl was built with.

It can generate the necessary options to the L<Module::Build>
constructor or to L<ExtUtils::MakeMaker>'s C<WriteMakefile>
function.

=head1 METHODS

=head2 new

Creates a new C<ExtUtils::CppGuess> object.
Takes the path to the C compiler as the C<cc> argument,
but falls back to the value of C<$Config{cc}>, which should
be what you want anyway.

You can specify C<extra_compiler_flags> and C<extra_linker_flags>
(as strings) which will be merged in with the auto-detected ones.

=head2 module_build_options

Returns the correct options to the constructor of C<Module::Build>.
These are:

    extra_compiler_flags
    extra_linker_flags

=head2 makemaker_options

Returns the correct options to the C<WriteMakefile> function of
C<ExtUtils::MakeMaker>.
These are:

    CCFLAGS
    dynamic_lib => { OTHERLDFLAGS => ... }

If you specify the extra compiler or linker flags in the
constructor, they'll be merged into C<CCFLAGS> or
C<OTHERLDFLAGS> respectively.

=cut

use Config ();
use File::Basename qw();
use Capture::Tiny 'capture_merged';

our $VERSION = '0.01';

sub new {
    my( $class, %args ) = @_;
    my $self = bless {
      cc => $Config::Config{cc},
      %args
    }, $class;

    return $self;
}

sub guess_compiler {
    my( $self ) = @_;
    return $self->{guess} if $self->{guess};

    if( $^O =~ /^mswin/i ) {
        $self->_guess_win32() or return();
    } else {
        $self->_guess_unix() or return();
    }

    if (defined $self->{extra_compiler_flags}) {
        $self->{guess}{extra_cflags} .= ' ' . $self->{extra_compiler_flags};
    }

    if (defined $self->{extra_linker_flags}) {
        $self->{guess}{extra_lflags} .= ' ' . $self->{extra_linker_flags};
    }

    return $self->{guess};
}

sub makemaker_options {
    my( $self ) = @_;
    $self->guess_compiler || die;

    return ( CCFLAGS      => $self->{guess}{extra_cflags},
             dynamic_lib  => { OTHERLDFLAGS => $self->{guess}{extra_lflags} },
             );
}

sub module_build_options {
    my( $self ) = @_;
    $self->guess_compiler || die;

    return ( extra_compiler_flags => $self->{guess}{extra_cflags},
             extra_linker_flags   => $self->{guess}{extra_lflags},
             );
}

sub _guess_win32 {
    my( $self ) = @_;
    my $c_compiler = $self->{cc};
    $c_compiler = $Config::Config{cc} if not defined $c_compiler;

    if( _cc_is_gcc( $c_compiler ) ) {
        $self->{guess} = { extra_cflags => ' -xc++ ',
                           extra_lflags => ' -lstdc++ ',
                           };
    } elsif( _cc_is_msvc( $c_compiler ) ) {
        $self->{guess} = { extra_cflags => ' -TP -EHsc ',
                           extra_lflags => ' msvcprt.lib ',
                           };
    } else {
        die "Unable to determine a C++ compiler for '$c_compiler'";
    }

    return 1;
}

sub _guess_unix {
    my( $self ) = @_;
    my $c_compiler = $self->{cc};
    $c_compiler = $Config::Config{cc} if not defined $c_compiler;

    if( !_cc_is_gcc( $c_compiler ) ) {
        die "Unable to determine a C++ compiler for '$c_compiler'";
    }

    $self->{guess} = { extra_cflags => ' -xc++ ',
                       extra_lflags => ' -lstdc++ ',
                       };
    return 1;
}

# originally from Alien::wxWidgets::Utility

my $quotes = $^O =~ /MSWin32/ ? '"' : "'";

sub _capture {
    my @cmd = @_;
    my $out = capture_merged {
        system(@cmd);
    };
    $out = '' if not defined $out;
    return $out;
}

sub _cc_is_msvc {
    my( $cc ) = @_;

    return $^O =~ /MSWin32/ and File::Basename::basename( $cc ) =~ /^cl/i;
}

sub _cc_is_gcc {
    my( $cc ) = @_;

    my $cc_version = _capture( "$cc --version" );
    if ($cc_version =~ m/\bg(?:cc|\+\+)/i) { # 3.x, some 4.x
      return 1;
    }
    elsif (scalar( _capture( "$cc" ) =~ m/\bgcc\b/i )) { # 2.95
      return 1;
    }
    elsif ($cc_version =~ m/\bcc\b.*Free Software Foundation/si) { # some 4.x?
      return 1;
    }

    return 0;
}

1;
