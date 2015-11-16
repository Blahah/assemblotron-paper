require 'bindeps'
require 'yaml'
require 'open3'
require 'fixwhich'
require 'fileutils'
require 'csv'
%w[cmd data deps optimiser_sim sweep controller].each do |class_def|
  require "assemblotron-paper/#{class_def}"
end
