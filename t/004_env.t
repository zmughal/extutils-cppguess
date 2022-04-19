use strict;
use warnings;
use Test::More;

@ENV{qw(CXX CXXFLAGS CXXLDFLAGS)} = qw(czz flag ldflag);
my $MODULE = 'ExtUtils::CppGuess';
use_ok($MODULE);

my $guess = $MODULE->new;
isa_ok $guess, $MODULE;

diag 'EUMM env:', explain { $guess->makemaker_options };

like $guess->compiler_command, qr/czz.*flag/;
is $guess->linker_flags, 'ldflag';

done_testing;
