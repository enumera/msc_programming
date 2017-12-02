# require_relative 'youtube'
require_relative 'init_twitter'

# require 'google/apis'
# require 'google/apis/youtube_v3'
# require 'googleauth'
# require 'googleauth/stores/file_token_store'
require 'pry'
require 'fileutils'
require 'json'
require 'twitter'
require 'CSV'

 
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "weQxZVTiuGuMM2Pd1qPOEYhNO"
  config.consumer_secret     = "zXYECjZ0NhmoN0WbUFRfLNrsQLQYrcw7BsY3jTiVUueR4oaNVN"
  config.access_token        = "311476681-BPCvNHwgK1bXYOVtHctdSqk5YBSJitF7KB8PAyqf"
  config.access_token_secret = "JBJ3JBLmW2qeIBp5LaOmakDzwhvNBJPBRdGve94CYh9m3"
end

# Finding Friends : https://gist.github.com/ronhornbaker/7817176

# Find the relationship between two users https://stackoverflow.com/questions/29905776/how-to-get-ruby-twitter-to-check-friendship-relationship

# @tweets = client.user_timeline('rubyinside', count: 20)

user_screens = []


CSV.foreach("file_name.csv", :headers=>true) do |row|
	# adds the userScreen name to the user_ids array.
 	user_screens << row[8]

end

puts user_screens.size

user_screens = user_screens.uniq

puts user_screens.size

# binding.pry


user_screens_test = user_screens.drop(160)

puts user_screens_test

CSV.open("gephi", "w") do |csv|

	# Produce an array for each user to check to friends and followers

	user_screens.each do |user_base|
		user_base_arr = []
		
		user_screens.each do |user_independent|

			# user_base_arr = []

			if user_base != user_independent

				if client.friendship?(user_base, user_independent)

					user_base_arr << user_indepedent
					puts "match"
				end
			end

		end
		csv << user_base_arr
	end
end


