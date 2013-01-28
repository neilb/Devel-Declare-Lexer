#!/usr/bin/perl

package Devel::Declare::Lexer::t;

use strict;
use warnings;
#use Devel::Declare::Lexer qw/ :lexer_test /; # creates a lexer_test keyword and places lexed code into runtime $lexed
use Devel::Declare::Lexer qw/ :lexer_test lexer_test2 /; # creates a lexer_test keyword and places lexed code into runtime $lexed

use Devel::Declare::Lexer::Token;
use Devel::Declare::Lexer::Token::Comma;
use Devel::Declare::Lexer::Token::Declarator;
use Devel::Declare::Lexer::Token::EndOfStatement;
use Devel::Declare::Lexer::Token::LeftBracket;
use Devel::Declare::Lexer::Token::Newline;
use Devel::Declare::Lexer::Token::Operator;
use Devel::Declare::Lexer::Token::RightBracket;
use Devel::Declare::Lexer::Token::String;
use Devel::Declare::Lexer::Token::Variable;
use Devel::Declare::Lexer::Token::Whitespace;

use Test::More;

my $tests = 0;
my $lexed;

BEGIN {
    Devel::Declare::Lexer::lexed(lexer_test2 => sub {
        my ($stream_r) = @_;
        my @stream = @$stream_r;

        my $string = $stream[2]; # keyword [whitespace] "string"
        $string->{value} =~ tr/pi/do/;

        my @ns = ();
        tie @ns, "Devel::Declare::Lexer::Stream";

        push @ns, (
            new Devel::Declare::Lexer::Token::Declarator( value => 'lexer_test2' ),
            new Devel::Declare::Lexer::Token::Whitespace( value => ' ' ),
            new Devel::Declare::Lexer::Token( value => 'my' ),
            new Devel::Declare::Lexer::Token::Variable( value => '$lexer_test2'),
            new Devel::Declare::Lexer::Token::Whitespace( value => ' ' ),
            new Devel::Declare::Lexer::Token::Operator( value => '=' ),
            new Devel::Declare::Lexer::Token::Whitespace( value => ' ' ),
            $string,
            new Devel::Declare::Lexer::Token::EndOfStatement,
            new Devel::Declare::Lexer::Token::Newline,
        );

        return \@ns;
    });
}

lexer_test2 "pigs in blankets";
++$tests && is($lexer_test2, q|dogs on blankets|, 'Lexer callback');

lexer_test "this is a test";
++$tests && is($lexed, q|lexer_test "this is a test";|, 'Strings');

lexer_test "this", "is", "another", "test";
++$tests && is($lexed, q|lexer_test "this", "is", "another", "test";|, 'List of strings');

lexer_test { "this", "is", "a", "test" };
++$tests && is($lexed, q|lexer_test { "this", "is", "a", "test" };|, 'Hashref list of strings');

lexer_test ( "this", "is", "a", "test" );
++$tests && is($lexed, q|lexer_test ( "this", "is", "a", "test" );|, 'Array of strings');

my $a = 1;
lexer_test ( $a + $a );
++$tests && is($lexed, q|lexer_test ( $a + $a );|, 'Variables and operators');
lexer_test ( $a != $a );
++$tests && is($lexed, q|lexer_test ( $a != $a );|, 'Inequality operator');

my $longer_name = 1234;
lexer_test ( !$longer_name );
++$tests && is($lexed, q|lexer_test ( !$longer_name );|, 'Negative operator and complex variable names');
lexer_test ( \$longer_name );
++$tests && is($lexed, q|lexer_test ( \$longer_name );|, 'Referencing operator');

my $ln_ref = \$longer_name;
lexer_test ( $$ln_ref );
++$tests && is($lexed, q|lexer_test ( $$ln_ref );|, 'Dereferencing operator');

lexer_test q(this is a string);
++$tests && is($lexed, q|lexer_test q(this is a string);|, 'q quoting operator');

lexer_test q(this
is
a
multiline);
++$tests && is($lexed, q|lexer_test q(this
is
a
multiline);|, 'q quoting operator with multiline');

lexer_test ( {
    abc => 2,
    def => 4,
} );
++$tests && is($lexed, q|lexer_test ( {
    abc => 2,
    def => 4,
} );|, 'Hashref multiline');

++$tests && is(__LINE__, 107, 'Line numbering (CHECK WHICH LINE THIS IS ON)');

done_testing $tests;

#100 / 0;