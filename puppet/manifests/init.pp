Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

exec { 'add-repo':
  command => 'sudo add-apt-repository -s "deb http://pride.aegis.cylab.cmu.edu/aegis/ trusty main" && wget -qO - http://pride.aegis.cylab.cmu.edu/aegis/aegis.gpg.key | sudo apt-key add -'
}

exec { 'get-deps':
  command => 'sudo apt-get build-dep -y bap-types bap-lifter qemu'
}

exec { 'bap-types':
  command => 'git clone https://github.com/BinaryAnalysisPlatform/bap-types && cd bap-types && ./configure && sudo make -j2 && sudo make install && cd ..',
  creates => '/home/vagrant/bap-types'
}

exec { 'bap-lifter':
  command => 'git clone https://github.com/BinaryAnalysisPlatform/bap-lifter && cd bap-lifter && ./configure && sudo make -j2 && sudo make install && cd ..',
  creates => '/home/vagrant/bap-lifter'
}

exec { 'bap-traces':
  command => 'git clone https://github.com/BinaryAnalysisPlatform/bap-traces && cd bap-traces && ./configure && sudo make -j2 && sudo make install && cd ..',
  creates => '/home/vagrant/bap-traces'
}

#exec { 'tracer':
#  command => 'git clone https://github.com/BinaryAnalysisPlatform/qemu-tracer.git && cd qemu-tracer && git checkout --track origin/tracewrap && ./configure && sudo make -j2 && sudo make install && cd ..',
#  creates => '/home/vagrant/qemu-tracer'
#}



Exec['add-repo'] -> Exec['apt-get update'] -> Exec['get-deps']
Exec['get-deps'] -> Exec['bap-types']
Exec['get-deps'] -> Exec['bap-lifter']
Exec['get-deps'] -> Exec['bap-traces']
#Exec['get-deps'] -> Exec['tracer']
Exec['apt-get update'] -> Package <| |> # run before any package

exec { 'apt-get update':
  path => '/usr/bin',
}

# apt packages

package { 'vim':
  ensure => present,
}
package { 'emacs':
  ensure => present,
}
package { 'git':
  ensure => present,
}
package { 'opam':
  ensure => present,
}
package { 'm4':
  ensure => present,
}

# Manually-run install commands

exec { 'opam_init':
  command => 'opam init --auto-setup',
  environment => ['HOME=/home/vagrant'],
  creates => '/home/vagrant/.ocamlinit',
  cwd => '/home/vagrant',
  user => 'vagrant',
}
exec { 'opam_install':
  command => 'opam install -y ocp-indent',
  environment => ['HOME=/home/vagrant'],
#path => '/home/vagrant/.opam/system/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  user => 'vagrant',
}

#Package['g++-4.8'] -> Exec['opam_init']
#Package['gcc-4.8'] -> Exec['opam_init']
Package['m4'] -> Exec['opam_init']
Exec['get-deps'] -> Package['opam']
Package['opam'] -> Exec['opam_init']
Exec['opam_init'] -> Exec['opam_install']
#
#exec { 'pip_packages':
#  command => 'sudo pip install -U cython && sudo pip install pycapnp'
#}
#Exec['install_capnproto'] -> Exec['pip_packages']
#Package['python-pip'] -> Exec['pip_packages']

