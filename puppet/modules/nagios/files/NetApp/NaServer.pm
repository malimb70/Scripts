#============================================================#
#                                                            #
# $ID:$                                                      #
#                                                            #
# NaServer.pm                                                #
#                                                            #
# Client-side interface to ONTAPI APIs                       #
#                                                            #
# Copyright (c) 2010 NetApp, Inc. All rights reserved.       #
# Specifications subject to change without notice.           #
#                                                            #
# This SDK sample code is provided AS IS, with no support or #
# warranties of any kind, including but not limited to       #
# warranties of merchantability or fitness of any kind,      #
# expressed or implied.  This code is subject to the license #
# agreement that accompanies the SDK.                        #
#                                                            #
# tab size = 8                                               #
#                                                            #
#============================================================#

package NaServer;

$VERSION = '1.0';	# work with all versions

use	Socket;
use	LWP::UserAgent;
use	XML::Parser;
eval	"require	Net::SSLeay";
eval	"require	IO::Select";
use	NaElement;
use IO::Socket;
# use	vars ('@ISA', '@EXPORT');
# use	Exporter;

# @ISA	= qw(Exporter);
# @EXPORT	= qw(invoke);
# @EXPORT	= qw(invoke_elem);

my $ctx = "";
my $chk_ssl_init = 0;

#============================================================#

=head1 NAME

  NaServer - class for managing Network Appliance(r)
             filers using ONTAPI(tm) APIs.


=cut

