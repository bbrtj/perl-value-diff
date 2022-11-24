package Value::Diff;

use v5.10;
use strict;
use warnings;

use Exporter qw(import);
use Carp qw(croak);

our @EXPORT = qw(diff);

my $no_diff = \'no_diff';

sub _diff_hash
{
	my ($left, $right) = @_;

	my %out;
	for my ($key, $value) (%{$left}) {
		$out{$key} = $value
			unless exists $right->{$key};

		my $diff = _diff($value, $right->{$key});
		$out{$key} = $diff
			unless $diff eq $no_diff;
	}

	return %out ? \%out : $no_diff;
}

sub _diff_array
{
	my ($left, $right) = @_;

	my @out;
	my @other = @{$right};

	OUTER:
	for my $value (@{$left}) {
		for my $key (0 .. $#other) {
			my $other_value = $other[$key];
			if (_diff($value, $other_value) eq $no_diff) {
				splice @other, $key, 1;
				next OUTER;
			}
		}

		push @out, $value;
	}

	return @out ? \@out : $no_diff;
}

sub _diff
{
	my ($left, $right) = @_;

	my $ref_left = ref $left;
	my $ref_right = ref $right;
	return $left if $ref_left ne $ref_right;
	return _diff_array($left, $right) if $ref_left eq 'ARRAY';
	return _diff_hash($left, $right) if $ref_left eq 'HASH';
	return _diff($$left, $$right) if $ref_left eq 'SCALAR';

	croak "cannot compare references to $ref_left"
		if length $ref_left;

	return $left
		if defined $left ne defined $right
		|| (defined $left && $left ne $right);

	return $no_diff;
}

sub diff
{
	my ($left, $right, $out) = @_;

	my $diff = _diff($left, $right);

	if ($diff eq $no_diff) {
		return !!0;
	}
	else {
		$$out = $diff;
		return !!1;
	}
}

