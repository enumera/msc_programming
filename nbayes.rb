require 'pry'
require 'fileutils'
require 'CSV'
require 'nbayes'


# Information can be found about the nbayes ruby gem at the following urls
# https://github.com/oasic/nbayes
# http://blog.oasic.net/2012/06/naive-bayes-for-ruby.html


def split_text(text)
	#splits the text into words and removes any reference to urls

	 text.split(/\s+/).select {|str| !str.include?("http")}
end

def generate_train_test_datasets(source_filename, text_train, text_predict)
# Open the CSV file holding all the tweets and push them into the text_train array
# or the text_predict array depending on whether they have a rating a.k.a classification of either Positive, Negative or Neutral.  
# Also remove any duplicate tweets.

	CSV.foreach("#{source_filename}", :headers=>true) do |row|

		# adds the userScreen name to the user_ids array.
		if row["Rating"] != nil
	 		text_train << [row["tweetID"],row["userScreen"],row["tweetText"], row["Rating"], row["tweetFavoriteCt"]]
	 	else
	 		unless text_predict.include?(row["tweetText"])
				text_predict << [row["tweetID"],row["userScreen"],row["tweetText"], row["tweetFavoriteCt"]]
			end
	 	end
	end
end

# puts text_predict.size


def train_classifier(nbayes_instance, text_train)

	#Train the instance of nbayes with the trained text.

	text_train.each do |ttrain|
		nbayes_instance.train(split_text(ttrain[2]), ttrain[3])
	end
end

def produce_results_for_tweet(results_file, text_train, text_predict, nbayes_instance)
	

	#Open a new csv file and load it with the trained text and the predictions

	CSV.open("#{results_file}", "w") do |csv|

		text_train.each do |ttrain|

			csv << ["Training",ttrain[0], ttrain[1],ttrain[2], ttrain[3],ttrain[4]]

		end



		text_predict.each do |tpredict|


			result = nbayes_instance.classify(split_text(tpredict[2]))
			nbayes_prob = nbayes_instance.calculate_probabilities(split_text(tpredict[2]))

			

			csv << ["Predicted",tpredict[0],tpredict[1],tpredict[2] ,result.max_class, nbayes_prob["Positive"], nbayes_prob["Negative"], nbayes_prob["Neutral"],tpredict[3]]

		end

	end
end




# Initialise the training array to hold all the tweets already classified
# Initialise the predict array to hold all the tweets to be classified
# initialise the nbayes instance

text_train =[]

text_predict =[]

network_array = []

@nbayes = NBayes::Base.new

generate_train_test_datasets("file_name2utf.csv", text_train, text_predict)
train_classifier(@nbayes, text_train)
produce_results("bananas2", text_train, text_predict, @nbayes)




