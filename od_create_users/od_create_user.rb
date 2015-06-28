#!/usr/bin/env ruby

# Author: [Donald L. Merand](http://donaldmerand.com) for
# [Explo](http://www.explo.org)
#
# I wrote this program to create LDAP (specifically Open Directory on OS X 10.7
# users, and optionally assign them to groups, based on a simple export of user
# names from eg. yer database.
#
# It takes a username and a password, along with any groups, and creates an OD
# user for you
#
# You can pass an OD group you'd like your users to be in with the `-g
# GROUPNAME` command-line option. 
#
# The program will output a file (`server_user_list.txt` by default) which is a
# list of all usernames and passwords that have been added to the OD.




# We use optparse to do command line options
require 'optparse'
# We use net/http to retrieve secure passwords
require "net/http"
require "uri"


# try to get a random password from explo's service, backup to random digits
def rand_pass(length=8)
  uri = URI.parse("http://robot.lab.explo.org/randompass")
  params = { :length => length }
  uri.query = URI.encode_www_form params

  response = Net::HTTP.get_response(uri)

  if response.is_a?(Net::HTTPSuccess)
    return response.body
  else
    # if the web call fails, make a cheesy random password
    # Simple function to create a random password,
    # which I got [here](http://stackoverflow.com/a/3572953)
    return rand(36**length).to_s(36)
  end
end


### Initialize variables

# I'm assuming you'll be using a local OD host
# (ie you're running this utility on your OD server)
od_host = "/LDAPv3/127.0.0.1/"
# Diradmin is the default user on OS X Server
od_user = "diradmin"
# Password is intentionally blank. You know, for security.
od_pass = ""
# Optional OD group to which to add all users
od_group = []
# This is the username
user_name = ""
# This is the optional password
user_pass = rand_pass



### Parse Command Line Options

# Simple function to show help for the command-line interface
def show_help(opts)
  puts opts
  exit 0
end

# Optparse is totally rad for reading command line options.  Hopefully it'll be
# relatively obvious what's going on here.
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: create_users.rb |options|"
  opts.on('-h', '--help', 'show this help') { show_help(opts) }
  opts.on('-p', '--od-pass PASSWORD', '(required) specify a dscl/OD pass') do |pass| 
    od_pass = pass
  end
  opts.on('-u', '--od-user USERNAME', 'specify a dscl/OD user') do |user|
    od_user = user
  end
  opts.on('--user-name USER', 'user name') do |u|
    user_name = u
  end
  opts.on('--user-pass', '(optional) user password') do |p|
    user_pass = p
  end
  opts.on('-g', '--group GROUPNAME', 'set created OD user group', 
        'use -g group1 -g group2 etc. for multiple groups') do |group|
    od_group.push group
  end
end

# Do the actual parsing of options, now that we've set it up.
optparse.parse!

# Validate that a password was sent, exit if not.
show_help(optparse) if od_pass.empty?




### Okay We're Ready

# Set up the basic `dscl` command we'll be using to do all `dscl` stuff
# If you don't know about dscl, `man dscl` will be helpful ;)
dscl_command = "dscl -u #{od_user} -P #{od_pass} #{od_host}"
# Get the most recent UNIQUE ID from OD. We only have to do this once
# via DSCL, then just increment it below, since that's all that OD
# would do.
unique_id = `dscl #{od_host} list Users UniqueID | awk '{print $2}' | sort -ug | tail -1`.to_i

# Increment the unique_id from above once per row
unique_id += 1

# Since system calls exit 0 on success, I'm going to add all the exit
# statuses and make a fuss if they are greater than zero
num_errors = 0

# Attempt user creation
$stdout.printf "Attempting to create %s | %s | %s\n", od_group.join, user_name, user_pass
system "#{dscl_command} create Users/#{user_name}"
num_errors += $?.exitstatus
system "#{dscl_command} create Users/#{user_name} UniqueID #{unique_id}"
num_errors += $?.exitstatus
system "#{dscl_command} create Users/#{user_name} RealName #{user_name}"
num_errors += $?.exitstatus
system "#{dscl_command} create Users/#{user_name} PrimaryGroupID 20"
num_errors += $?.exitstatus
system "#{dscl_command} passwd Users/#{user_name} '#{user_pass}'"
num_errors += $?.exitstatus

# Add users to group if applicable
unless od_group.empty?
  od_group.each do |group|
    system "dseditgroup -u #{od_user} -P #{od_pass} -o edit -t user -a #{user_name} #{group.downcase}"
    num_errors += $?.exitstatus
  end
end

# If there were no errors with the pile of shell scripts I just ran...
if num_errors == 0
  # Append username and password (and anything else passed in) to output file
  $stdout.print "Success!\n" # ...continuing the line we printed above

# Otherwise be a good UNIX citizen and print the results to STDERR
else
  $stderr.printf "User creation error for %s :(\n", user_name
end
