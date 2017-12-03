require 'pry'
require 'fileutils'
require 'CSV'
require 'nbayes'


# Information can be found about the nbayes ruby gem at the following urls
# https://github.com/oasic/nbayes
# http://blog.oasic.net/2012/06/naive-bayes-for-ruby.html


def hashtag_handles(text)
	#splits the text into words and removes any reference to urls

	 a = text.split(/\s+/).select {|str| str.include?("#")}
	 b = text.split(/\s+/).select {|str| str.include?("@")}
	 c = text.split(/\s+/).select {|str| str.upcase.include?("APPLEPAY")}
	 [a,b].flatten.uniq
end

def strip_text(text)

	text.tr('\\^.?#@_: "','')

end



network =[]


# *******************************************************************
	tweet_text =[]

	def extract_handles_and_hashtags

		CSV.foreach("file_name2utf.csv", :headers=>true) do |row|

			split_tweet = []


			unless tweet_text.include?(row["tweetText"])

				split_tweet = [row["userName"],hashtag_handles(row["tweetText"])]

				tweet_text << row["tweetText"]

				network << split_tweet

			end
		end

		tweet_text = []

		#This code generates each unique handle or hastag and the number of times it is included
		#in all the tweets

		flatten_array = network.flatten.map(&:upcase)

		cleaned_flatten_array = flatten_array.map {|text| strip_text(text)}


		flatten_unique_array = cleaned_flatten_array.uniq

		count_array = []

		flatten_unique_array.each do |uniq_val|

			count_array << [uniq_val, cleaned_flatten_array.count(uniq_val)]

		end
	end


	network_array = []

	CSV.foreach("network_gephi_list", :headers=>false) do |row|

		network_array << row[0]

	end

# *********************************************************************


def generate_search_list(list_names_file, cut_off)
	# Only use this code to set up the hastag and handles to look for.

	CSV.open("network_gephi_list", "w") do |csv|

		count_array.each do |uniq_count|

			if uniq_count[1] > 5

				network_array << uniq_count[0]

				csv << uniq_count
			end
		end

	end
end



# Once the main hastags and handles have been found there is no need to have this updated


def generate_network_matrix(network_matrix_file, network_array)
	network_joins =[]

	# Only use to generate the network links once this is done comment out the code

		CSV.open("network_links", "w") do |csv|

			network_array_with_dups =[]

			# add headers for the csv.
			csv << network_array

			#First loop setting the source text.
			network_array.each do |net_text|

			#Build the next row to be added to the csv file

			next_row_array = []

			#Second loop setting the potential target text.

			next_row_array = [net_text]

				network_array.each do |next_text|

					if net_text != next_text

						found = false

						network.each do |check_tweet|
							
							#clean the split tweet to match it against the 
							# uppercase handle or hastag

							check_tweet_cleaned = check_tweet[1].map {|text| strip_text(text).upcase}

							#Check if the cleaned tweet includes both words if it does, stop there - there is a link, if not continue through all tweets and continue checking.

							if check_tweet_cleaned.include?(net_text) &&  check_tweet_cleaned.include?(next_text)

								found=true
								break if found

							end

						end

						

						# puts "#{net_text} and #{next_text} and #{found}"
						# puts next_row_array.size

						if found
							next_row_array << 1
						else
							next_row_array << 0
						end

						
					else

						#When the node matches itself on the other list there is no link

						next_row_array << 0

					end

				

				end

				# Add the row to the csv file holding the network

				csv << next_row_array

			end
		end
end



