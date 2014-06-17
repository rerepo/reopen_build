function hmm()
{
    echo "
Invoke $ source build/envsetup.sh from your shell to add the following functions to your environment:
- mm:      Builds all of the modules in the current directory, but not their dependencies."
}

function gettop()
{
    #local TOPFILE=build/core/envsetup.mk
    local TOPFILE=build/core/root.mk

    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                \cd ..
                T=`PWD= /bin/pwd`
            done
            \cd $HERE
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}

export EXPORT_TOP=$(gettop)
export BUILD_MAIN=${EXPORT_TOP}/build/core/main.mk

function mm()
{
    #local T=$(gettop)
    #make -C $T -f build/core/main.mk
    make -f Modules.mk
}

