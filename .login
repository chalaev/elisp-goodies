

emacs_detected=-1

# Unless emacs is already launched, let us start it:

for PIDfile in /tmp/emacs-*.pid; do
    if [ $emacs_detected -ge 0 ]; then
	echo "erasing extra PID file"
	rm -f $PIDfile
    else
	if `kill -s 0 $pid`; then
	    emacs_detected=0
	    echo "emacs detected!"
	else
	    echo "erasing invalid PID file"
	    rm -f $PIDfile
	fi
    fi
done

# Note, however that we did not check the process owner.
# (But this is probably not needed for personal computers.)

if [ $emacs_detected -lt 0 ]; then
    echo "launching emacs"
    emacs --daemon
fi
