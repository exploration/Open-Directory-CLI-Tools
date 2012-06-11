Get Users and Groups
====================
The purpose of this script is to extract a list of groups and users from the LDAP database on a given OS X server. We use this list to put those users in the `message_board` (MB) database. Since the MB database associates logins with "nicknames", we need a list of every login that a user might use so that no matter which one they use, the database will associate properly. 

We also need the names of the groups that users are in so that we can associate their nickname with the appropriate department in the MB.

Usage
-----
Usage is simple. Just clone this repository onto your OS X server with `git clone https://github.com/exploration/Open-Directory-CLI-Tools.git`, and run the `get_users.sh` script. You'll see a file called `final_list.tab`, which you can use to import users into the message board. See below for the entire procedure.

General User Management Procedure
=============================
Here's what needs to happen, in rough order:

- Use `odt_create_users` to import students and faculty out of Portico. Check the README there for more information.
- Get a list of users who need to be added to Portico groups. This is typically all of the office workers. You'll need their specific office.
    - Each user should get _one and only one_ `PORTICO_XXX` group that indicates their Portico privilege level
    - Each office user should also get one _or more_ office groups, which are used for file-sharing. For example, a Main Office Manager might be in the `PORTICO_Admissions` group, and the `Main Office` group.
- Implement this user list in the Open Directory using Workgroup Manager to add users to groups.
    - You'll need usernames and passwords. If you used `odt_create_users` you'll have a list of those already.
    - People can have multiple usernames. So "Donald Merand" might have the usernames `donald`, `dmerand`, `donaldmerand`, and `Donald Merand`.
    - If you're doing passwords by hand, you can either generate passwords for people and give them out, or have people give you passwords. Either is fine. **JUST DON'T KEEP THE PASSWORDS IN PLAIN-TEXT ANYWHERE**.
- Once your Open Directory looks good, it's time to run the `odt_get_users.sh` utility. This will give you a file called `final_list.tab`.
- Open the `Message Board Sync` FileMaker database.
- Clear out any records that there may be in the database (if you didn't put them in yourself, natch)
- Import from your `final_list.tab` file. The default import order should be fine.
- You should now have a list of users, where each record associates one group of usernames with a specific Open Directory group.
- Find the groups you want to import into the `message_board`, and run the "create people and departments in message_board for found set" script, which will... you know... do what it says it does.
- Your Open Directory users now have accounts in the message board.
