#!/bin/bash

# Check if sox exists
if ! command -v sox
then
    echo "Sox not found"
    exit
fi

create_sink () {
    pactl load-module module-null-sink
    echo $? | sed -n 's/0/Virtual microphone created./p'
}

destroy_sink () {
    pactl unload-module module-null-sink
    echo $? | sed -n 's/0/Virtual microphone destroyed./p'
}

sox_pitch_shift () {
    echo "Shifting by $1 cents... Press Ctrl-C to cancel."
    echo "Go to 'Recording' in PulseAudio Volume Control to switch an
    application to 'Monitor of null output'."
    sox -t pulseaudio default -t pulseaudio null pitch $1
}

print_help () {
    cat << EOF
Normal mode:
------------

First, create a virtual microphone with:
  ./voiceshifter.sh create

Then, shift its frequency with
  ./voiceshifter.sh shift
and enter a frequency change when prompted. A recording dialog should now
appear.

Once active, open PulseAudio Volume Control.

Go to the 'Recording' tab in PulseAudio Volume Control and switch an
application to 'Monitor of null output'. The application should now be using
the pitch-shifted virtual microphone.

After cancelling a 'shift' command with Ctrl-C, the virtual microphone should
be muted. A different pitch shift can be started by running:
  ./voiceshifter.sh shift
again.

Once finished, run
  ./voiceshifter.sh destroy
to destroy the virtual microphone.

Quick mode:
-----------

The above can be done in a one-shot mode with the command:
  ./voiceshifter.sh quick SHIFT
where SHIFT is the shift in 1/100ths of a semitone, e.g. -550. The command is
cancelled (and virtual mic destroyed) with Ctrl-C.
EOF
}

case $1 in
    create)
        create_sink
        ;;

    destroy)
        destroy_sink
        ;;

    shift)
        echo "Enter frequency:"
        read FREQ
        sox_pitch_shift $FREQ
        ;;

    quick)
        create_sink
        sox_pitch_shift $2
        destroy_sink
        ;;

    help)
        print_help
        ;;

    *)
        echo "Options:"
        echo "  ./voiceshifter.sh create"
        echo "  ./voiceshifter.sh shift"
        echo "  ./voiceshifter.sh destroy"
        echo "  ./voiceshifter.sh quick SHIFT"
        echo "  ./voiceshifter.sh help"
        ;;
esac

exit
