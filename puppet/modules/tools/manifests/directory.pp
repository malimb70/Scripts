# To create specific directory (NB)
class tools::directory (
    $directories    = undef,
    $owner          = 'www-data',
    $group          = 'www-data',
    $is_directory   = true,
    $mode           = 755,
    $content        = undef,
    $recurse        = true
) {
    define directory_create() {
        file { $name:
            owner   => $owner,
            group   => $group,
            recurse => $recurse,
            force   => true,
            ensure  => $is_directory ? {
                true     => directory,
                false    => file,
                default  => directory,
            },
            mode    => $mode,
            content => $is_directory ? {
                false   => template("$content"),
                true    => $content,
                default => $content,
	    },
        }
    }
    directory_create{ $directories: }
}

