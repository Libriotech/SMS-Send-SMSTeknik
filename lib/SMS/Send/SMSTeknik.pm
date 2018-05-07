package SMS::Send::SMSTeknik;

# use HTTP::Tiny;
use LWP::UserAgent;
use Modern::Perl;
use base 'SMS::Send::Driver';

our $VERSION = '0.01';

sub new {
    my ($class, @arg_arr) = @_;
    my $args = {
        _login => "$arg_arr[1]",
        _pass  => "$arg_arr[3]",
        _id    => "$arg_arr[5]",
        _user  => "$arg_arr[7]",
        _pass  => "$arg_arr[9]",
    };

    # FIXME Make this configurable
    my $protocol = "https";
    my $service = "xml";
    my $postURL = "/send/";
    my $postHOST = "api.smsteknik.se";

    die "$class needs hash_ref with _login and _password.\n" unless $args->{_login} && $args->{_password};
    my $self = bless {%$args}, $class;
    $self->{send_url} = $protocol . "://" . $postHOST . $postURL . $service  . "?id=" . $args->{_id} . "&user=" . $args->{_user} . "&pass=" . $args->{_pass};
    # $self->{status_url} = 'http://sms-pro.net/services/' . $args->{_login} . '/status';
    # $self->{sms_sender} = 'FROM SENDER'; #Add the text that describes who sent the sms
    return $self;
}

sub send_sms {

    my ($self, %args) = @_;
    my $xml_args = {
        message => "$args{'text'}",
        to      => "$args{'to'}",
        sender  => "$self->{_sender}"
    };
    my $sms_xml = _build_sms_xml($xml_args);

    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/0.1 " . $ua->agent);
    print $ua->protocols_forbidden .  "\n";

    my $req = new HTTP::Request GET => $self->{send_url};
    $req->content_type('application/x-www-form-urlencoded');
    $req->content($sms_xml);

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    print $res->as_string;

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

    my ($sec,$min,$hour,$mday,$mon,$year) = localtime time;
    my $sendtime = addZero($hour) . ":" . addZero($min) . ":" . addZero($sec);
    my $senddate = 1900+$year . "-" . addZero($mon+1) . "-" . addZero($mday);

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
