How to Create LDAP Users from Portico
=====================================
This is for on-campus file-server setups


Faculty
-------

1. Make sure that you have created a `Faculty` group in your LDAP
2. Export faculty from SIS->Faculty using the "Export Faculty to Open Directory Format" script in `SIS`.
3. `create_users.rb -g Faculty -p <password>`
4. Check the file `server_user_list.txt` (or whichever file you specified from the command line) for the list of usernames and passwords


Students
--------

1. Make sure that you have created a `Students` group in your LDAP
2. Export students from SIS->Students using the "Export Faculty to Open Directory Format" script in `SIS`.
3. `create_users.rb -g Student -p <password>`
4. See step 4 above


Import Format
-------------

The expected import format is:

    First Name  TAB  Last Name
