
module SRS
	class Workspace
		class AlreadyInitialisedError < StandardError
		end
		class FolderNotEmptyError < StandardError
		end

		attr_reader :root, :dotsrs

		def initialize(dirname=".")
			if not SRS::Workspace.initialised?(dirname) then return nil end
			@root = dirname
			@dotsrs = File.join(dirname,'.srs')
			self
		end

		def self.create(dirname, force=false)
			dotsrs_dir = File.join(dirname,'.srs/')
			config_file = File.join(dotsrs_dir,'config')

			if( SRS::Workspace.initialised?(dirname) ) then
				raise AlreadyInitialisedError
				return nil
			end

			if( !force ) then
				if( Dir.entries(dirname).length > 2 ) then
					raise FolderNotEmptyError
					return nil
				end
			end

			Dir.mkdir(dotsrs_dir)
			File.new(config_file, "w")

			return SRS::Workspace.new(dirname)
		end

		def self.initialised?(dirname)
			dotsrs_dir = File.join(dirname,'.srs/')
			config_file = File.join(dotsrs_dir,'config')

			return File.exists?(config_file)
		end
	end
end
