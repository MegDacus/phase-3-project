ENV["RACK_ENV"] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"])

require_relative '../app/models/bookstore_app.rb'
require_relative '../app/models/book.rb'
require_relative '../app/models/user.rb'
require_relative '../app/models/bookshelf.rb'
require_relative '../app/models/book_list.rb'

