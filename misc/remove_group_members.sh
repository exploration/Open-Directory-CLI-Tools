#!/usr/bin/env sh

# Author: Donald L. Merand
# Description: Allows you to delete all Open Directory users who are members of
# a certain OD group. At Explo, we use this to remove all summer-only logins
# after the summer is over.

# TODO: update with better visual feedback 

HOST=127.0.0.1
GROUP=$1
if [ -z $GROUP ]; then
  GROUP=invalid
fi
USERNAME=diradmin
PASSWORD=yerpassword

dscl -u "${USERNAME}" -P "${PASSWORD}" "/LDAPv3/${HOST}" read "Groups/${GROUP}" GroupMembership |
awk '{gsub(/ /, "\n", $0);print $0;}' |
xargs -I xXx dscl -u "${USERNAME}" -P "${PASSWORD}" "/LDAPv3/${HOST}" delete /Users/xXx
