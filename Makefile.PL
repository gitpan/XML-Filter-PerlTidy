#!/usr/bin/perl
# $Id: Makefile.PL,v 1.1 2003/01/07 21:03:40 eric Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'XML::Filter::PerlTidy',
    AUTHOR       => 'Eric Cholet <cholet@logilune.com>',
    ABSTRACT     => 'SAX filter character data through Perl::Tidy',
    VERSION_FROM => 'PerlTidy.pm',
    PM           => { 'PerlTidy.pm' => '$(INST_LIBDIR)/PerlTidy.pm' },
    PREREQ_PM    => { XML::SAX::Base => 0,
                      XML::Filter::BufferText => 0,
                      XML::SAX::Writer => 0,
                    },
    dist         => { COMPRESS => 'gzip -9f',
                      SUFFIX   => 'gz',
                    },
);
