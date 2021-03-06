# = Define: magento::install::tarball
#
# This define installs magento from a tarball.
# It installs a given version into a directory named after the title.
# If no version is passed, then the title is assumed to be the version
# and the directory will be magento- followed by the version name.
# If a version is passed, then the directory will be the title.
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
  $version = undef
) {

  if ($version) {
    $real_version = $version
    $dirname = $title
  } else {
    $real_version = $title
    $dirname = "magento-${title}"
  }

  include magento::params
  include magento::install

  # exec commands inspired by
  # https://github.com/guewen/vagrant-eshop-lab/blob
  $magento_dir = "${magento::params::document_root}/${dirname}"

  $assets_url = 'http://www.magentocommerce.com/downloads/assets'
  $targz = "magento-${real_version}.tar.gz"

  exec { "magento-download-${real_version}-for-${dirname}":
    cwd     => $magento::params::download_directory,
    command => "/usr/bin/wget ${assets_url}/${real_version}/${targz}",
    creates => "${magento::params::download_directory}/${targz}",
  }

  # we do this in the final directory so that selinux context gets set
  # correctly
  # we tell tar to unpack to the final dir, because magento tarballs by
  # default unpack to magento/ which could be the name of one of our installs
  exec { "magento-untar-${real_version}-to-${dirname}":
    cwd     => $magento::params::document_root,
    command => "/bin/tar xzf ${magento::params::download_directory}/${targz} --transform 's@magento@${dirname}@'; chown -R www:root ${magento_dir}",
    require => [
      Exec["magento-download-${real_version}-for-${dirname}"],
    ],
    creates => $magento_dir,
  }

  exec { "magento-permissions-${dirname}":
    cwd     => $magento_dir,
    command => '/bin/chmod -R go+w media',
    require => Exec["magento-untar-${real_version}-to-${dirname}"],
    unless  => '/bin/bash -c "test `stat -c %a media` -eq 777"'
  }

  file { "${magento_dir}/mage":
    ensure  => present,
    mode    => '0550',
    require => Exec["magento-untar-${real_version}-to-${dirname}"],
  }

  file { "${magento_dir}/var/.htaccess":
    ensure  => present,
    mode    => '0666',
    require => Exec["magento-untar-${real_version}-to-${dirname}"],
  }


  file { [
    $magento_dir,
    ]:
    ensure  => directory,
    owner   => 'www',
    require => Exec["magento-untar-${real_version}-to-${dirname}"],
  }

  # FIXME: can we tighten these?
  file { [
    "${magento_dir}/var",
    "${magento_dir}/app/etc",
    "${magento_dir}/app/media",
    ]:
    ensure  => directory,
    mode    => '0777',
    require => [
      File[$magento_dir],
      Exec["magento-untar-${real_version}-to-${dirname}"],
    ]
  }

  # indexer locks are saved in var/locks and should be apache-owned so apache
  # can manage them
  # avoids
  # Stock Status Index process is working now. Please try run this process
  # later.
  file { [
    "${magento_dir}/var/locks",
    ]:
    ensure  => directory,
    mode    => '0777',
    owner   => 'apache',
    group   => 'apache',
    require => [
      File["${magento_dir}/var"],
      Exec["magento-untar-${real_version}-to-${dirname}"],
    ]
  }
}
