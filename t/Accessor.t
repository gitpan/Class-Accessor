# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num;
BEGIN { $| = 1; $^W = 1; $test_num=1}
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use Class::Accessor;
$loaded = 1;
ok(1, 															'compile()'	);
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
sub ok {
	my($test, $name) = @_;
	print "not " unless $test;
	print "ok $test_num";
	print " - $name" if defined $name;
	print "\n";
	$test_num++;
}

sub eqarray  {
	my($a1, $a2) = @_;
	return 0 unless @$a1 == @$a2;
	my $ok = 1;
	for (0..$#{$a1}) { 
	    unless($a1->[$_] eq $a2->[$_]) {
		$ok = 0;
		last;
	    }
	}
	return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 9 }


# Set up a testing package.
package Foo;

use base qw(Class::Accessor);
use public 	qw( foo bar yar car );
use private qw( _har _Changed );


sub new {
	my $class = shift;
	no strict 'refs';
	return bless [\%{"$class\:\:FIELDS"}], $class;
}

sub car {
	shift->_car_accessor(@_);
}

package main;

my Foo $test = Foo->new;

# Test accessors.
$test->foo(42);
$test->bar('Meep');
ok( $test->foo 	 == 42 and
	$test->{foo} == 42, 								'accessor get/set'	);

ok( $test->_foo_accessor == 42,							'accessor alias'	);

$test->car("AMC Javalin");
ok( $test->car eq 'AMC Javalin' );

# Make sure bogus accessors die.
eval { $test->gargle() };
ok( $@,													'bad accessor()' 	);


# Test get()
my @vals = $test->get(qw(foo bar));
ok( eqarray(\@vals, [qw(42 Meep)]), 							'get()'		);

# Test that the accessor works properly in list context with a single arg.
my Foo $test2 = Foo->new;
my @args = ($test2->foo, $test2->bar);
ok( @args == 2,							'accessor get in list context'		);


# Test set()
$test->set('foo', 23);
ok( $test->foo == 23, 											'set()' 	);


# Make sure a DESTROY field won't slip through.
package Arrgh;
use base qw(Foo);
use public qw(DESTROY);


package main;

my Arrgh $arrgh = Arrgh->new;

eval {
	local $SIG{__WARN__} = sub { die @_ };
	$arrgh->DESTROY('this');
};

ok( $@ and $@ =~ /Having a public data field named DESTROY in 'Arrgh' which inherits from Class::Accessor/i,					'No DESTROY field'	);

# Override &Arrgh::DESTROY to shut up the warning we intentionally created
*Arrgh::DESTROY = sub {};
() = *Arrgh::DESTROY;  # shut up typo warning.
