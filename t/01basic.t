#!/usr/bin/perl
#
#$Id: 01basic.t,v 1.2 2003/01/10 17:09:01 eric Exp $

use strict;
use Test;

BEGIN { plan tests => 6 }

use XML::SAX::ParserFactory;
use XML::SAX::Writer;
use XML::Filter::BufferText;
use XML::Filter::PerlTidy;

my $output;
my $writer  = XML::SAX::Writer->new(Output => \$output);;
ok($writer);
my $filter1 = XML::Filter::BufferText->new(Handler => $writer);
ok($filter1);
my $filter2 = XML::Filter::PerlTidy->new(Handler => $filter1);
ok($filter2);
my $parser  = XML::SAX::ParserFactory->parser(Handler => $filter2);
ok($parser);

my $xmldecl = qq(<?xml version='1.0'?>);
$parser->parse_string($xmldecl . '<perl>#!/usr/bin/perl\n</perl>');
ok($output);
ok($output =~ /^\Q$xmldecl\E/);

__END__
