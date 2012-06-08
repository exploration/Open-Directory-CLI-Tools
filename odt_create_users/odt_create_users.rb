#!/usr/bin/ruby

# Author: [Donald L. Merand](http://donaldmerand.com) for
# [Explo](http://www.explo.org)
#
# I wrote this program to create LDAP (specifically Open Directory on OS X 10.7
# users, and optionally assign them to groups, based on a simple export of user
# names from eg. yer database.
#
# It takes a tab-separated file in the form: `FirstName TAB LastName` and
# creates an OD user for each row.
#
# You can pass an OD group you'd like your users to be in with the `-g
# GROUPNAME` command-line option. 
#
# The program will output a file (`server_user_list.txt` by default) which is a
# list of all usernames and passwords that have been added to the OD.




# We use optparse to do command line options
require 'optparse'


### Initialize variables

# I'm assuming you'll be using a local OD host
# (ie you're running this utility on your OD server)
od_host = "/LDAPv3/127.0.0.1/"
# Diradmin is the default user on OS X Server
od_user = "diradmin"
# Password is intentionally blank. You know, for security.
od_pass = ""
# This is the file full of users you pass in.
user_input_file = "portico_user_list.txt"
# This is the name of the list of usernames and passwords that gets generated.
user_output_file = "server_user_list.txt"
# Optional OD group to which to add all users
od_group = ""



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
  opts.on('-p', '--pass PASSWORD', '(required) specify a dscl pass') do |pass| 
    od_pass = pass
  end
  opts.on('-u', '--user USERNAME', 'specify a dscl/OD user') do |user|
    od_user = user
  end
  opts.on('-i', '--input_file FILE', 'specify a file from which to import') do |file|
    user_input_file = file
  end
  opts.on('-o', '--output_file FILE', 'output results to file') do |file|
    user_output_file = file
  end
  g_desc = 'set OD user group to whatever you want'
  opts.on('-g', '--group GROUPNAME', g_desc) do |group|
    od_group = group
  end
end

# Do the actual parsing of options, now that we've set it up.
optparse.parse!

# Validate that a password was sent, exit if not.
show_help(optparse) if od_pass.empty?




### Okay We're Ready

# Attempt to open the input users file for reading
portico_users = File.open(user_input_file, "r")
# Attempt to open/create the output users file for appending
output_users = File.open(user_output_file, "a")


# Simple function to create a random password,
# which I got [here](http://stackoverflow.com/a/3572953)
def rand_pass(length=8)
  return rand(36**length).to_s(36)
end


# Set up the basic `dscl` command we'll be using to do all `dscl` stuff
# If you don't know about dscl, `man dscl` will be helpful ;)
dscl_command = "dscl -u #{od_user} -P #{od_pass} #{od_host}"
# Get the most recent UNIQUE ID from OD. We only have to do this once
# via DSCL, then just increment it below, since that's all that OD
# would do.
unique_id = `dscl #{od_host} list Users UniqueID | awk '{print $2}' | sort -ug
| tail -1`.to_i

# For each user in the input file...
portico_users.each { |line|
  # Get rid of the new line and split into fields based on tab
  row = line.gsub!("\n", "").split("\t")

  # Get variables based on field position
  # expects: First Name TAB Last Name
  first_name = row[0]
  last_name = row[1]
  user_name = "#{first_name}#{last_name}".downcase

  # Create a random password
  pass = rand_pass

  # Increment the unique_id from above once per row
  unique_id += 1

  # Since system calls exit 0 on success, I'm going to add all the exit
  # statuses and make a fuss if they are greater than zero
  num_errors = 0

  # Attempt user creation
  $stdout.printf "Attempting to create %s %s... ", od_group, user_name
  num_errors += system "#{dscl_command} create Users/#{user_name}"
  num_errors += system "#{dscl_command} create Users/#{user_name} UniqueID #{unique_id}"
  num_errors += system "#{dscl_command} create Users/#{user_name} RealName '#{first_name} #{last_name}'"
  num_errors += system "#{dscl_command} create Users/#{user_name} PrimaryGroupID 1025"
  num_errors += system "#{dscl_command} passwd Users/#{user_name} #{pass}"

  # Add users to group if applicable
  unless od_group.empty?
    num_errors += system "dseditgroup -u #{od_user} -P #{od_pass} -o edit -t user -a #{user_name} #{od_group.downcase}"
  end

  # If there were no errors with the pile of shell scripts I just ran...
  if num_errors == 0

    # Append username and password to output file
    output_users.puts "#{user_name}\t#{pass}"
    $stdout.print "Success!\n" # ...continuing the line we printed above

  # Otherwise be a good UNIX citizen and print the results to STDERR
  else
    $stderr.printf "User creation error for %s :(", user_name
  end
}
