use strict;
use warnings;
use Test::More;
use ExtUtils::CppGuess;

my $guess = ExtUtils::CppGuess->new;

plan skip_all => "Test currently only supports GCC and Clang"
	unless $guess->is_gcc || $guess->is_clang;

subtest "Test argument C++11" => sub {
	my $flag = eval {
		$guess->cpp_standard_flag('C++11');
	};
	if( $@ =~ /does not support any flags for standard/ ) {
		plan skip_all => "Skipping: $@";
	}
	like $flag, qr/\Q-std=c++\E(11|0x)/, 'correct flag';
};

subtest "Test non-C++ standard" => sub {
	my $flag = eval {
		# The flag `-std=c11` is a valid compiler flag,
		# but not for C++.
		$guess->cpp_standard_flag('C11');
	};
	ok $@ =~ /Unknown standard/, 'C11 is not a C++ standard';
};

done_testing;
