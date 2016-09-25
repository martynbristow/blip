# blip - Bash Library for Indolent Programmers

Programmers are lazy. Good system administrators are _really_ lazy. (Why bother doing something more than once)?

Unfortunately, due to the fact that Bash doesn't particularly lend itself to reusable code, it doesn't enjoy the same wealth of shared code available that you find with Python or Perl.

_"But what about the lazy sysadmin that needs to write a script, where Bash genuinely is the most appropriate option?"_, I hear you ask! Well, by providing functions for many common tasks, I'm hoping that `blip` will help fill some of the gaps for those situations.

```bash
source /usr/lib/blip.bash
```

* https://nicolaw.uk/blip
* https://github.com/neechbear/blip/

## TODO

* Merge all the other cool and reusable stuff I've written in to this library.
* Make all the shell scripting comply with a sensible style guide (like Google's one at https://google.github.io/styleguide/shell.xml).
* Write a comprehensive manual page with code examples for each function.
* Export the manual to HTML as well as native \*NIX man pages.
* Add comprehensive unit tests.
* Configure automatic unit test integtation with Travis.
* Setup automatic build of release tarballs upon GitHub repository commits (assuming a Travis pass of unit tests).
* Create SPEC file for RPM creation, and automatic release RPM creation.
* Polish the Debian package creation, and automatic release DEB creation.

## See Also

https://github.com/akesterson/cmdarg - A pure bash library to make argument parsing far less troublesome.

