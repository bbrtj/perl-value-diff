use v5.10;
use strict;
use warnings;

use Test::More;
use Value::Diff;

subtest 'testing mixed - no diff' => sub {
	ok !diff({a => [1, 2, 3], b => \42, c => undef}, {a => [1, 2, 3], b => \42, c => undef}), 'mixed ok';
};

subtest 'testing mixed - diff' => sub {
	my $out;

	ok diff({a => [1, 2, 3], b => \42, c => undef}, {a => [1, 3], b => \42, c => undef}, \$out), 'mixed ok';
	is_deeply $out, {a => [2]}, 'diff ok';
};

done_testing;

