require "stringio"

module SRS
	module Models
		class SimpleFlashcard
			def initialize()
			end

			def run(headers, metadata)
				data = headers.delete("Data")

				sha1_start = data[0..1]
				sha1_rest = data[2..-1]

				datafile = "data/#{sha1_start}/#{sha1_rest}"

				if not File.exists?(datafile) then
					puts "No content with that ID exists"
					return 4
				end

				self.load(datafile)

				score = 0.0
				StringIO.open(metadata) do |metadata|
					while( line = metadata.gets() ) do
						break if line.strip == "---"
						line.gsub!(/\[([^\]]+)\]/) { "#{@fields[$1]}" }
						puts line
					end
					answer = metadata.read.strip.gsub!(/\[([^\]]+)\]/) { "#{@fields[$1]}" }

					print "> "
					attempt = STDIN.gets().strip

					if( attempt == answer ) then
						puts "Correct."
						score = 1.0
					else
						puts answer

						for i in 0..0
							puts "Was your answer: [h] Correct, [j] Close, [k] Wrong, or [l] Very Wrong?"
							print "> "

							case STDIN.gets().strip
							when "h"
								score = 3.0/3.0
							when "j"
								score = 2.0/3.0
							when "k"
								score = 1.0/3.0
							when "l"
								score = 0.0
							else
								redo
							end
						end
					end
				end

				puts "You scored: " + score.to_s

				return score
			end

			def load(datafile)
				@fields = {}
				File.open(datafile, "r") do |file|
					while( line = file.gets() ) do
						if line.strip.empty? then
							break
						end

						keyval = line.split(':').map{|e| e.strip}
						key = keyval[0]
						val = keyval[1]

						@fields[key] = val
					end
				end
			end
		end
	end
end
