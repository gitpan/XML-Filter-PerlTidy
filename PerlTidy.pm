#$Id: PerlTidy.pm,v 1.2 2003/01/10 17:09:01 eric Exp $

package XML::Filter::PerlTidy;
use strict;

use Perl::Tidy;
use XML::Filter::BufferText;
use XML::SAX::ParserFactory;

use vars qw($VERSION @ISA);
@ISA = qw(XML::SAX::Base);
$VERSION = '0.01';

#############################
package XML::Filter::PerlTidy::EventBlocker;
use vars qw(@ISA);
@ISA = qw(XML::SAX::Base);

sub xml_decl       {}
sub start_document {}
sub end_document   {}

#############################
package XML::Filter::PerlTidy;

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $options = ($#_ == 0) ? shift : { @_ };

    $options->{tidy_element} ||= 'perl';
    $options->{tidy_argv}    ||= [ qw(-html -pre -se -nss -nsyn) ];

    my $self = $class->SUPER::new($options);
    return XML::Filter::BufferText->new( Handler => $self );
}
sub start_element
{
    my ($self, $el) = @_;
    if ($el->{Name} eq $self->{tidy_element}) {
        $self->{tidy} = 1;
    }
    else {
        $self->SUPER::start_element($el);
    }
}
sub end_element
{
    my ($self, $el) = @_;
    if ($self->{tidy}) {
        $self->{tidy} = 0;
    }
    else {
        return $self->SUPER::end_element($el);
    }
}
sub characters
{
    my ($self, $data) = @_;
    my $chars = $data->{Data};

    if ($self->{tidy}) {
        my $output;
        Perl::Tidy::perltidy (
            source      => \$chars,
            destination => \$output,
            argv        => $self->{tidy_argv},
        );
        my $event_blocker = XML::Filter::PerlTidy::EventBlocker->new(
            Handler => $self->get_handler
        );
        my $parser = XML::SAX::ParserFactory->parser(
            Handler => $event_blocker
        );
        $parser->parse_string(
            qq{<?xml version="1.0"?>}
          . $output
        );
    }
    else {
        $self->SUPER::characters({Data => $chars});
    }
}
#############################
1;
__END__

=head1 NAME

XML::Filter::PerlTidy - SAX filter through Perl::Tidy

=head1 SYNOPSIS

  my $h = SomeHandler->new;
  my $f = XML::Filter::PerlTidy->new( Handler => $h );
  my $p = SomeParser->new( Handler => $f );
  $p->parse;

=head1 DESCRIPTION

  my $filter = XML:Filter::PerlTidy->new(
                    Handler      => $some_handler,
                    tidy_element => 'perl',
                    tidy_argv    => [ qw(-html -pre -se -nss -nsyn) ],
               );


Create a new instance of the filter. As with any SAX filter, you must provide
a C<Handler> which will receive the filter's output.

C<tidy_element> is the name of the element in the XML element whose contents
should be filtered through Perl::Tidy. It default to B<perl>, meaning that
all character data within E<lt>perlE<gt> ... E<lt>/perlE<gt> containers will
be filtered.

C<tidy_argv> an anonymous array of options that are passed to Perl::Tidy's
C<perltidy> function. It defaults to B<[ qw(-html -pre -se -nss -nsyn) ]>.
XML::Filter::PerlTidy will work only if Perl::Tidy's output is
valid XML, with all data included in a single root element. Therefore
it is advised to provide at least the B<'-html -pre'> options.

XML::Filter::PerlTidy automatically calls XML::Filter::BufferText to
coalesce character data so that a complete element is fed to PerlTidy.


=head1 AUTHOR

Eric Cholet

=head1 CREDITS

Robin Berjon for taking the time to teach me SAX basics.

=head1 SEE ALSO

L<Perl::Tidy>
L<XML::SAX>

=head1 COPYRIGHT

The XML::Filter::PerlTidy module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
