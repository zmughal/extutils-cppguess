#!/usr/bin/perl -w

use strict;
use blib '../..';
use ExtUtils::MakeMaker;
use ExtUtils::CppGuess;

my $guess = ExtUtils::CppGuess->new;
$guess->add_extra_compiler_flags(
  '-DINCLUDE_DOT=' .
  ($guess->iostream_fname =~ /\./ ? 1 : 0)
);

WriteMakefile
  ( NAME            => 'CppGuessTest',
    VERSION_FROM    => 'lib/CppGuessTest.pm',
    PL_FILES        => {},
    $guess->makemaker_options,
    );