=head1 DESCRIPTION

  An NaServer encapsulates an administrative connection to
  a NetApp filer running ONTAP 6.4 or later.  You construct
  NaElement objects that represent queries or commands, and
  use invoke_elem() to send them to the filer (a convenience 
  routine called invoke() can be used to bypass the element
  construction step.  The return from the call is another
  NaElement which either has children containing the command
  results, or an error indication.
  
  The following routines are available for setting up 
  administrative connections to a filer.

=cut

#============================================================#

use	strict;

$::ZAPI_xmlns = "http://www.netapp.com/filer/admin";
$::ZAPI_dtd = "file:/etc/netapp_filer.dtd";
my $FILER_dtd = "file:/etc/netapp_filer.dtd";
my $DFM_ZAPI_dtd = "file:/etc/netapp_dfm.dtd";
my $AGENT_ZAPI_dtd = "file:/etc/netapp_agent.dtd";
$::ZAPI_snoop = 0;

#============================================================#

=head2  new($filer, $majorversion, $minorversion)

  Create a new connection to filer $filer.  Before
  use, you either need to set the style to "hosts.equiv"
  or set the username (always "root" at present) and
  password with set_admin_user().

=cut

sub new {
	my ($class)  = shift;
	my ($server) = shift;
	my ($major_version) = shift;
	my ($minor_version) = shift;
	my ($port)  = 80;
	my ($user)   = "root";
	my ($password) = "";
	my ($style) = "LOGIN";  # LOGIN or HOSTS
	my ($vfiler) = "";
	my ($server_type) = "";
	my ($debug_style) = "";
	my ($xml) = "";
	my ($timeout) = 0;
	my ($prev_resv_port) = 0;

	my $self = {
		server => $server,
		user   => $user,
		password => $password,
		style => $style,
		major_version => $major_version,
		minor_version => $minor_version,
		transport_type => "HTTP",
		port => $port,
		debug_style =>$debug_style,
		vfiler => $vfiler,
		server_type => $server_type,
		xml => $xml,
		timeout => $timeout,
		prev_resv_port => $prev_resv_port
	};

	bless $self, $class;

	$self->set_server_type("FILER");
	return $self;
}

#============================================================#

=head2 set_style($style)

  Pass in "LOGIN" to cause the server to use HTTP 
  simple authentication with a username and 
  password.  Pass in "HOSTS" to use the hosts.equiv 
  file on the filer to determine access rights (the
  username must be root in that case).

=cut

sub set_style ($) {
	my $self = shift;
	my $style = $self->{style};

	if ($style ne "HOSTS" && $style ne "LOGIN") {
		return $self->fail_response(13001,
			"in NaServer::set_style: bad style \"$style\"");
	}
	$self->{style} = shift;
}

#============================================================#

=head2 get_style()

  Get the authentication style

=cut

sub get_style () {
	my $self = shift;

	return $self->{style};
}

#============================================================#

=head2 set_admin_user($user, $password)

  Set the admin username and password.  At present
  $user must always be "root".

=cut

sub set_admin_user ($$) {
	my $self = shift;

	$self->{user} = shift;
	$self->{password} = shift;
}

#============================================================#

=head2 set_server_type($type)

  Pass in one of these keywords: "FILER" or "NETCACHE"
  to indicate whether the server is a filer or a NetCache
  appliance.

  If you also use set_port(), call set_port() AFTER calling
  this routine.

  The default is "FILER".

=cut

#
#  Note that "AGENT" and "DFM" are also valid values.  We
#  don't expose those to customers yet.
#

sub set_server_type ($$) {
	my $self = shift;
	my $type = shift;
	my $port = $self->{port};

	if ($type !~ /^(Filer|NetCache|Agent|DFM)/i) {
		return $self->fail_response(13001,
		  "in NaServer::set_server_type: bad type \"$type\"");
	}

	($type =~ /Filer/i) && do {
		$self->{url} = "/servlets/netapp.servlets.admin.XMLrequest_filer";
	};
	($type =~ /NetCache/i) && do {
		$self->{url} = "/servlets/netapp.servlets.admin.XMLrequest";
		$self->{port} = 80;
	};
	($type =~ /Agent/i) && do {
		$self->{url} = "/apis/XMLrequest";
		$self->{port} = 4092;
	};
	($type =~ /DFM/i) && do {
		$self->{url} = "/apis/XMLrequest";
		$self->{port} = 8081;
	};

	$self->{servertype} = $type;
}

#============================================================#

=head2 get_server_type()

  Get the type of server this server connection applies to.

=cut

sub get_server_type () {
	my $self = shift;

	return $self->{servertype};
}

#============================================================#

=head2 set_transport_type($scheme)

  Override the default transport type.  The valid transport
  type are currently "HTTP", "HTTPS".

=cut

sub set_transport_type ($$) {
	my $self = shift;
	my $scheme = shift;

	if ($scheme ne "HTTP" && $scheme ne "HTTPS") {
		return $self->fail_response(13001,
		  "in NaServer::set_transport_type: bad type \"$scheme\"");
	}

	if ($scheme eq "HTTP") {
	
		$self->{transport_type} = "HTTP";
		$self->{port} = 80;
	}
	
	if ($scheme eq "HTTPS") {
	
		$self->{transport_type} = "HTTPS";
		$self->{port} = 443;

		#One time SSL initialization
		if (!$chk_ssl_init) {

			Net::SSLeay::load_error_strings();
			Net::SSLeay::SSLeay_add_ssl_algorithms();
			#Random seed.
			Net::SSLeay::randomize("", time ^ $$);
			$ctx = Net::SSLeay::CTX_new() or
			return $self->fail_response(13001,
				"in Zapi::new - failed to create SSL_CTX ");
			Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
			and die_if_ssl_error("ssl ctx set options");
			$chk_ssl_init = 1;

		}
	}

}
#============================================================#

=head2 get_transport_type()

  Retrieve the transport used for this connection.

=cut

sub get_transport_type () {
	my $self = shift;

	return $self->{transport_type};
}
#============================================================#

=head2 set_debug_style($style)
	
	Set the style of debug.

=cut

sub set_debug_style ($$) {
	my $self = shift;
	my $debug_style = shift;
	
	if ($debug_style ne "NA_PRINT_DONT_PARSE") {
		return $self->fail_response(13001,
		"in NaServer::set_debug_style: bad style \"$debug_style\"");
	}
	else {
		$self->{debug_style} = $debug_style;
		return;
	}
}

#============================================================#

=head2 set_port($port)

  Override the default port for this server.  If you
  also call set_server_type(), you must call it before
  calling set_port().

=cut

sub set_port ($$) {
	my $self = shift;
	my $port = shift;
	
	$self->{port} = $port;
}

#============================================================#

=head2 get_port()

  Retrieve the port used for the remote server.

=cut

sub get_port () {
	my $self = shift;

	return $self->{port};
}

#============================================================#

=head2 is_debugging()

	Check the type of debug style and return the 
	value for different needs.
	Return 1 if debug style is NA_PRINT_DONT_PARSE
	else return 0.
=cut

sub is_debugging()
{
	my $self = shift;	
	my $style = $self->{debug_style};
	if ($style ne "NA_NO_DEBUG") {
		return 1;
	}
	else {
		return 0;
	}
}
#============================================================#

=head2 get_raw_xml_output()

	Return the raw XML output.

=cut

sub get_raw_xml_output()
{
	my $self = shift;

	return $self->{xml};
}
	
#============================================================#

=head2 set_raw_xml_output($$)

	Save the raw XML output.

=cut

sub set_raw_xml_output($$)
{
	my $self = shift;
	my $xml = shift;
	$self->{xml} = $xml;
}
#============================================================#

=head2 use_https()

   Determines whether https is enabled.

=cut

sub use_https () {
	my $self = shift;
	if ($self->{transport_type} eq "HTTPS" ) {
		return 1;
	} else {
		return 0;
	}
}
#============================================================#

=head2 invoke_elem($elt)

  Submit an XML request already encapsulated as
  an NaElement and return the result in another 
  NaElement.

=cut

sub invoke_elem ($) {
	my $self	= shift;
	my $req		= shift;
	my $server	= $self->{server};
	my $user	= $self->{user};
	my $password	= $self->{password};
	my $debug_style = $self->{debug_style};
	my $vfiler  = $self->{vfiler};
	my $server_type = $self->get_server_type();

	#my $xmlrequest = $req->sprintf();
	my $xmlrequest = $req->toEncodedString();

        # This is the filer url, in a form acceptable
	# to the method line of an HTTP transaction.

        my $url = $self->{url};

	my($sockaddr);
	my($name,$aliases,$proto,$port,$type,$len,$thisaddr);
	my($thisport,$thatport);
	my $lowport = 0;
	my($thataddr);
	my ($non_blocking);
	
	my $using_ssl = $self->use_https();
	my $ssl;
	
	my $timeout = $self->get_timeout();
	
	my $sock = undef;


	
	#
	# Establish socket connection
	#
	$sockaddr = 'S n a4 x8';
	if ($using_ssl) {
	    ($name,$aliases,$proto)=getprotobyname('ssl');
	     $proto = 0;
 	} else {	
	    ($name,$aliases,$proto)=getprotobyname('tcp');
	}

	($name,$aliases,$type,$len,$thataddr)=gethostbyname($server);
	$thatport=pack($sockaddr, &AF_INET,$self->{port},$thataddr);
	
	$lowport = 1023 if ( $self->get_style() eq "HOSTS" );
    
	while($lowport >= 0) {
		$sock = IO::Socket->new();
		if (!socket($sock,&PF_INET,&SOCK_STREAM,$proto) ) {
			return $self->fail_response(13001,
				"in Zapi::invoke, cannot create socket");
		}

		#
		# If we are being asked to use a reserved port (we
		# are doing hosts.equiv authentication), then we search to
		# find an available port number below 1024.
		#
		do{
			# do not bind to a reserved port if it is used in previous invoke
			if($lowport != 0 && $lowport == $self->{prev_resv_port}) {
				$lowport--;
			}
			$thisport=pack($sockaddr, &AF_INET, $lowport);
			$lowport--;
		} while (!bind($sock,$thisport) && $lowport > 0);
		if ($lowport == 0) {
			close($sock);
			return $self->fail_response(13001,
				"in Zapi::invoke, unable to bind "
				."to reserved port, you must be "
				."executing as root");
		}
		$self->{prev_resv_port} = $lowport + 1;
		
		#handle connection time out.
		if ($timeout > 0) {
			$sock->timeout($timeout);

			#In Perl 5.8.8 On windows, IO::Socket::connect call doesn't work 
			#because it dosn't check for EINPROGRESS after connect call
			if($^O eq "MSWin32" && ($] * 1000000 < 5008009)){
			$non_blocking = 1;
			# On windows, the value of FIONBIO is 0x8004667E. 
				ioctl($sock, 0x8004667e, pack("L!", $non_blocking));
			}
		}
		
		if (!$sock->connect($thatport)) {
			if($^O eq "MSWin32") {
				# On windows, sometimes the bind will succeed but connect fails 
				# with EADDRINUSE on a reserved port. So, try to recreate the
				# socket, bind it to the next available reserve port and attempt
				# to connect it again.
				if($self->get_style() eq "HOSTS" and $!{EADDRINUSE}){
					close($sock);
					$sock = undef;
					next;
				}
				if($timeout > 0 && ($] * 1000000 < 5008009)){
					if (($!{EINPROGRESS} || $!{EWOULDBLOCK})) { 
						$non_blocking = 0;
						if (!IO::Select->new(\*$sock)->can_write($timeout)) {
							ioctl($sock, 0x8004667e, pack("L!",$non_blocking));
							close($sock);
							return $self->fail_response(13001,
							"in Zapi::invoke, cannot connect to socket");
						}
						ioctl($sock, 0x8004667e, pack("L!",$non_blocking));
						last;
					}
				}
			}
			close ($sock);
			return $self->fail_response(13001,
			"in Zapi::invoke, cannot connect to socket");
		} else {
			last;
		}
	}
	
	select($sock); $| = 1;              # Turn on autoflushing
	select(STDOUT); $| = 1;         # Select STDOUT as default output
	
        #
	# Create an HTTP request.
        #
	my $request = HTTP::Request->new('POST',"$url");
	
	if ( $self->get_style() ne "HOSTS" ) {	
		$request->authorization_basic($user,$password);
	}
	
	
	my $content = "";
	my $vfiler_req = "";
    
	if($vfiler ne "") {
		$vfiler_req = " vfiler= \"$vfiler\" ";
	}

	my $xml_print = "";
	my $FILE = "";
	if ($server_type eq "FILER") {
		$FILE = $FILER_dtd;
	}
	elsif ($server_type eq "DFM") {
		$FILE = $DFM_ZAPI_dtd;
	}
	elsif ($server_type eq "AGENT") {
		$FILE = $AGENT_ZAPI_dtd;
	}
	$content = "<?xml version='1.0' encoding='utf-8' ?>"
		."<!DOCTYPE netapp SYSTEM '$FILE'>"
		."<netapp"
		.$vfiler_req
		." version='"
		.$self->{major_version}.".".$self->{minor_version}
		."' xmlns='$::ZAPI_xmlns'>"
		.$xmlrequest
		."</netapp>";
	if ($debug_style eq "NA_PRINT_DONT_PARSE") {
		$xml_print = "<?xml version='1.0' encoding='utf-8' ?>\n"
				."<!DOCTYPE netapp SYSTEM '$FILE'>\n"
				."<netapp"
				.$vfiler_req
				." xmlns=\"$::ZAPI_xmlns\""
				." version=\""
				.$self->{major_version}.".".$self->{minor_version}."\">"
				.$xmlrequest
				."</netapp>";

		print "INPUT:\n$xml_print\n";
	}
	
	$request->content($content);
	$request->content_length(length($content));

	my $methline =  $request->method()." ".$request->uri()." HTTP/1.0\n";
	my $headers  =  $request->headers_as_string();

	if ($using_ssl) {
		$ssl = Net::SSLeay::new($ctx) or return $self->fail_response(13001,
			"in Zapi::invoke, failed to create SSL $!");
		Net::SSLeay::set_fd($ssl, fileno($sock)); #Must use fileno
		Net::SSLeay::connect($ssl) or return $self->fail_response(13001,
		     "in Zapi::invoke failed to connect SSL $!");
				
		Net::SSLeay::ssl_write_all($ssl, $methline);
		Net::SSLeay::ssl_write_all($ssl, $headers);
		Net::SSLeay::ssl_write_all($ssl, "\n");
		Net::SSLeay::ssl_write_all($ssl, $request->content());

	} else {
		print $sock $methline;
		print $sock $headers;
		print $sock  "\n";
		print $sock $request->content();
	}

	my $xml = "";
	my $response;

	# Inside this loop we will read the response line and all headers
	# found in the response.

	my $n;
	my $state = 0;	# 1 means we're in headers, 2 means we're in content
	my ($key, $val);
	my $line;
	while (1) {
		if ($using_ssl) {
		    $line = Net::SSLeay::ssl_read_CRLF($ssl);
		} else {	
		    $line = <$sock>;
		}

		if ( !defined($line) || $line eq "" ) {
			last;
		}
		if ( $state == 0 ) {
			if ($line =~ s/^(HTTP\/\d+\.\d+)[ \t]+(\d+)[ \t]*([^\012]*)\012//) {
				# HTTP/1.0 response or better
				my($ver,$code,$msg) = ($1, $2, $3);
				$msg =~ s/\015$//;
				$response = HTTP::Response->new($code, $msg);
				$response->protocol($ver);
				$state = 1;
				next;
			} else {
				if ($using_ssl) {
					Net::SSLeay::free ($ssl);
				}	
				close($sock);
				return $self->fail_response(13001,
					"in Zapi::invoke, unable to parse "
					."status response line - $line");
			}
		} elsif ( $state == 1 ) {
			# ensure that we have read all headers.
			# The headers will be terminated by two blank lines
			if ( $line =~ /^\r*\n*$/ ) {
				$state = 2;
			} else {
				if ($line =~ /^([a-zA-Z0-9_\-.]+)\s*:\s*(.*)/) {
					$response->push_header($key, $val) if $key;
					($key, $val) = ($1, $2);
				} elsif ($line =~ /^\s+(.*)/ && $key) {
					$val .= " $1";
				} else {
					$response->push_header(
					    "Client-Bad-Header-Line" => $line);
				}
			}
		} elsif ( $state == 2 ) {
			$xml .= $line;
		} else {
			if ($using_ssl) {
				Net::SSLeay::free ($ssl);
			}	
			close($sock);
			return $self->fail_response(13001,
				"in Zapi::invoke, bad state value "
				."while parsing response - $state\n");
		}
	}
	if ($using_ssl) {
   	  Net::SSLeay::free ($ssl);  			# Tear down connection
	}	
	close($sock);

	if (!defined($response)) {
		 return $self->fail_response(13001,"No response received");
	}
	my $code = $response->code();
	if ( $code == 401 ) {
		return $self->fail_response(13002,"Authorization failed");
	}
	if ($self->is_debugging() > 0) {
		if ($debug_style eq "NA_PRINT_DONT_PARSE") {
			$self->set_raw_xml_output($xml);
			print "\nOUTPUT:\n$xml\n";
			return $self->fail_response(13001,"debugging bypassed xml parsing");
		}
	}
	return $self->parse_xml($xml,$xmlrequest);
}

