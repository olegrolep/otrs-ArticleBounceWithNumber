use Kernel::System::Ticket::Article;

package Kernel::System::Ticket::Article;
use strict;
use warnings;

#
# Please note that all autoload files have to be registered via SysConfig (see AutoloadPerlPackages###1000-Test).
#

sub ArticleBounceWithCustomSubject {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID ArticleID From To UserID Subject)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # create message id
    my $Time         = $Kernel::OM->Get('Kernel::System::Time')->SystemTime();
    my $Random       = rand 999999;
    my $FQDN         = $Kernel::OM->Get('Kernel::Config')->Get('FQDN');
    my $NewMessageID = "<$Time.$Random.0\@$FQDN>";
    my $Email        = $Self->ArticlePlain( ArticleID => $Param{ArticleID} );

    # check if plain email exists
    if ( !$Email ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "No such plain article for ArticleID ($Param{ArticleID})!",
        );
        return;
    }

    # pipe all into sendmail
    return if !$Kernel::OM->Get('Kernel::System::Email')->BounceWithCustomSubject(
        'Message-ID' => $NewMessageID,
        From         => $Param{From},
        To           => $Param{To},
        Email        => $Email,
        Subject      => $Param{Subject},
    );

    # write history
    my $HistoryType = $Param{HistoryType} || 'Bounce';
    $Self->HistoryAdd(
        TicketID     => $Param{TicketID},
        ArticleID    => $Param{ArticleID},
        HistoryType  => $HistoryType,
        Name         => "\%\%$Param{To}",
        CreateUserID => $Param{UserID},
    );

    return 1;
}

1;
