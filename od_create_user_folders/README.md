Open Directory Tools - Create User Folders
==========================================

Author: Donald Merand

This script is designed to take the output of `od_create_users`, which is (usually) a file name `server_user_list.txt`, and create user shared folders, with ACL settings, in a destination of your choosing. It's designed to be run on the Open Directory server itself.

More generally, it can take any tab-separated text file as input, where the first column is a username in your Open Directory.


Usage
-----

- Create a `server_user_list.txt` file as above.
- `ruby od_create_user_folder.rb -p path_to_parent_folder`
    - You can deny access to groups with the command `-d group_to_deny_access -d other_group_to_deny`  


Notes
-----

Thanks to [this page](http://www.ideocentric.com/technology/articles/title/osx-acl) for tons of info on ACLs
