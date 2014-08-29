# = Class: magento::install
#
# This class sets up everything needed to be able to install magento.
#
# == Requirements:
#
# - This module requires
#
# == Parameters
#
# [* ensure *]
#   What state to ensure for the module.
#   Default: present
#
# == Variables
#
# == Examples
#
# == Author
#
class magento::install {

  include magento::params

  file { $magento::params::download_directory_tree:
    ensure => directory
  }

  # for magento's php installation script
  package { [
    'php-mysql',
    'php-mcrypt',
    # without this, magento 500's on generating the src tag for the first
    # image on the product page
    'php-gd',
  ]:
    ensure => installed
  }

}
