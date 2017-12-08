#!/usr/bin/perl

# This module is triggered by a generic agent and will set
# the current time to a dynamic field

package ArticleBounceWithNumber::ToOwner;

use strict;
use warnings;
use utf8;
use lib '/opt/otrs/';
use lib '/opt/otrs/Kernel/cpan-lib';
use lib '/opt/otrs/Custom';

sub new {
  my ( $Type, %Param ) = @_;

  # allocate new hash for object
  my $Self = {%Param};
  bless( $Self, $Type );

  return $Self;
}

sub Run {
  my ( $Self, %Param ) = @_;

  my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
  my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

  my %Ticket = $TicketObject->TicketGet(
    TicketID      => $Param{TicketID},
    UserID        => 1,
  );

  my ($OwnerID, $Owner) = $TicketObject->OwnerCheck(
    TicketID => $Param{TicketID},
  );

  my %Article = $TicketObject->ArticleLastCustomerArticle(
    TicketID      => $Param{TicketID},
  );

  my $TicketNumber = $TicketObject->TicketNumberLookup(
    TicketID      => $Param{TicketID},
  );

  my $Subject = $TicketObject->TicketSubjectBuild(
    TicketNumber => $TicketNumber,
    Action       => 'Forward',
    Subject      => $Article{Subject} || '',
  );

  my %UserData = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
    UserID        => $OwnerID,
  );

  my %Address = $QueueObject->GetSystemAddress(
    QueueID => $Ticket{QueueID},
  );

  my $Success = $TicketObject->ArticleBounceWithCustomSubject(
    From      => $Address{Email},
    To        => $UserData{UserEmail},
    TicketID  => $Param{TicketID},
    ArticleID => $Article{ArticleID},
    UserID    => 1,
    Subject   => $Subject,
  );

}

1;
