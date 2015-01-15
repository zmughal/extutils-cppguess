#!/usr/bin/perl -w

use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name    => 'ExtUtils::CppGuess',
    license        => 'perl',
    configure_requires => { 'Module::Build' => 0.42 },
    requires       => {
        'Capture::Tiny' => '0',
        'File::Basename' => '0',
    },
    build_requires  => {
        'Module::Build' => '0',
    },
    test_requires  => {
        'Capture::Tiny' => '0',
        'Module::Build' => '0',
        'ExtUtils::MakeMaker' => '0',
        'Test::More' => '0',
        'File::Spec' => '0',
        'ExtUtils::Manifest' => '0',
        'Fatal' => '0',
        'Cwd' => '0',
    },
    add_to_cleanup => [ 't/module_build', 't/makemaker' ],
    meta_merge => {
        resources => {
            repository => 'git://github.com/tsee/extutils-cppguess'
        }
    },
);

$build->create_build_script;
