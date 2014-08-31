# = Define: magento::modman::deploy
#
# This define deploys a magento module using modman.
# Currently this only supports deploying from a git repository.
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
  $module_git_commit = 'origin/master',
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

  git::checkout { "modman-deploy-git-checkout-${magento_root}-${module_name}":
    directory        => "${magento_root}/.modman",
    checkoutdir      => $module_name,
    repository       => $module_git_url,
    commit           => $module_git_commit,
    commit_file      => "${module_name}.commit",
    user             => 'www',
    #    manage_directory => false,
    require          => [
      Exec["modman-deploy-clone-${magento_root}-${module_name}"]
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
