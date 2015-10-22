require 'bindeps'
require 'yaml'
require 'open3'
require 'fixwhich'
require 'fileutils'

module AssemblotronPaper

  class AssemblotronPaper

    def initialize opts
      @opts = opts
      @gem_dir = Gem.loaded_specs['assemblotron-paper'].full_gem_path
      input_files_yaml = File.join(@gem_dir, 'metadata', 'input_files.yaml')
      @data = YAML.load_file input_files_yaml
      @reads_got = false
      bin = Which.which 'atron'
      if !bin || bin.empty?
        raise 'Assemblotron binary (atron) was not found in PATH'
      end
      @atron = bin.first
    end

    # For each dataset, run a full parameter sweep at a variety of sampling
    # rates, including with no sampling (i.e. the full dataset).
    #
    # For the sampled runs, do both stream sampling and graph sampling.
    def run_full_sweeps

      maybe_get_read_data

      Dir.chdir File.join(@gem_dir, 'data') do

        @data[:reads].each_pair do |species, dataset|

          Dir.chdir species.to_s do

            [1.0, 0.2, 0.1, 0.05].each do |rate|

              samplers = rate == 1.0 ? ['stream'] : ['graph', 'stream']

              samplers.each do |sampler|

                3.times do |n|

                  rep_no = n + 1

                  puts "Running full sweep using sampler #{sampler}" +
                       " at sample rate #{rate} (rep #{rep_no})"

                  # run assemblotron with the specified sampling method
                  # and the rep_no as seed
                  cmdstr =
                    @atron +
                    " --left #{dataset[:left]}" +
                    " --right #{dataset[:right]}" +
                    " --threads #{@opts.threads}" +
                    "#{rate == 1.0 ? '' : ' --skip-subsample'}" +
                    " --sampler #{sampler}" +
                    " --skip-final" +
                    " --optimiser sweep" +
                    " --seed #{rep_no}"
                  cmd = Cmd.new(cmdstr)
                  cmd.run

                  ratestr = "#{(rate * 100).to_i}pc"
                  save_logs(cmd.stdout, species.to_s, sampler, ratestr, rep_no)
                  save_csv(cmd.stdout, species.to_s, sampler, ratestr, rep_no)

                end

              end

            end

          end

        end

      end

    end # run_full_sweeps


    # Save the log output of an Assemblotron run
    def save_logs(stdout, *args)

      logfile = "#{args.join '_'}.log"
      logfile = File.expand_path logfile

      File.open(logfile, 'w') do |f|

        f.write stdout
        log.info "Assemblotron sweep log saved to #{logfile}"

      end

    end # save_logs


    # Save the results of an assemblotron run as a CSV file
    # by parsing the logs
    def save_csv(stdout, *args)

      lineregex = /parameters: K:(\d+), d:(\d+), e:(\d+) \| score: (\S+)/

      csvfile = "#{args.join '_'}.csv"
      csvfile = File.expand_path csvfile

      CSV.open(csvfile, 'w') do |out|

        out << ['K', 'd', 'e', 'score']

        stdout.split("\n").each do |line|

          next unless line =~ /^run/

          k, d, e, score = line.match(lineregex).captures
          score = score.to_f.round(6)
          score = 0.0 if score < 0.0001

          out << [k, d, e, score]

        end

        log.info "Assemblotron sweep data saved to #{csvfile}"

      end

    end # save_csv


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
