require 'pry'
require 'fileutils'
require 'CSV'
require 'nbayes'
require 'json'


data = {}

data["directed"] = false

data["multigraph"] = false

data["nodes"] = []

data["links"] = []

source_list = []

shapes = ["circle", "square", "triangle-up", "diamond", "cross", "triangle-down", "cross", "diamond"]


#create the nodes for the network


def create_nodes(shapes, data, source_list)

	CSV.foreach("network_links_final", :headers=>true) do |row|

		# binding.pry

		shapes.shuffle


		data["nodes"] << {"size"=>10, "score"=> 0.6,"id"=> row["TAG"], "group"=>row["Group"], "type"=>shapes[row["Group"].to_i]}

		source_list << row["TAG"]


	end
end


def create_links(data, source_list)
#Create the links for the networ diagram.

#The matrix is configured with a sorted (by links) on the row side with no sorting on the 
#columns.  So the matching process to create the links is slightly more complicated:
# 1. The initial loop on the CSV file will move down each row and pick up the source node
# 2. The target nodes will be identified by moving through a list of nodes within each row loop. 
# 3. A link between a source and target link is identified by a one on the matrix.
# 4. The link is created between the row and column item - using the csv functionality.

	CSV.foreach("network_links_final", :headers=>true) do |row|

		#The source list is a list of the possible nodes

		source_list.each do |target|

		# row[target] will identify the column on the matrix

			if row[target] == "1"

				#create hash with source and target index between the current row item and the column item
				#identified to be linked to the row item r[target] will be looking down a column at the specific row in question.

				data["links"] << {"source" => source_list.index(row["TAG"]), "target"=> source_list.index(target)}

			end
		end
	end
end

def generate_json(data, filename)

	#Generate the json file including the nodes and links from the data array.


	File.open("#{filename}.json", "w") do |f|

		f.write(data.to_json)

	end
end

create_nodes(shapes, data, source_list)
create_links(data, source_list)
generate_json(data, "bannanas")