#============================================================#

=head2 invoke($api, [$argname, $argval] ...)

   A convenience routine which wraps invoke_elem().
   It constructs an NaElement with name $api, and
   for each argument name/value pair, adds a child
   element to it.  It's an error to have an even
   number of arguments to this function.  

   Example: $myserver->invoke("snapshot-create",
                              "snapshot", "mysnapshot",
			      "volume", "vol0");

=cut

sub invoke (@) {
	my $self = shift;
	my $api  = shift;

	my $num_parms = @_;
	my $i;
	my $key;
	my $value;

	if ( ($num_parms & 1) != 0 ) {
		return $self->fail_response(13001,
			"in Zapi::invoke, invalid number of parameters");
	}

	my $xi = new NaElement($api);

	for ($i = 0; $i < $num_parms; $i += 2) {
		$key = shift;
		$value = shift;
		$xi->child_add(new NaElement($key, $value));
	}
	return $self->invoke_elem($xi);
}

1;

=head1 COPYRIGHT

  Copyright 2002-2003 Network Appliance, Inc. All rights 
  reserved. Specifications subject to change without notice.

  This SDK sample code is provided AS IS, with no support or 
  warranties of any kind, including but not limited to 
  warranties of merchantability or fitness of any kind, 
  expressed or implied.  This code is subject to the license 
  agreement that accompanies the SDK.

