class pacemaker::corosync($cluster_name, $cluster_members) inherits pacemaker {

    firewall { '001 corosync mcast':
      proto  => 'udp',
      dport  => ['5404', '5405'],
      action => 'accept',
    }

    exec {"Set password for hacluster user on $cluster_name":
      command => "/bin/echo CHANGEME | /usr/bin/passwd --stdin hacluster",
      creates => "/etc/cluster/cluster.conf",
      require => Class["::pacemaker::install"],
    }

    exec {"Create Cluster $cluster_name":
      creates => "/etc/cluster/cluster.conf",
      command => "/usr/sbin/pcs cluster setup --name $cluster_name $cluster_members",
      require => Class["::pacemaker::install"],
    }

    exec {"Start Cluster $cluster_name":
      unless => "/usr/sbin/pcs status > /dev/null 2>&1",
      command => "/usr/sbin/pcs cluster start",
      require => Exec["Create Cluster $cluster_name"],
    }
}
