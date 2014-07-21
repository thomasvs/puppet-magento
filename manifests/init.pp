# = Class: magento
#
# This class does stuff that you describe here.
# Change Class to Define if needed.
#
# == Requirements:
#
# - This module requires
#   - the puppetlabs mysql module
#   - the thias php module
#   - php::ini call for /etc/php.ini
#
# == Parameters
#
# [* ensure *]
#   What state to ensure for the module.
#   Default: present
#
# == Variables
#
#   [* admin_password *]
#     must contain letters and numbers and be at least 7 characters long
#
# == Examples
#
# == Author
#
define magento (
  $version = $title,
  $db_pass,
  $admin_firstname,
  $admin_lastname,
  $admin_email,
  $admin_username = 'admin',
  $admin_password,
) {
  magento::install::tarball { $version: }
  magento::config { $version:
    db_pass         => $db_pass,
    admin_firstname => $admin_firstname,
    admin_lastname  => $admin_lastname,
    admin_email     => $admin_email,
    admin_username  => $admin_username,
    admin_password  => $admin_password,
  }
}
