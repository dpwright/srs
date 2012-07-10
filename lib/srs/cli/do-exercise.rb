require 'require_all'

module SRS
	class CLI
		class DoExercise
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				sha1 = arguments.shift
				if sha1 == nil then
					return 4
				end

				sha1_start = sha1[0..1]
				sha1_rest = sha1[2..-1]

				datafile = "exercises/#{sha1_start}/#{sha1_rest}"

				if not File.exists?(datafile) then
					puts "No content with that ID exists"
					return 4
				end

				headers = {}
				metadata = ""
				File.open(datafile, "r") do |file|
					while( line = file.gets() ) do
						if line.strip.empty? then
							break
						end

						key, *val = line.split(':').map{|e| e.strip}
						headers[key] = val.join(':')
					end
					metadata = file.read
				end

				runModel(sha1, headers, metadata)
			end

			def runModel(sha1, headers, metadata)
				if not headers.has_key?("Model") then
					puts "Exercise #{sha1} has no model!\n"
					return nil
				end

				modelclass = headers.delete("Model")

				begin
					require_all "models/#{modelclass}"
				rescue LoadError
					begin
						require_rel "../models/#{modelclass}"
					rescue LoadError
						puts "Couldn't find model #{modelclass}."
						return nil
					end
				end

				model = SRS::Models.const_get(modelclass.to_sym).new
				score = model.run(headers, metadata)

				return score
			end

			def help()
				puts <<-EOF
srs do-exercise <id>

Runs the exercise defined in <id>
					EOF
			end
		end
	end
end

