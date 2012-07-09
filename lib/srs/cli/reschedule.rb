require 'fileutils'

module SRS
	class CLI
		class Reschedule
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				schedule_id = arguments.shift
				score = arguments.shift.to_f

				is_new = false;
				schedulefile = "schedule/#{schedule_id}"

				if not File.exists?(schedulefile) then
					schedulefile = "schedule/pending/#{schedule_id}"
					is_new = true
					if not File.exists?(schedulefile) then
						puts "No content with that ID exists"
						return 4
					end
				end

				headers = {}
				File.open(schedulefile, "r") do |file|
					while( line = file.gets() ) do
						if line.strip.empty? then
							break
						end

						key, *val = line.split(':').map{|e| e.strip}
						headers[key] = val.join(':')
					end
				end

				if not headers.has_key?("Scheduler") then
					puts "Schedule #{schedule_id} has no scheduler!\n"
					return 6
				end

				exercise = headers.delete("Exercise")
				schedulername = headers.delete("Scheduler")
				was_repeat = (headers["Repeat"] == "true")

				scheduler = getScheduler(schedulername)
				headersOut = is_new ? scheduler.first_rep(score) : scheduler.rep(score, headers)

				FileUtils.rm_rf( schedulefile )

				fileOut = "schedule/#{schedule_id}"
				File.open(fileOut, "w") do |file|
					file.puts "Exercise: #{exercise}"
					file.puts "Scheduler: #{schedulername}"
					headersOut.each do |key, value|
						file.puts "#{key}: #{value.to_s}"
					end
				end

				if not was_repeat then
					puts "Exercise rescheduled for #{headersOut["Due"]}"
				else
					puts "Exercise passed; removed from repeats list" if not headersOut["Repeat"]
				end

				puts "Exercise failed; marked for repetition" if headersOut["Repeat"]

				#Update queue files
				ws = SRS::Workspace.new

				lines = []
				if File.exists? "#{ws.dotsrs}/QUEUED" then
					File.open("#{ws.dotsrs}/QUEUED", "r") do |queued_file|
						lines = File.readlines(queued_file).reject{|f| f == schedule_id}
					end
					File.open("#{ws.dotsrs}/QUEUED", "w") do |queued_file|
						lines.each do |f|
							queued_file.puts f
						end
					end
				end

				lines = []
				if File.exists? "#{ws.dotsrs}/REPEAT" then
					File.open("#{ws.dotsrs}/REPEAT", "r") do |queued_file|
						lines = File.readlines(queued_file).reject{|f| f == schedule_id}
					end
				end

				File.open("#{ws.dotsrs}/REPEAT", "w") do |queued_file|
					lines.each do |f|
						queued_file.puts f
					end

					queued_file.puts schedule_id if headersOut["Repeat"]
				end

				return 0
			end

			def getScheduler(schedulername)
				begin
					require_all "schedulers/#{schedulername}"
				rescue LoadError
					begin
						require_rel "../schedulers/#{schedulername}"
					rescue LoadError
						puts "Couldn't find scheduler #{schedulername}."
						return nil
					end
				end

				SRS::Schedulers.const_get(schedulername.to_sym).new
			end

			def help()
				puts <<-EOF
srs reschedule <id> <score>

Rescedules the exercise being set by schedule id according to the score
supplied.  Makes use of the scheduler defined for that schedule.  The score
passed in will typically be that returned from do-exercise.
					EOF
			end
		end
	end
end

