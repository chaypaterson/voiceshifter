#!/bin/bash

create_sink () {
    pactl load-module module-null-sink
    echo $? | sed -n 's/0/Virtual microphone created./p'
}

destroy_sink () {
    pactl unload-module module-null-sink
    echo $? | sed -n 's/0/Virtual microphone destroyed./p'
}

sox_pitch_shift () {
    echo "Shifting by $1 Hz... Press Ctrl-C to cancel."
    echo "Go to 'Recording' in PulseAudio Volume Control to switch an
    application to 'Monitor of null output'."
    sox -t pulseaudio default -t pulseaudio null pitch $1
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
        echo "Normal mode:"
        echo "First, create a virtual microphone with:"
        echo "  ./voiceshifter.sh create"
        echo ""
        echo "Then, shift its frequency with"
        echo "  ./voiceshifter.sh shift"
        echo "and enter a frequency change when prompted."
        echo ""
        echo "Once active, open PulseAudio Volume Control."
        echo "Go to the 'Recording' tab in PulseAudio Volume Control 
        and switch an application to 'Monitor of null output'. The application
        should now be using the pitch-shifted virtual microphone."
        echo ""
        echo "After cancelling a 'shift' command, the virtual microphone
        should be muted. A different pitch shift can be started by running"
        echo "  ./voiceshifter.sh shift"
        echo "again."
        echo ""
        echo "Once finished, run"
        echo "  ./voiceshifter.sh destroy"
        echo "to destroy the virtual microphone."
        echo ""
        echo "Quick mode:"
        echo "The above can be done in a one-shot mode with the command:"
        echo "  ./voiceshifter.sh quick DFREQ"
        echo "where DFREQ is, e.g. -550."
        ;;

    *)
        echo "Options:"
        echo "  ./voiceshifter.sh create"
        echo "  ./voiceshifter.sh shift"
        echo "  ./voiceshifter.sh destroy"
        echo "  ./voiceshifter.sh quick DFREQ"
        echo "  ./voiceshifter.sh help"
        ;;
esac

exit
