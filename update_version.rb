# This script is used to update the version number in the pubspec file, in github action
require 'yaml'

pwd = Dir.pwd
# load the yaml file
config = YAML.load_file(pwd + '/pubspec.yaml')
tag_version = ENV["GITHUB_REF_NAME"]

tag_version = tag_version.gsub("v", "")
tag_version = tag_version.gsub("-alpha", "")

config["version"] = tag_version
File.open(pwd + "/pubspec.yaml", 'w') { |f| YAML.dump(config, f) }
