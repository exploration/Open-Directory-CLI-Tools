Open Directory Tools: Create Users
==================================

Author: [Donald L. Merand](http://donaldmerand.com) for
[Explo](http://www.explo.org)

I wrote this program to create LDAP (specifically Open Directory on OS X 10.7
users, and optionally assign them to groups, based on a simple export of user
names from eg. yer database.

It takes a tab-separated file in the form: `FirstName TAB LastName` and creates
an OD user for each row.

You can pass an OD group you'd like your users to be in with the `-g GROUPNAME`
command-line option. 

The program will output a file (`server_user_list.txt` by default) which is a
list of all usernames and passwords that have been added to the OD.
