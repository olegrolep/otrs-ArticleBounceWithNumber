use Kernel::System::Email;

package Kernel::System::Email;
use strict;
use warnings;

#
# Please note that all autoload files have to be registered via SysConfig (see AutoloadPerlPackages###1000-Test).
#

sub BounceWithCustomSubject {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(From To Email Subject)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check and create message id
    my $MessageID = $Param{'Message-ID'} || $Self->_MessageIDCreate();

    # split body && header
    my @EmailPlain = split( /\n/, $Param{Email} );
    my $EmailObject = Mail::Internet->new( \@EmailPlain );

    # get sender
    my @Sender   = Mail::Address->parse( $Param{From} );
    my $RealFrom = $Sender[0]->address();

    # add ReSent header (see https://www.ietf.org/rfc/rfc2822.txt A.3. Resent messages)
    my $HeaderObject = $EmailObject->head();
    $HeaderObject->replace( 'Resent-Message-ID', $MessageID );
    $HeaderObject->replace( 'Resent-To',         $Param{To} );
    $HeaderObject->replace( 'Resent-From',       $RealFrom );
    $HeaderObject->replace( 'Resent-Date',       $Kernel::OM->Get('Kernel::System::Time')->MailTimeStamp() );
    $HeaderObject->replace( 'Subject', $Param{Subject} );
    my $Body         = $EmailObject->body();
    my $BodyAsString = '';
    for ( @{$Body} ) {
        $BodyAsString .= $_ . "\n";
    }
    my $HeaderAsString = $HeaderObject->as_string();

    # debug
    if ( $Self->{Debug} > 1 ) {
        my $OldMessageID = $HeaderObject->get('Message-ID') || '??';
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "Bounced email to '$Param{To}' from '$RealFrom'. "
                . "MessageID => '$OldMessageID';",
        );
    }

    my $Sent = $Self->{Backend}->Send(
        From    => $RealFrom,
        ToArray => [ $Param{To} ],
        Header  => \$HeaderAsString,
        Body    => \$BodyAsString,
    );

    return if !$Sent;

    return ( \$HeaderAsString, \$BodyAsString );
}

1;
