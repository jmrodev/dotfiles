function y -d "Abre yazi y deja la shell en el directorio donde saliste"
    set -l tmp (mktemp -t yazi-cwd.XXXXXX); or return 1

    command yazi $argv --cwd-file=$tmp

    set -l cwd (string collect <$tmp)
    command rm -f -- $tmp

    if test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        # builtin: tu cd esta aliasado a z (zoxide), esto salta el alias
        builtin cd -- $cwd
    end
end
