require 'optparse'
require 'srs/workspace'

module SRS
	class CLI
		class Init
			def initialize
				@options = {}
				@opts = OptionParser.new do |o|
					o.banner = <<-EOF.gsub /^\s+/, ""
						srs init [options] [dirname]

						Initialises a workspace in directory [dirname].  A `.srs/` folder will be
						created containing the default configuration files.  A skeleton directory
						structure may also be created (this is undecided as yet).

						If no [dirname] is passed, uses the current directory.
						EOF

					o.on('-f', '--force', 'Initialise workspace even if the directory is not empty') do
						@options[:force] = true
					end
				end
			end

			def run!(arguments)
				begin
					@opts.parse!(arguments)
					@options[:dir_name] = arguments.shift
				rescue OptionParser::InvalidOption => e
					@options[:invalid_argument] = e.message
				end

				if @options[:dir_name] == nil then
					@options[:dir_name] = "./"
				end

				begin
					SRS::Workspace.create(@options[:dir_name], @options[:force])
				rescue SRS::Workspace::AlreadyInitialisedError => e
					puts "SRS is already initialised in #{@options[:dir_name]}."
					return 2
				rescue SRS::Workspace::FolderNotEmptyError => e
					puts "The current folder is not empty!"
					puts "Run 'srs init --force' to initialise in this folder anyway."
					return 1
				end

				0
			end

			def help()
				puts @opts
			end
		end
	end
end

