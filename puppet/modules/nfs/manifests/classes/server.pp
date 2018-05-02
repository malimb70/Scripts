class nfs::server inherits nfs::base {
  service {"nfs":
    enable => "true",
    ensure => "running",
    require => [Package["portmap"], Package["nfs-utils"]],
  }

  exec {"reload_nfs_srv":
    command => "exportfs -av",
  }
}
