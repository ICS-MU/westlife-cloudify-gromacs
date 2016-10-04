class gromacs::install {
  require ::apache

  file { '/var/www/html/index.html':
    ensure  => file,
    source  => 'puppet:///modules/gromacs/index.html',
  }
}
