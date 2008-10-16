module PoolParty
  class Base
    plugin :heartbeat do
      
      def enable
        execute_if("$hostname", "master") do
          has_package(:name => "heartbeat-2", :ensure => "installed")
          has_service(:name => "heartbeat", :hasstatus => true) do
            ensures "running"
          end
        
          has_exec(:name => "heartbeat-update-cib", :command => "/usr/sbin/cibadmin -R -x /etc/ha.d/cib.xml", :refreshonly => true)
        
          # variables for the templates
          variable(:name => "ha_nodenames", :value => 'generate(". /etc/profile && server-list-active -c name")')
          variable(:name => "ha_node_ips",  :value => 'generate(". /etc/profile && server-list-active -c ip")')
          
          has_variable({:name => "ha_timeout",  :value => (self.respond_to?(:timeout) ? timeout : "5s")})
          has_variable({:name => "ha_port", :value => (self.respond_to?(:port) ? port : Base.port)})
          
          # These can also be passed in via hash
          has_remotefile(:name => "/etc/ha.d/ha.cf") do
            mode 444
            requires 'Package["heartbeat-2"]'
            notify 'Service["heartbeat"]'
            template File.join(File.dirname(__FILE__), "..", "templates/ha.cf")
          end
        
          has_remotefile(:name => "/etc/ha.d/authkeys") do
            mode 400
            requires 'Package["heartbeat-2"]'
            notify 'Service["heartbeat"]'
            template File.join(File.dirname(__FILE__), "..", "templates/authkeys")
          end
        
          has_remotefile(:name => "/etc/ha.d/cib.xml") do
            mode 444
            requires 'Package["heartbeat-2"]'
            notify 'Exec["heartbeat-update-cib"]'
            template File.join(File.dirname(__FILE__), "..", "templates/cib.xml")
          end
          
        end
        
        execute_if("$hostname", "master") do
          if list_of_node_names.size > 1
            has_exec(:name => "update pem for heartbeat", :refreshonly => true) do
              command "scp /etc/puppet/ssl/ca/ca_crl.pem #{user || Base.user}@#{list_of_node_ips[1]}:/etc/puppet/ssl/ca"
            end
          end
        end
        
      end
    end  
  end
end