=cut

###############################################################################

# "private" subroutines for use by the public routines

#
# This is used when the transmission path fails, and we don't actually
# get back any XML from the server.
#
sub fail_response {
	my $self	= shift;
	my $errno	= shift;
	my $reason	= shift;

	my $n = new NaElement("results");
	$n->attr_set("status","failed");
	$n->attr_set("reason","$reason");
	$n->attr_set("errno","$errno");
	return $n;
}


sub server_start_handler ($$@) {
	my $xp = shift;
	my $el = shift;

	my $n = new NaElement("$el");
	push(@$::ZAPI_stack,$n);

	my $sz = $#$::ZAPI_stack;

	%::ZAPI_atts = ();
	while ( @_ ) {
		my $att = shift;
		my $val = shift;
		$::ZAPI_atts{$att} = $val;
		$n->attr_set($att,$val);
	}
}

sub server_char_handler {
	my $xp = shift;
	my $data = shift;

	my $i = $#$::ZAPI_stack;
	$::ZAPI_stack->[$i]->add_content($data);
}

sub server_end_handler {
	my $xp = shift;
	my $el = shift;

	# We leave the last element on the stack.
	if ( $#$::ZAPI_stack > 0 ) {
		my $sz = $#$::ZAPI_stack;

		# Pop the element and add it as a child
		# to its parent.
		my $n = pop(@$::ZAPI_stack);
		my $ns = $n->sprintf();
		my $i = $#$::ZAPI_stack;

		$::ZAPI_stack->[$i]->child_add($n);
	}
}

