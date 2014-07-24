# = Define: magento::modman::install
#
# This define installs modman
#
# == Variables
#
# == Examples
#
# == Author
#
class magento::modman::install (
) {
  $url = ' https://raw.github.com/colinmollenhour/modman/master/modman'
  $path = '/usr/local/bin/modman'

  # raw.github.com points to a server that thinks it's github.com
  exec { 'modman-install':
    command => "/usr/bin/wget --no-check-certificate -O ${path} ${url}",
    creates => $path,
#    require => Package['wget'],
  }

  file { $path:
    mode    => '0755',
    require => Exec['modman-install'],
  }
}
