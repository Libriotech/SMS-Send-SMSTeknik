package SMS::Send::SMSTeknik;

# use HTTP::Tiny;
use LWP::UserAgent;
use Modern::Perl;
use Data::Dumper;
use base 'SMS::Send::Driver';

our $VERSION = '0.01';

=pod

=head2 new()

C4::SMS calls new() like so:

        $sender = SMS::Send->new(
            $driver,
            _login    => C4::Context->preference('SMSSendUsername'),
            _password => C4::Context->preference('SMSSendPassword'),
            %args,
        );

%args comes from the YAML config file.

=cut

sub new {
    my ($class, @arg_arr) = @_;
#    my $args = {
#        _user   => "$arg_arr[1]",
#        _pass   => "$arg_arr[3]",
#        _id     => "$arg_arr[5]",
#        _sender => "$arg_arr[7]",
#    };
    my %args = @arg_arr;
    say Dumper %args;

    # FIXME Make this configurable
    my $protocol = "https";
    my $service = "xml";
    my $postURL = "/send/";
    my $postHOST = "api.smsteknik.se";

    die "$class needs hash_ref with _user and _pass and and _id and _sender.\n" unless $args{_user} && $args{_pass} && $args{_id} && $args{_sender};
    my $self = bless {%args}, $class;
    $self->{send_url} = $protocol . "://" . $postHOST . $postURL . $service  . "?id=" . $args{_id} . "&user=" . $args{_user} . "&pass=" . $args{_pass};
    $self->{_sender} = $args{_sender};
    # $self->{status_url} = 'http://sms-pro.net/services/' . $args->{_login} . '/status';
    return $self;
}

sub send_sms {

    my ($self, %args) = @_;
    my $xml_args = {
        message => "$args{'text'}",
        to      => "$args{'to'}",
        sender  => "$self->{_sender}"
    };
    say Dumper $xml_args;
    my $sms_xml = _build_sms_xml($xml_args);
    say $sms_xml;

    my $ua = new LWP::UserAgent;
    $ua->agent("Koha/0.1 " . $ua->agent);

    my $req = new HTTP::Request GET => $self->{send_url};
    $req->content_type('application/x-www-form-urlencoded');
    $req->content($sms_xml);

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    say $res->as_string;

     # Check the outcome of the response
    if ($res->is_success) {
        return 1;
    } else {
        return 0;
    }
}

# This status subroutine is not used by SMS::Send but can be used directly with the driver.
#sub sms_status {
#    my ($self, $mobilectrl_id) = @_;
#    my $args = {
#        customer_id     => "$self->{_login}",
#        mobilectrl_id   => "$mobilectrl_id"
#    };
#    my $xml = _build_status_xml($args);
#    return _post($self->{status_url}, $xml);
#}

#sub _post {
#    my ($url, $sms_xml) = @_;
#    return HTTP::Tiny->new->post(
#        $url => {
#            content => $sms_xml,
#            headers => {
#                "Content-Type" => "application/xml",
#            },
#        },
#    );
#}

sub _build_sms_xml {

    my ( $args ) = @_;
    say Dumper $args;

    # FIXME Use DateTime for this...
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime time;
    my $sendtime = _addZero($hour) . ":" . _addZero($min) . ":" . _addZero($sec);
    my $senddate = 1900+$year . "-" . _addZero($mon+1) . "-" . _addZero($mday);

    my $xmltemp = "<?xml version='1.0' ?>";
    $xmltemp .= "<sms-teknik>";
    $xmltemp .=     "       <operationtype>0</operationtype>";
    $xmltemp .=     "       <flash>0</flash> ";
    $xmltemp .=     "       <multisms>0</multisms>";
    $xmltemp .=     "       <compresstext>0</compresstext>";
    $xmltemp .=     "       <send_date>$senddate</send_date>";
    $xmltemp .=     "       <send_time>$sendtime</send_time>";
    $xmltemp .=     "       <udh></udh>";
    $xmltemp .=     "       <udmessage>" . $args->{'message'} . "</udmessage>";
    $xmltemp .=     "       <smssender>" . $args->{'sender'} . "</smssender>";
    $xmltemp .=     "       <deliverystatustype>0</deliverystatustype>";
    $xmltemp .=     "       <deliverystatusaddress></deliverystatusaddress> ";
    $xmltemp .=     "       <usereplynumber>0</usereplynumber>";
    $xmltemp .=     "       <usereplyforwardtype>0</usereplyforwardtype>";
    $xmltemp .=     "       <usereplyforwardurl></usereplyforwardurl>";
    $xmltemp .=     "       <usereplycustomid></usereplycustomid>";
    $xmltemp .=     "       <usee164>0</usee164>";
    $xmltemp .=     "       <items>";
    $xmltemp .=     "               <recipient>";
    $xmltemp .=     "                       <orgaddress>" . $args->{'to'} . "</orgaddress>";
    $xmltemp .=     "               </recipient>";
    $xmltemp .=     "       </items>";
    $xmltemp .=     "</sms-teknik>";

    return $xmltemp;
}

sub _addZero{
    my ($value) = @_;
    if($value < 10){ $value = "0" . $value; }
    return $value;
}

#sub _build_status_xml {
#    my $args = shift;
#    return '<?xml version="1.0" encoding="ISO-8859-1"?>'
#    . '<mobilectrl_delivery_status_request>'
#    . '<customer_id>'
#    . $args->{customer_id}
#    . '</customer_id>'
#    . '<status_for type="mobilectrl_id">'
#    . $args->{mobilectrl_id}
#    . '</status_for>'
#    . '</mobilectrl_delivery_status_request>';
#}

#sub _verify_response {
#    my $content = shift;
#    if ($content =~ /\<status\>(\d)\<\/status>/) {
#        return $1;
#    }
#    return 1;
#}
1;

=head1 NAME

SMS::Send::Telenor - SMS::Send driver to send messages via Telenor SMS Pro

=head1 AUTHOR

Magnus Enger, <lt>magnus@libriotech.no<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 Libriotech

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
__END__
