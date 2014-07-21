# = Class: magento::install::tarball
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
define magento::install::tarball (
  $version = $title
) {

  include magento::params
  include magento::install

  # exec commands inspired by
  # https://github.com/guewen/vagrant-eshop-lab/blob
  $magento_dir = "${magento::params::document_root}/magento-${version}"

  $assets_url = 'http://www.magentocommerce.com/downloads/assets'
  $targz = "magento-${version}.tar.gz"

  exec { "download-magento-${version}":
    cwd     => $magento::params::download_directory,
    command => "/usr/bin/wget ${assets_url}/${version}/${targz}",
    creates => "${magento::params::download_directory}/${targz}",
  }

  exec { "untar-magento-${version}":
    cwd     => $magento::params::document_root,
    command => "/bin/tar xvzf /tmp/${targz}",
    require => [
      Exec["download-magento-${version}"],
    ],
    creates => $magento_dir,
  }

  exec { "setting-permissions-${version}":
    cwd     => $magento_dir,
    command => "/bin/chmod 550 mage; /bin/chmod o+w var var/.htaccess app/etc; /bin/chmod -R o+w media",
    require => Exec["untar-magento-${version}"],
  }

}
