require 'bindeps'
require 'yaml'
require 'open3'
require 'fixwhich'
require 'fileutils'

module AssemblotronPaper

  class AssemblotronPaper

    def initialize
      @gem_dir = Gem.loaded_specs['assemblotron-paper'].full_gem_path
      input_files_yaml = File.join(@gem_dir, 'metadata', 'input_files.yaml')
      @data = YAML.load_file input_files_yaml
    end

    def run_full_sweeps

      maybe_get_read_data

      ['graph', 'stream'].each do |sampler|

        3.times do |n|

          rep_no = n + 1

          puts "Running full sweep using sampler #{sampler} (rep #{rep_no})"
          # un assemblotron with the specified sampling method
          # and the rep_no as seed

        end

      end

    end

    def maybe_get_read_data

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

    end


  end

  class Cmd

    attr_accessor :cmd, :stdout, :stderr, :status

    def initialize cmd
      @cmd = cmd
    end

    def run
      @stdout, @stderr, @status = Open3.capture3 @cmd
    end

    def to_s
      @cmd
    end

  end

end
