# = Class: magento::params
#
# This class does stuff that you describe here.
# Change Class to Define if needed.
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
class magento::params {
  $download_directory_tree = [
    '/var',
    '/var/cache',
    '/var/cache/magento',
    '/var/cache/magento/download',
  ]
  $download_directory = '/var/cache/magento/download'

  # default settings for magento
  $locale = 'en_US'
  $timezone = 'UTC'
  $currency = 'USD'

  case $::operatingsystem {
    'Fedora', 'CentOS', 'RedHat': {
      $document_root = '/var/www/html'
    }
    default: {
      $document_root = '/var/www/html'
    }
  }
}
