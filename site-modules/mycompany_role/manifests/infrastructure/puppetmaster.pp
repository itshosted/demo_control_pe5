# == mycompany_role::infrastructure::puppetmaster
#
# This a business role for:
# application_name: infrastructure
# application_role: puppetmaster
#
class mycompany_role::infrastructure::puppetmaster {

  case $facts['os']['family'] {

    'RedHat': {
      include mycompany_profile::infrastructure::puppetmaster
    }

    default: {
      fail("OS ${facts['operatingsystem']}${facts['operatingsystemrelease']} is not supported!")
    }
  }

}
