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




# Open the CSV file holding all the tweets and push them into the text_train array
# or the text_predict array depending on whether they have a rating a.k.a classification of either Positive, Negative or Neutral.  
# Also remove any duplicate tweets.
tweet_text =[]

CSV.foreach("file_name2utf.csv", :headers=>true) do |row|

	split_tweet = []



	unless tweet_text.include?(row["tweetText"])

		split_tweet = [row["userName"],hashtag_handles(row["tweetText"])]

		tweet_text << row["tweetText"]

		network << split_tweet

	end
	

	# adds the userScreen name to the user_ids array.
	# if row["Rating"] != nil
 # 		text_train << [row["tweetID"],row["userScreen"],row["tweetText"], row["Rating"]]
 # 	else
 # 		unless text_predict.include?(row["tweetText"])
	# 		text_predict << [row["tweetID"],row["userScreen"],row["tweetText"]]
	# 	end
 # 	end
end

tweet_text = []

# binding.pry



#Open a new csv file and load it with the trained text and the predictions

# CSV.open("network_gephi", "w") do |csv|

# 	network.each do |nw|

# 		unless nw[1].empty?

# 			csv << nw[1]
# 		end


# 	end

# end

# binding.pry

flatten_array = network.flatten.map(&:upcase)

cleaned_flatten_array = flatten_array.map {|text| strip_text(text)}

# binding.pry

flatten_unique_array = cleaned_flatten_array.uniq

count_array = []

flatten_unique_array.each do |uniq_val|

	count_array << [uniq_val, cleaned_flatten_array.count(uniq_val)]

end

# binding.pry

network_array = []


CSV.open("network_gephi_list", "w") do |csv|

	count_array.each do |uniq_count|

		if uniq_count[1] > 5

			network_array << uniq_count[0]

			csv << uniq_count
		end
	end

end

# network_joins =[]

	CSV.open("network_list", "w") do |csv|

		network_array_with_dups =[]

		network_array.each do |net_text|

			network_array.each do |next_text|

				unless net_text == next_text

					unless net_text == network_array.last

						unless net_text == "" || next_text==""

							network.each do |check_tweet|
								# binding.pry
								check_tweet_cleaned = check_tweet[1].map {|text| strip_text(text).upcase}

								if check_tweet_cleaned.include?(net_text) &&  check_tweet_cleaned.include?(next_text)

										network_array_with_dups << [net_text, next_text]
								
								end

							end
						end
					end	
				end
			end
		end


		network_array_no_dups = network_array_with_dups.uniq

		network_array_no_dups.each do |network|
			csv << network
		end
	end

