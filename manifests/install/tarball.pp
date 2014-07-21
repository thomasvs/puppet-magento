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

  exec { "magento-download-${version}":
    cwd     => $magento::params::download_directory,
    command => "/usr/bin/wget ${assets_url}/${version}/${targz}",
    creates => "${magento::params::download_directory}/${targz}",
  }

  exec { "magento-untar-${version}":
    cwd     => $magento::params::document_root,
    command => "/bin/tar xvzf ${magento::params::download_directory}/${targz}; mv magento magento-${version}; chown -R root:root magento-${version}",
    require => [
      Exec["magento-download-${version}"],
    ],
    creates => $magento_dir,
  }

  exec { "magento-permissions-${version}":
    cwd     => $magento_dir,
    command => '/bin/chmod -R o+w media',
    require => Exec["magento-untar-${version}"],
    unless  => '/bin/bash -c "test `stat -c %a media` -eq 777"'
  }

  file { "${magento_dir}/mage":
    ensure  => present,
    mode    => '0550',
    require => Exec["magento-untar-${version}"],
  }

  file { "${magento_dir}/var/.htaccess":
    ensure  => present,
    mode    => '0666',
    require => Exec["magento-untar-${version}"],
  }


  # FIXME: can we tighten these?
  file { [
    "${magento_dir}/var",
    "${magento_dir}/app/etc",
    "${magento_dir}/app/media",
    ]:
    ensure  => directory,
    mode    => '0777',
    require => Exec["magento-untar-${version}"],
  }
}
