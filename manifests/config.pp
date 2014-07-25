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
# [* web_method *]
#   If set to apache, generates container-magento-${version}.inc files
#   under the apache config directory to be included by configuration
#
# == Variables
#
# == Examples
#
# == Author
#
define magento::config (
  $version = undef,
  $db_host = 'localhost',
  $db_name = undef,
  $db_user = undef,
  $db_pass,
  $url = undef,
  $admin_firstname,
  $admin_lastname,
  $admin_email,
  $admin_username = 'admin',
  $admin_password,
  $web_method = 'apache',
) {

  # handle input variables
  if (!$url) {
    $real_url = inline_template(
      '<%= "magento-" + @version.gsub(".", "_") + ".localdomain" %>')
  } else {
    $real_url = $url
  }

  if ($version) {
    $real_version = $version
    $real_title = $title
  } else {
    $real_version = $title
    $real_title = "magento-${title}"
  }

  if ($db_name) {
    $real_db_name = $db_name
  } else {
    $real_db_name = $real_title
  }
  # mysql::db cannot deal with the same user being reused
  if ($db_user) {
    $real_db_user = $db_user
  } else {
    $real_db_user = $real_title
  }


  include php::cli
  include mysql::server

  include magento::params




  $magento_dir = "${magento::params::document_root}/${real_title}"

  exec { "magento-install-${real_title}":
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
    --url '${real_url}' \
    --use_rewrites 'yes' \
    --use_secure 'no' \
    --secure_base_url '${real_url}' \
    --use_secure_admin 'no' \
    --skip_url_validation 'yes' \
    --admin_firstname '${admin_firstname}' \
    --admin_lastname '${admin_lastname}' \
    --admin_email '${admin_email}' \
    --admin_username '${admin_username}' \
    --admin_password '${admin_password}' \
    ",
    # this can take a while, so it timed out on my host with 300
    timeout => 1800,
    require => [
      Magento::Install::Tarball[$title],
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

  if ($web_method == 'apache') {
    # deploy container for magento
    apache_httpd::file { "container-${real_title}.inc":
      ensure  => file,
      content => template('magento/apache/container/magento.inc.erb'),
    }

  }
}

