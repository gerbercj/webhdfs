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

 * append(path, data) - Add additional text to the end of a file
 * cat(path) - Display the contents of a stored file
 * create(path, data) - Create a new file
 * home_dir - Get the user's home directory
 * ls(path) - List the contents of a directory
 * mkdir(path) - Make a new directory
 * mv(path, destination) - Rename a file or directory
 * rm(path) - Remove a file or directory
 * status(path) - Status of a file or directory
 * summary(path) - Summary information for a directory

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
