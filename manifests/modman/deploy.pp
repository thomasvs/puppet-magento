# = Define: magento::modman::deploy
#
# This define deploys a magento module using modman.
#
# == Requirements:
#
# - This module requires magento::modman::install
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
define magento::modman::deploy (
  $magento_root,
  $module_name,
  $module_git_url,
) {

  exec { "modman-deploy-init-${magento_root}-${module_name}":
    cwd     => $magento_root,
    user    => 'www',
    command => '/usr/local/bin/modman init',
    creates => "${magento_root}/.modman",
    require => File[$magento_root]
  }

  exec { "modman-deploy-clone-${magento_root}-${module_name}":
    cwd     => $magento_root,
    user    => 'www',
    command => "/usr/local/bin/modman clone ${module_name} ${module_git_url}",
    creates => "${magento_root}/.modman/${module_name}",
    require => [
      Exec["modman-deploy-init-${magento_root}-${module_name}"]
    ]
  }

  exec { "modman-deploy-deploy-${magento_root}-${module_name}":
    cwd     => $magento_root,
    user    => 'www',
    command => "/usr/local/bin/modman deploy ${module_name}",
    require => [
      Exec["modman-deploy-clone-${magento_root}-${module_name}"]
    ]
  }

}
