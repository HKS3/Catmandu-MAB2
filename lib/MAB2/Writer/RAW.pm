package MAB2::Writer::RAW;

# ABSTRACT: MAB2 RAW format serializer
# VERSION

use strict;
use Moo;
with 'MAB2::Writer::Handle';

use charnames ':full';
use Readonly;
Readonly my $SUBFIELD_INDICATOR => qq{\N{INFORMATION SEPARATOR ONE}};
Readonly my $END_OF_FIELD       => qq{\N{INFORMATION SEPARATOR TWO}};
Readonly my $END_OF_RECORD      => qq{\N{INFORMATION SEPARATOR THREE}\N{LINE FEED}};

=head1 SYNOPSIS

L<MAB2::Writer::RAW> is a MAB2 serializer.

    use MAB2::Writer::RAW;

    my @mab_records = (

        [
          ['001', ' ', '_', '2415107-5'],
          ['331', ' ', '_', 'Code4Lib journal'],
          ['655', 'e', 'u', 'http://journal.code4lib.org/', 'z', 'kostenfrei'],
          ...
        ],
        {
          record => [
              ['001', ' ', '_', '2415107-5'],
              ['331', ' ', '_', 'Code4Lib journal'],
              ['655', 'e', 'u', 'http://journal.code4lib.org/', 'z', 'kostenfrei'],
              ...
          ]
        }
    );

    $writer = MAB2::Writer::RAW->new( fh => $fh );

    foreach my $record (@mab_records) {
        $writer->write($record);
    }


=head1 Arguments

See L<MAB2::Writer::Handle>.

=head1 METHODS
  
=head2 new(file => $file | fh => $fh [, encoding => 'UTF-8'])

=head2 _write_record($record)

=cut

sub _write_record {
    my ( $self, $record ) = @_;
    my $fh = $self->fh;

    if ( $record->[0][0] eq 'LDR' ) {
        my $leader = shift( @{$record} );
        print $fh "$leader";
    }
    else {
        # set default record leader
        print $fh "99999nM2.01200024      h";
    }

    foreach my $field (@$record) {

        if ( $field->[2] eq '_' ) {
            print $fh $field->[0], $field->[1], $field->[3], $END_OF_FIELD;
        }
        else {
            print $fh $field->[0], $field->[1];
            for ( my $i = 2; $i < scalar @$field; $i += 2 ) {
                my $subfield_code = $field->[ $i ];
                my $value = $field->[ $i + 1 ];
                print $fh $SUBFIELD_INDICATOR, $subfield_code, $value;
            }
            print $fh $END_OF_FIELD;
        }
    }
    print $fh $END_OF_RECORD;
}

=head1 SEEALSO

L<MAB2::Writer::Handle>, L<Catmandu::Exporter>.

=cut

1;
