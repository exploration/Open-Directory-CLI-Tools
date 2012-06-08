#!/bin/sh

# Author: [Donald Merand](http://donaldmerand.com) for
# [Explo](http://www.explo.org)

# The goal is to get a spreadsheet from Open Directory of users, and the groups
# they are in. We use this at Explo for various database-related reasons, but
# we think it might be useful as a reference for how to do various things with
# dscl and Open Directory.
#
# Creates a spreadsheet called final_list.tab, which contains one row for each
# time a user is assigned to a group. The first element in the row is the group
# name, and each following element is a username for the same person

##  Setup

# Fail if a pipeline fails, not just the last command
set -e

# Either pass the LDAP root as a parameter, or assume it's localhost
LDAP_ROOT="/LDAPv3/127.0.0.1/"



##  Get Stuff

# Retrieve user data from the LDAP server
dscl $LDAP_ROOT -readall Users RecordName > ldap_users.txt

# Parse user data into a readable spreadsheet
awk '
#creates a tab-separated list of users out of a DSCL LDAP export
/RecordName: / {} #ignore
/^-/ { 
	counter = 0
	#Print every username, tab-separated
	for (i in users) {
		printf("%s\t", users[i])
		delete users[i]
	}
	printf("\n")
}
/^ / {
	#dscl puts a space before each username. get rid of it
	sub(/^ /, "", $0)
	users[counter] = $0	
	counter += 1
}
' ldap_users.txt > user_list.tab


# Retrieve group assignment data from the LDAP server
dscl $LDAP_ROOT -readall Groups GroupMembership > ldap_groups.txt

# Parse group data into a readable spreadsheet
awk '
#makes a tab-separated spreadsheet out of the default DSCL GroupMembership export
BEGIN {
	OFS="\t"
	ORS="\n"
}
/RecordName: / {
	group = $2
}
/GroupMembership: / {
	for (i=2; i<NF; i++) {
		users[i] = $i
	}
}
/^-/ {
	for (i in users) {
		print group, users[i]
		delete users[i]
	}
}
' ldap_groups.txt > group_list.tab


##  Parse Stuff

# Now combine the two spreadsheets into one
awk '
#Assumes you have sent the group spreadsheet, not the user spreadsheet
{
	command = "grep " $2 " user_list.tab" 
	command | getline grep_result
	close command
	printf("%s\t%s\n", $1, grep_result)
}
' group_list.tab |

sort -k 1 -k 2 > combined_list.tab



##  Cleanup

# Clear out the temporary files
rm ldap_users.txt ldap_groups.txt #leave the group lists

echo "user_list.tab, group_list.tab, and combined_list.tab created"
