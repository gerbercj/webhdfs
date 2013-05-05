# WebHDFS

A demonstration of the WebHDFS REST API from Ruby for CSCI E-185

## Installation

Add this line to your application's Gemfile:

    gem 'webhdfs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webhdfs

## Usage

First, instantiate an instance of WebHDFS::Client with an appropriate user and host:

````ruby
client = WebHDFS::Client.new('user', 'host.example.com')
````

You now have access to the following methods:

 * append(path, data, opts) - Add additional text to the end of a file
 * cancel_token(token) - Cancel a delegation token
 * cat(path, opts) - Display the contents of a stored file
 * checksum(path) - Generate checksum information for a file
 * chmod(path) - Set permissions for a file or directory
 * chown(path, opts) - Change the owner and/or group for a file or directory
 * create(path, data, opts) - Create a new file
 * get_token(renewer) - Get a delegation token
 * home_dir - Get the user's home directory
 * ls(path) - List the contents of a directory
 * mkdir(path, opts) - Make a new directory
 * mv(path, destination) - Rename a file or directory
 * renew_token(token) - Renew a delegation token
 * replication(path, opts) - Set the number of replications for a file
 * rm(path, opts) - Remove a file or directory
 * status(path) - Status of a file or directory
 * summary(path) - Summary information for a directory
 * touch(path, opts) - Set timestamps for a file

Options for the various methods are described here: [WebHDFS API](http://http://hadoop.apache.org/docs/r1.0.4/webhdfs.html#SETOWNER)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
