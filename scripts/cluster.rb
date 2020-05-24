class Cluster
	def self.configure(config, settings)
		script_dir = File.dirname(__FILE__)

		settings['vms'].each do |vms|
			active = vms['active'] ||= true
			# if machine need active
			if active == false
				next
			end
			if vms.include? 'name'
				config.vm.define vms['name'] do |machine|
					# Configure Box
					machine.vm.define vms['name']
					machine.vm.box = 'cluster/centos'
					# machine.vm.box_check_update = false
					machine.vm.hostname = vms['name']

					# Configure VirtualBox
					machine.vm.provider 'virtualbox' do |vb|
						vb.name = vms['name']
						vb.cpus = vms['cpus'] ||= '1'
						vb.memory = vms['memory'] ||= '1024'
						vb.gui = vms['gui'] ||= false
					end

					# Configure Networks
					vms['networks'].each do |network|
						if network['type'] === 'private_network'
							if network['ip'] != 'auto'
								machine.vm.network 'private_network', ip: network['ip']
							else
								machine.vm.network 'private_network', ip: '0.0.0.0', auto_network: true
							end
						else
							machine.vm.network 'public_network', ip: network['ip'], bridge: network['bridge'] ||= nil, netmask: network['netmask'] ||= '255.255.255.0'
						end
					end

					# Configure ports
					if vms.has_key?('ports')
						vms['ports'].each do |port|
							port['guest'] ||= port['to']
							port['host'] ||= port['send']
							port['protocol'] ||= 'tcp'
						end
					else
						vms['ports'] = []
					end
					if vms.has_key?('ports')
						vms['ports'].each do |port|
							machine.vm.network 'forwarded_port', guest: port['guest'], host: port['host'], protocol: port['protocol'], auto_correct: true
						end
					end

					# Configure The Public Key For SSH Access
					if settings.include? 'authorize'
						if File.exist? File.expand_path(settings['authorize'])
							machine.vm.provision 'shell' do |s|
								s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/vagrant/.ssh/authorized_keys"
								s.args = [File.read(File.expand_path(settings['authorize']))]
							end
						end
					end

					# Copy The SSH Private Keys To The Box
					if settings.include? 'keys'
						if settings['keys'].to_s.length.zero?
							puts 'Check your Cluster.yaml file, you have no private key(s) specified.'
							exit
						end
						settings['keys'].each do |key|
							if File.exist? File.expand_path(key)
								machine.vm.provision 'shell' do |s|
									s.privileged = false
									s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
									s.args = [
										File.read(File.expand_path(key)),
										key.split('/').last
									]
								end
							else
								puts 'Check your Cluster.yaml file, the path to your private key does not exist.'
								exit
							end
						end
					end

					if vms.include? 'type'
						if vms['type'] == 'nginx'
							# start nginx
							machine.vm.provision 'shell' do |s|
								s.path = script_dir + '/features/nginx.sh'
							end

							machine.vm.provision 'shell' do |s|
                                s.path = script_dir + '/clear-nginx.sh'
                            end

                            # Clear any Homestead sites and insert markers in /etc/hosts
                            machine.vm.provision 'shell' do |s|
                                s.path = script_dir + '/hosts-reset.sh'
                            end

                            # Create any Homestead sites
							vms['proxys'].each do |proxy|
							    proxys = ''
							    proxy['site'].each do |site|
							        machine.vm.provision 'shell' do |s|
							            s.path = script_dir + "/hosts-add.sh"
							            s.args = [site['to'], site['send']]
                                    end
                                    proxys += 'server ' + site['send'] + ';'
							    end

								# Create load balancing
                                machine.vm.provision 'shell' do |s|
                                	s.name = 'Load balancing:' + proxys
                                	s.path = script_dir + '/sites/nginx.sh'
                                	s.args = [proxy['map'], proxys]
                                end
							end

						elsif vms['type'] == 'apache'
							# start apache
							machine.vm.provision 'shell' do |s|
								s.path = script_dir + '/features/apache.sh'
							end

							machine.vm.provision 'shell' do |s|
                                s.path = script_dir + '/clear-apache.sh'
                            end

							vms['sites'].each do |site|
                                machine.vm.provision 'shell' do |s|
                                    s.name = 'Creating Site: ' + site['map']

                                    # Convert the site & any options to an array of arguments passed to the
                                    # specific site type script (defaults to laravel)
                                    s.path = script_dir + "/sites/apache.sh"
                                    s.args = [
                                        site['map'],                # $1
                                        site['to'],                 # $2
                                        '80',                       # $3
                                    ]

                                    # generate pm2 json config file
                                    # if site['pm2']
                                    #     machine.vm.provision "shell" do |s2|
                                    #         s2.name = 'Creating Site Ecosystem for pm2: ' + site['map']
                                    #         s2.path = script_dir + "/create-ecosystem.sh"
                                    #         s2.args = Array.new
                                    #         s2.args << site['pm2'][0]['name']
                                    #         s2.args << site['pm2'][0]['script'] ||= "npm"
                                    #         s2.args << site['pm2'][0]['args'] ||= "run serve"
                                    #         s2.args << site['pm2'][0]['cwd']
                                    #     end
                                    # end

                                end
                            end
						elsif vms['type'] == 'database'
							# start database
							machine.vm.provision 'shell' do |s|
								s.path = script_dir + '/features/database.sh'
							end

							# create databases
							if vms.has_key?('databases')
							    vms['databases'].each do |db|
                                    machine.vm.provision 'shell' do |s|
                                        s.name = 'Creating MySQL Database: ' + db
                                        s.path = script_dir + '/create-mysql.sh'
                                        s.args = [db]
                                    end
                                end
							end
						end
					else
						puts 'Check your Cluster.yaml file, you have no type specified'
						exit
					end

					# Configured Shared Folders
					if vms.has_key?('folders')
						vms['folders'].each do |folder|
							# Judge path
							if File.exist? File.expand_path(folder['map'])
								mount_opts = []

								if ENV['VAGRANT_DEFAULT_PROVIDER'] == 'hyperv'
									folder['type'] = 'smb'
								end

								if folder['type'] == 'nfs'
									mount_opts = folder['mount_options'] ? folder['mount_options'] : ['actimeo=1', 'nolock']
								elsif folder['type'] == 'smb'
									mount_opts = folder['mount_options'] ? folder['mount_options'] : ['vers=3.02', 'mfsymlinks']

									smb_creds = {smb_host: folder['smb_host'], smb_username: folder['smb_username'], smb_password: folder['smb_password']}
								end

								# For b/w compatibility keep separate 'mount_opts', but merge with options
								options = (folder['options'] || {}).merge({ mount_options: mount_opts }).merge(smb_creds || {})

								# Double-splat (**) operator only works with symbol keys, so convert
								options.keys.each{|k| options[k.to_sym] = options.delete(k) }

								machine.vm.synced_folder folder['map'], folder['to'], type: folder['type'] ||= nil, **options
							else
								puts 'Check your Cluster.yaml file, the path to your folders map does not exist'
								exit
							end
						end
					end

				end
			else
				puts 'Check your Cluster.yaml file, you have no name specified'
				exit
			end

		end
	end
end