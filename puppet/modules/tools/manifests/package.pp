## Use this class to either install or ensure purged for a list of packages. (NB)

class tools::package (
    $install_list   = undef,
    $purge_list     = undef
) {

    ## Install an array of packages in $install_list
    if $install_list {
        package { $install_list:
            ensure  => installed,
        }
    }

    ## Purge the list of packages in $purge_list
    if $purge_list {
        package { $purge_list:
            ensure  => purged,
        }
    }
}

