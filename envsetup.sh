# static var
#TOP=

function hmm()
{
    echo "
Invoke $ source build/envsetup.sh from your shell to add the following functions to your environment:
- mm:      Builds all of the modules in the current directory, but not their dependencies."
}

function gettop()
{
    local TOPFILE=build/core/envsetup.mk
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

function croot()
{
    T=$(gettop)
    if [ "$T" ]; then
        \cd $(gettop)
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function findmakefile()
{
    TOPFILE=build/core/envsetup.mk
    local HERE=$PWD
    T=
    while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
        T=`PWD= /bin/pwd`
        if [ -f "$T/Modules.mk" ]; then
            echo $T/Modules.mk
            \cd $HERE
            return
        fi
        \cd ..
    done
    \cd $HERE
}

function mm()
{
    echo "CMD_ARGS=$@"

    #local T=$(gettop)
    #make -C $T -f build/core/main.mk


    # If we're sitting in the root of the build tree, just do a
    # normal make.
    if [ -f build/core/envsetup.mk -a -f Makefile ]; then
        make $@
    else
        # Find the closest Android.mk file.
        T=$(gettop)
        local M=$(findmakefile)

        # Remove the path to top as the makefilepath needs to be relative
        local M=`echo $M|sed 's:'$T'/::'`

        if [ ! "$T" ]; then
            echo "Couldn't locate the top of the tree.  Try setting TOP."
        elif [ ! "$M" ]; then
            echo "Couldn't locate a makefile from the current directory."
        else
            ONE_SHOT_MAKEFILE=$M make -C $T -f build/core/main.mk $@
        fi
    fi
}

#export EXPORT_TOP=$(gettop)
#export BUILD_MAIN=${EXPORT_TOP}/build/core/main.mk

