#!/usr/bin/env ruby

# Author: Donald L. Merand
# Given a tab-separated text file with usernames as the first
# row, create user folders in a chosen directory, and
# add ACl entries so that only that user can access the folder.


# We use optparse to do command line options
require 'optparse'


### Initialize variables

# This is the file full of users you pass in.
user_input_file = "server_user_list.txt"
# Folder into which you'd like to place the user (required)
parent_folder = ""
deny = []



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
  p_desc = '(required) parent folder into which to add users'
  opts.on('-p', '--parent FOLDER', p_desc) do |p|
    parent_folder = p.sub(%r/\/$/, "")
  end
  opts.on('-d', '--deny GROUP', 'groups to deny access') do |group|
    deny.push group
  end
  i_desc = 'specify a file from which to import'
  opts.on('-i', '--input_file FILE', i_desc) do |file|
    user_input_file = file
  end
end

# Do the actual parsing of options, now that we've set it up.
optparse.parse!

# Validate that a password was sent, exit if not.
show_help(optparse) if parent_folder.empty?



### Ready for Action!

# Attempt to open/create the input users file for appending
user_list = File.open(user_input_file, "r")

# Attempt to create the passed folder, in case it doesn't exist.
begin
  Dir.mkdir(parent_folder)
rescue SystemCallError
  #no problem...
end

# Each row of the users file is a user. Try to add a directory
# for them and update the permissions
user_list.each do |line|
  # Tab-separated file. Split on tabs to make an array
  record = line.gsub!("\n", "").split("\t")

  # User name is the first row in the record
  user_name = record[0]

  # Create user folder
  folder_path = "#{parent_folder}/#{user_name}"
  begin
    dir = Dir.mkdir(folder_path)
  rescue SystemCallError
    puts "Error creating #{folder_path}"
    #next
  end

  $stdout.printf "Attempting to create/set permissions for %s... ", folder_path

  # Set ACL settings...
  # **NOTE** that we assume there is an LDAP user for the user
  # in the list. Perhaps modify this script to check?
  system("chown #{user_name} '#{folder_path}'")
  system("chmod 660 '#{folder_path}'")
  system("chmod +a \"#{user_name} allow read,write,execute,delete,append,readattr,writeattr,readextattr,writeextattr,readsecurity,list,search,add_file,add_subdirectory,delete_child,file_inherit,directory_inherit\" '#{folder_path}'")
  system("chmod +a \"admin allow read,write,execute,delete,append,readattr,writeattr,readextattr,writeextattr,readsecurity,list,search,add_file,add_subdirectory,delete_child,file_inherit,directory_inherit\" '#{folder_path}'")
  deny.each do |group|
    system("chmod +a \"#{group} deny read,write,execute,delete,append,writeattr,writeextattr,list,search,add_file,add_subdirectory,delete_child\" '#{folder_path}'")
  end

  $stdout.print "success!\n"
end


