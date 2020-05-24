# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

confDir = $confDir ||= File.expand_path(File.dirname(__FILE__))

clusterYamlPath = confDir + "/Cluster.yaml"

require File.expand_path(File.dirname(__FILE__) + "/scripts/cluster.rb")

Vagrant.require_version ">= 2.2.7"

Vagrant.configure("2") do |config|
	if File.exist? clusterYamlPath then
		settings = YAML::load(File.read(clusterYamlPath))
    else
        abort "Cluster settings file not found in #{confDir}"
    end
	
	Cluster.configure(config, settings)
end
