Open Directory Tools: Create Users
==================================

Author: [Donald L. Merand](http://donaldmerand.com) for
[Explo](http://www.explo.org)

I wrote these programs to create LDAP (specifically Open Directory on OS X 10.7
users, and optionally assign them to groups, usually based on a simple export
of user names from eg. yer database.

Each program takes either a tab-separated spreadsheet file in a particular
format, or just command-line options to generate users.

You can pass an OD group you'd like your users to be in with the `-g GROUPNAME`
command-line option. 

Most versions will output a file (`server_user_list.txt` by default) which is
a list of all usernames and passwords that have been added to the OD.
