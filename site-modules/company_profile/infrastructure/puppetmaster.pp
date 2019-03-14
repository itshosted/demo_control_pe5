#
class mycompany_profile::infrastructure::puppetmaster {

  class { 'puppetdb':
    listen_address  => 'puppetmaster.example.com',
    manage_firewall => false,
  }
  class { 'puppetdb::master::config':
    manage_report_processor => true,
    enable_reports          => true,
  }

  # Configure Apache on this server
  class { 'apache':
    purge_configs => true,
    mpm_module    => 'prefork',
    default_vhost => true,
    default_mods  => false,
  }
  class { 'apache::mod::wsgi': }

  # Configure Puppetboard
  class { 'puppetboard':
    puppetdb_host     => $facts['ipaddress'],
    manage_git        => true,
    manage_virtualenv => false,
  }

  # Access Puppetboard through
  class { 'puppetboard::apache::vhost':
    vhost_name => 'puppetmaster.example.com',
    port       => 80,
  }

}
