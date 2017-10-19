NAME

	vmb - vagrant multi box handler

VERSION

	0.2

SYNOPSIS:

	vmb.sh [ list | status | up | down | stop | halt | suspend | resume ]

DESCRIPTION

	Allows you to change states of multiple Vagrant boxes at once.

	I just recently started to play around with Vagrant -
	https://www.vagrantup.com - and found out that it doesn't have a built
	in way of suspending multiple boxes at once. Well, since I wanted to be
	able to do so, I wrote this little script.

	Currently only handling one provider type at a time.

ARGUMENTS

	OPTIONS

	list, status			Same as 'vagrant global-status'

	up, start			Bring all boxes that don't have the state
					'running' up

	halt, down, stop		Halt all boxes that are running or are
					suspended

	suspend				Suspend all boxes that are not already
					suspended

	resume				Resumes all boxes that are not already
					running

DEPENDENCIES

	- which
	- grep
	- awk
	- vagrant

	vmb.sh has built in sanity checks and will exit if any of these
	conditions are not met.

CONFIGURATION

	In the normal use case, only one variable needs to be set:

	    provider

		Name of provider of virtual machine

	    Default: "virtualbox"

AUTHOR

	Written by Marcus Hoffren

REPORTING BUGS

	Report vmb.sh bugs to marcus@harikazen.com
	Updates of gch.sh and other projects of mine can be found at
	https://github.com/rewtnull?tab=repositories

COPYRIGHT

	Copyright © 2017 Marcus Hoffren. License GPLv3+:
	GNU GPL version 3 or later - http://gnu.org/licenses/gpl.html

	This is free software: you are free to change and redistribute it.
	There is NO WARRANTY, to the extent permitted by law.

CHANGELOG

	LEGEND: [+] Add, [-] Remove, [*] Change, [!] Bugfix

	v0.1 (20171018)		[+] Initial release
	v0.2 (20171019)		[*] Attached exception handler to vagrant calls
				[*] Fixed super small shellcheck complaint
				[+] Added support for providers with a new provider
				    setting
				[+] Added some aliases to arguments
				[*] Minor code cleanup

TODO

	Send ideas to marcus@harikazen.com
