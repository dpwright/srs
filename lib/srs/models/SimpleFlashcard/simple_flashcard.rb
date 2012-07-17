require "stringio"

module SRS
	module Models
		class SimpleFlashcard
			def initialize()
			end

			def run(headers, metadata)
				data = headers.delete("Data")
				datafile = "data/#{data}"

				if not File.exists?(datafile) then
					puts "SimpleFlashcard: Cannot read data \"#{data}\""
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
								score = 1.0
							when "j"
								score = 0.8
							when "k"
								score = 0.4
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

			def format_textfield(text)
				text.strip.gsub(/^[ \t]+/, "").gsub(/^:/,"").split("\n").join(" ").gsub( /\\n ?/, "\n" )
			end

			def load(datafile)
				@fields = {}
				File.open(datafile, "r") do |file|
					@fields = {}
					Hash[*file.read.split(/^([^:\s][^:\n]*):/)[1..-1]].each{|k,v| @fields[k] = format_textfield v}
				end
			end
		end
	end
end
