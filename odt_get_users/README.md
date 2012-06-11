Open Directory Tools: Get Users
===============================

Author: [Donald Merand](http://donaldmerand.com) for
[Explo](http://www.explo.org)

The goal is to get a spreadsheet from Open Directory of users, and the groups
they are in. We use this at Explo for various database-related reasons, but we
think it might be useful as a reference for how to do various things with dscl
and Open Directory

Creates a spreadsheet called final_list.tab, which contains one row for each
time a user is assigned to a group. The first element in the row is the group
name, and each following element is a username for the same person