# this is a helper routine for invoke_elem

sub parse_raw_xml($$) {
 
	my $self        = shift;
	my $xml         = shift;

	$::ZAPI_stack = [];
 
	my $p = new XML::Parser(ErrorContext => 2);
	$p->setHandlers(
		Start => \&server_start_handler,
		Char => \&server_char_handler,
		End => \&server_end_handler
	);
	$p->parse($xml);

	if ( $#$::ZAPI_stack < 0 ) {
		return $self->fail_response(13001,
		"Zapi::parse_xml - no elements on stack");
	}
	my $r = pop(@$::ZAPI_stack);

	return $r;
}

sub parse_xml {

	my $self	= shift;
	my $xml		= shift;
	my $xmlrequest	= shift;

	$::ZAPI_stack = [];

	my $p = new XML::Parser(ErrorContext => 2);
	$p->setHandlers(
		Start => \&server_start_handler,
		Char => \&server_char_handler,
		End => \&server_end_handler
		);
	$p->parse($xml);

	if ( $#$::ZAPI_stack < 0 ) {
		return $self->fail_response(13001,
			"Zapi::parse_xml - no elements on stack");
	}
	my $r = pop(@$::ZAPI_stack);

	if ( $r->{name} ne "netapp" ) {
		return $self->fail_response(13001,
			"Zapi::parse_xml - Expected <netapp> element, "
			."but got ".$r->{name});
	}

	my $results = $r->child_get("results");
	if (! defined($results)) {
		return $self->fail_response(13001,
			"Zapi::parse_xml - No results element in output!");
	}
	return $results;
}

#============================================================#

=head2 set_vfiler($vfiler)

  sets the vfiler name. This function is added for vfiler-tunneling.

=cut

sub set_vfiler ($$) {
	my $self = shift;
	my $vfname = shift;

    if($self->{major_version} >= 1) {
        if($self->{minor_version} >= 7) {
            $self->{vfiler} = $vfname;
            return 1;
        }
    }
    return 0;
}

sub set_timeout ($$) {
	my $self = shift;
	my $timeout = shift;
	$self->{timeout} = $timeout;
}

sub get_timeout () {
	my $self = shift;
	return $self->{timeout};
}

