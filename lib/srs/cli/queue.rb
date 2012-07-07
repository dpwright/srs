require 'date'

module SRS
	class CLI
		class Queue
			def run!(arguments)
				if not SRS::Workspace.initialised? then
					puts "Current directory is not an SRS Workspace"
					return 3
				end

				queued = {}
				repeat = []

				Dir["schedule/*"].each do |filename|
					next if File.directory?(filename)

					schedule = {}
					File.open(filename, "r") do |file|
						while( line = file.gets() ) do
							if line.strip.empty? then
								break
							end

							key, *val = line.split(':').map{|e| e.strip}
							schedule[key] = val.join(':')
						end

						if( schedule["Repeat"] == "true" ) then
							repeat << filename
						else
							due = DateTime.parse(schedule["Due"])
							if( due < DateTime.now ) then
								queued[filename] = due
							end
						end
					end
				end

				ws = SRS::Workspace.new

				File.open("#{ws.dotsrs}/QUEUED", "w") do |queued_file|
					queued.sort_by{ |key, value| value }
					queued.each do |filename, due|
						queued_file.puts filename
					end
				end

				File.open("#{ws.dotsrs}/REPEAT", "w") do |repeat_file|
					repeat.each do |filename|
						repeat_file.puts filename
					end
				end

				return 0
			end

			def help()
				puts <<-EOF
srs queue

Queues exercises for review.
					EOF
			end
		end
	end
end

