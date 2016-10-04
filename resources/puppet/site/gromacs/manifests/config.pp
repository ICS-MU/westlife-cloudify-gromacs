class gromacs::config {
  Cron {
    user        => 'root',
    environment => 'MAILTO=holer@ics.muni.cz',
  }

  cron { 'gromacs_script1':
    command     => '/bin/true',
    hour        => 4,
    minute      => 4,
  }

  cron { 'gromacs_script2':
    command     => '/bin/true',
    hour        => 4,
    minute      => 5,
  }

  cron { 'gromacs_script3':
    command     => '/bin/true',
    hour        => 4,
    minute      => 5,
  }
}
