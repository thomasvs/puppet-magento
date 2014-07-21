# = Class: magento::config
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
define magento::config (
  $version = $title,
  $db_host = 'localhost',
  $db_name = undef,
  $db_user = undef,
  $db_pass,
  $url = "magento-${version}",
  $admin_firstname,
  $admin_lastname,
  $admin_email,
  $admin_username = 'admin',
  $admin_password,
) {

  include php::cli
  include mysql::server

  include magento::params



  if ($db_name) {
    $real_db_name = $db_name
  } else {
    $real_db_name = "magento-${version}"
  }
  # mysql::db cannot deal with the same user being reused
  if ($db_user) {
    $real_db_user = $db_user
  } else {
    $real_db_user = "magento-${version}"
  }


  $magento_dir = "${magento::params::document_root}/magento-${version}"

  exec { "install-magento-${version}":
    cwd     => $magento_dir,
    creates => "${magento_dir}/app/etc/local.xml",
    command => "/usr/bin/php -f install.php -- \
    --license_agreement_accepted 'yes' \
    --locale '${magento::params::locale}' \
    --timezone '${magento::params::timezone}' \
    --default_currency '${magento::params::currency}' \
    --db_host '${db_host}' \
    --db_name '${real_db_name}' \
    --db_user '${real_db_user}' \
    --db_pass '${db_pass}' \
    --url '${url}' \
    --use_rewrites 'yes' \
    --use_secure 'no' \
    --secure_base_url '${url}' \
    --use_secure_admin 'no' \
    --skip_url_validation 'yes' \
    --admin_firstname '${admin_firstname}' \
    --admin_lastname '${admin_lastname}' \
    --admin_email '${admin_email}' \
    --admin_username '${admin_username}' \
    --admin_password '${admin_password}' \
    ",
    require => [
      Magento::Install::Tarball[$version],
      Mysql::Db[$real_db_name],
#      Exec["create-magentodb-db"],
      Class['php::cli'],
    ],
  }

  mysql::db { $real_db_name:
    user     => $real_db_user,
    password => $db_pass,
    host     => $db_host,
    grant    => [ 'all' ],
  }

#  database_grant { "${real_db_user}@${db_host}/${real_db_name}":
#    privileges => [ 'all' ]
#  }
}

