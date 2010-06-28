#!/usr/bin/perl -w

use strict;
use Module::Build;

my $build = Module::Build->new
  ( module_name    => 'ExtUtils::CppGuess',
    license        => 'perl',
    requires       => {
        'Capture::Tiny' => '0',
        'File::Basename' => '0',
    },
    add_to_cleanup => [ 't/module_build', 't/makemaker' ],
    );

$build->create_build_script;
