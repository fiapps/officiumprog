
use utf8;
use URI::Escape;
use HTML::FormatText;

# Test::Officium object
{
  package Test::Officium;

  # Get the html for the office.
  sub html {
    my $self = shift;

    return $self->{_html};
  }

  # Get a plain text version of the office.
  # This is useful for verifying that certain strings
  # do or don't appear in the text (e.g., no alleluia during
  # Lent, correct antiphon for a particular feast, etc.).
  sub text {
    my $self = shift;

    # If there's no cached data, convert to HTML to text.
    if (!exists($self->{_text})) {
      my $text = HTML::FormatText->format_string(
        $self->html(),
        leftmargin => 0, rightmargin => 1000000
        );
      # Remove accents of the kind used in Latin.
      $text =~ tr/áäéëíïóöúüýÿ/aaeeiioouuyy/;
      $self->{_text} = $text;
    }

    return $self->{_text};
  }

  # Create a new object representing the HTML generated for
  # a given office.
  # This takes named parameters which will be passed to the CGI.
  # Sample usage:
  #   $off1 = Test::Officium->new(
  #     command  => 'prayMatutinum',
  #     date1 => '10-2-2011'
  #     );
  sub new {
    my $class = shift;
    my %options = (
      command  => 'praySexta',
      date1    => '7-21-2011',
      lang2    => 'Latin',
      testmode => 'regular',
      version  => 'Rubrics 1960',
      votive   => '',
      @_
    );

    # build query string
    my @queryParams;
    while(($key, $value) = each(%options)) {
      # URI escape each key and value, and join them with '='
      push(@queryParams, ::uri_escape($key) . '=' . ::uri_escape($value));
    }
    my $query = join('&',@queryParams);
  
    # Run the CGI program and collect its output (assumed to be an HTTP reply).
    my $cgi = 'officiumprog/Pofficium.pl';
    # $PROGRAM_NAME should be the Perl interpreter---
    my $perl = defined($::PROGRAM_NAME) ? $PROGRAM_NAME : 'perl';
    my $cmd = "'$perl' '$cgi' '$query'";
    print "# Reading breviary data from '$cmd'\n";
    open(CGI, "-|:encoding(iso-8859-1)", $cmd) || die "Cannot run '$cgi'";
    my $output;
    while(<CGI>) {
      $output .= $_;
    }
    close(CGI);

    # Eliminate HTTP header, leaving the content (which should be HTML).
    # No-op if there are no header lines.
    $output =~ s/^([^\n]+\n)+\n+//;

    my $self = { _html => $output };
    bless $self, $class;
  }
}

# Return a true value to make require happy.
1;
