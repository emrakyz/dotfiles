#!/bin/dash

dmenu() {
    rofi -dmenu -l $1 -p "$2"
}

mode=$(echo "What is A% of B?
A is What % of B?
What is the Percentage Increase/Decrease from A to B?
What If the Number A is Increased/Decreased by B%?" | dmenu 4 "Calculation Method:")

calculate_and_fix() {
    bc -ql | sed 's/0*$//;s/\.$//'
}

case "$mode" in
    "What is A% of B?")
        a=$(dmenu 0 "Enter A (the percentage):")
        b=$(dmenu 0 "Enter B (the total):")
        result=$(echo "($a/100)*$b" | calculate_and_fix)
        rofi -e "$result"
        ;;

    "A is What % of B?")
        a=$(dmenu 0 "Enter A (the part):")
        b=$(dmenu 0 "Enter B (the whole):")
        result=$(echo "($a/$b)*100" | calculate_and_fix)
        rofi -e "${result}%"
        ;;

    "What is the Percentage Increase/Decrease from A to B?")
        a=$(dmenu 0 "Enter the initial value (A):")
        b=$(dmenu 0 "Enter the new value (B):")
        result=$(echo "(($b-$a)/$a)*100" | calculate_and_fix)
        rofi -e "${result}%"
        ;;

    "What If the Number A is Increased/Decreased by B%?")
        a=$(dmenu 0 "Enter the number (A):")
        b=$(dmenu 0 "Enter the percentage increase/decrease (B%):")
        result=$(echo "$a + ($a*$b/100)" | calculate_and_fix)
        rofi -e "$result"
        ;;

    *[0-9]*[\+\-\*/]*|*[\+\-\*/]*[0-9]*)
	kitty --title "Calc-kitty" sh -c '
	colorize_output() {
	    while IFS= read -r line; do
		echo "\033[1;35m$line\033[0m"
	    done
	}
	echo '\'$mode\'' | bc -ql | colorize_output; bc -ql | colorize_output'
	;;
esac
