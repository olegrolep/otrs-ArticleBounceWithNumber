### Bounce last article to owner / resposnible, adding ticket number to subject

Email utils to bounce latest article in the ticket to owner or responsible agent email.
Installation:
- install ArticleBounceWithNumber-1.0.1.opm

Usage: create GenericAgent job, where i.e. on owner or respnsible update set
execute custom module.
Set one of the modules:
- ArticleBounceWithNumber::ToOwner
- ArticleBounceWithNumber::ToResponsible
In passed Params/Keys set TicketID / TicketID (mb can work without it, but whatever)
As autoload is used - OTRS 6 is required
(yes, probably all functions can be organized in one file - you can improve it)

This add-on adds functions, which can be used in GenericAgent.
It allows to bounce latest article in the selected ticket to
owner or responsible agent's email.

Usage: In GenericAgent job -> Execute Custom Module, set one of
- ArticleBounceWithNumber::ToOwner
- ArticleBounceWithNumber::ToResponsible
In passed Params/Keys set TicketID / TicketID (mb can work without it, as ticketid
is supposed to be passed automatically)

Usecase: some managers can't move to otrs, they require email client to communicate with clients, etc.
If there is a new ticket in otrs for them - agent can set one as owner / responsible
(they have users created for them)
Only bounce preserve all fields in original email, but it will not contain ticket number.
With this add-on latest article is bounced to their email, with ticket number in subject,
allowing agents to track responses if needed (otrs email can remain in cc).
