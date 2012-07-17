require 'require_all'

module SRS
	class CLI
		class DoExercise
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				exercise_id = arguments.shift
				if exercise_id == nil then
					return 4
				end

				exercisefile = "#{exercise_id}"
				exercisefile = "exercises/#{exercise_id}" if not File.exists?(exercisefile)

				if not File.exists?(exercisefile) then
					puts "do-exercise: cannot read exercise #{exercisefile}"
					return 4
				end

				data_id = arguments.shift
				if data_id == nil then
					return 4
				end

				datafile = "#{data_id}"
				datafile = "data/#{data_id}" if not File.exists?(datafile)

				if not File.exists?(datafile) then
					puts "do-exercise: Cannot read data #{datafile}"
					return 4
				end

				headers = {}
				metadata = ""
				File.open(exercisefile, "r") do |file|
					while( line = file.gets() ) do
						if line.strip.empty? then
							break
						end

						key, *val = line.split(':').map{|e| e.strip}
						headers[key] = val.join(':')
					end
					metadata = file.read
				end

				runModel(exercisefile, headers, metadata, datafile)
			end

			def runModel(exercisefile, headers, metadata, datafile)
				if not headers.has_key?("Model") then
					puts "Exercise #{exercisefile} has no model!\n"
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
				score = model.run(headers, metadata, datafile)

				return score
			end

			def help()
				puts <<-EOF
srs do-exercise <exercise_id> <data_id>

Runs the exercise defined in <exercise_id> passing in the data from <data_id>
					EOF
			end
		end
	end
end

