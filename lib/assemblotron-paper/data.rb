module AssemblotronPaper

  class Data

    def initialize(opts, gem_dir, data)
      @opts, @gem_dir, @data = opts, gem_dir, data
    end

    # Read the file that specifies which datsets are needed. For each
    # dataset, check if it is present. If not, download it.
    def maybe_get_read_data

      return if @reads_got

      Dir.chdir File.join(@gem_dir, 'data') do

        @data[:reads].each_pair do |species, dataset|

          Dir.mkdir species.to_s unless File.exist? species.to_s
          Dir.chdir species.to_s do

            [:left, :right].each do |pair_end|

              paths = dataset[pair_end]

              next if paths.key?(:downloaded) && paths[:downloaded]

              if File.exist?(paths[:filename])
                puts "Found #{pair_end} reads for #{species} dataset"
                next
              end

              puts "Downloading #{pair_end} reads for #{species} dataset"

              c = Cmd.new "wget #{paths[:url]} -O #{paths[:filename]}.gz"
              c.run

              c = Cmd.new "gunzip #{paths[:filename]}.gz"
              c.run

              paths[:downloaded] = true

            end

          end

        end

      end

      @reads_got = true

    end # maybe_get_read_data

  end # Data

end # AssemblotronPaper
