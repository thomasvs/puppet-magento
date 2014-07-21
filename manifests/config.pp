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
) {

  include magento::params
  $root_document = "${magento::params::document_root}/magento-${version}"

  exec { "install-magento-${version}":
    cwd     => $root_document,
    creates => "$root_document/app/etc/local.xml",
    command => '/usr/bin/php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Los_Angeles" \
    --default_currency "EUR" \
    --db_host "localhost" \
    --db_name "magentodb" \
    --db_user "magento" \
    --db_pass "secret" \
    --url "${lucid32_base::site_url}" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "${lucid32_base::site_url}" \
    --use_secure_admin "no" \
    --skip_url_validation "yes" \
    --admin_firstname "Store" \
    --admin_lastname "Owner" \
    --admin_email "${lucid32_base::eshop_admin_email}" \
    --admin_username "${lucid32_base::eshop_admin_login}" \
    --admin_password "${lucid32_base::eshop_admin_password}"',
    require => [
      Magento::Install::Tarball[$version],
#      Exec["create-magentodb-db"],
      Package["php"]
    ],
  }

  
 
  
}
