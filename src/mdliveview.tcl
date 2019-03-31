#! /usr/bin/env tclsh

package require Tcl 8.6

lappend auto_path [pwd]

package require Tk
package require Markdown
package require Tkhtml
package require fileutil
package require Img
package require gifblock
package require struct::list

namespace import ::tcl::mathop::*

set APP_NAME mdliveview
set VERSION  1.0

proc main {} {
    if {[llength $::argv] != 1} {
	usage
	exit 0
    }
    set mdfilename [lindex $::argv 0]
    global reloading
    global APP_NAME
    global VERSION
    set reloading {1}
    pack [ttk::frame .frame] -fill both -expand 1
    grid [html .frame.html -imagecmd "load_image [file dirname $mdfilename]" -yscrollcommand ".frame.scroll set"] -row 0 -column 0 -sticky nsew
    grid [ttk::scrollbar .frame.scroll -command ".frame.html yview" -orient vertical] -row 0 -column 1 -sticky ns
    grid [ttk::checkbutton .frame.toggleReloading -text {Automatic reloading} -command "toggleReloading $mdfilename" -variable reloading] -columnspan 2
    grid rowconfigure .frame 0 -weight 1
    grid columnconfigure .frame 0 -weight 1

    wm title . "$APP_NAME $VERSION - $mdfilename"
    bind . <Key-Up> ".frame.html yview scroll -1 units"
    bind . <Key-Down> ".frame.html yview scroll  1 units" 
    bind . <Key-Prior> ".frame.html yview scroll -50 units"
    bind . <Key-Next> ".frame.html yview scroll  50 units" 
    bind . <Escape> {exit}
    draw_html $mdfilename
    toggleReloading $mdfilename
}

proc draw_html {filename} {
    apply {{html_data} {
	global MDLIVEVIEW_CSS
	set scroll_origin [.frame.scroll get]
	.frame.html reset
	.frame.html style $MDLIVEVIEW_CSS
	.frame.html parse $html_data
	.frame.scroll set {*}$scroll_origin
    }} [Markdown::convert [fileutil::cat $filename]]
}

proc toggleReloading {filename {last_mtime -}} {
    global reloading
    if {$reloading eq 0} {
	return
    }
    if {$last_mtime == "-"} {
	set last_mtime [file mtime $filename]
    } else {
	if {$last_mtime ne [file mtime $filename]} {
	    draw_html $filename
	    set last_mtime [file mtime $filename]
	}
    }
    after 500 toggleReloading $filename $last_mtime
}

proc usage {} {
    global APP_NAME
    global VERSION
    puts "$APP_NAME $VERSION"
    puts "By Géballin 2019"
    puts "Usage :"
    puts "\t$APP_NAME MARKDOWN_FILE"
}

proc load_image {path_arg imagename_arg} {
    set imagename [file join $path_arg $imagename_arg]
    if {[file extension $imagename] == ".gif"} {
	update_gif $imagename
    } else {
	image create photo -file $imagename
    }
}

proc update_gif {imagename {frame_nbr 0} {frames_delays ""}} {
    if {$frames_delays == ""} {
	set frames_delays [get_gif_delays $imagename]
    }
    if {$frame_nbr >= [llength $frames_delays]} {
	set frame_nbr 0
    }
    image create photo $imagename -file $imagename -format "gif -index $frame_nbr"
    if {[llength $frames_delays] > 1} {
	after [* 10 [lindex $frames_delays $frame_nbr]] "update_gif $imagename [incr frame_nbr] [list $frames_delays]"
    }
    return $imagename
}

proc get_gif_delays {image_name} {
    set image_nbr 0
    gifblock::gif.load gifvar $image_name
    # Get number of images in gif
    lmap elem [gifblock::gif.blocknames gifvar] {
	if {$elem == "Image Descriptor"} {
	    gifblock::gif.get gifvar {Graphic Control} [lindex $image_nbr[incr image_nbr; list]] "delay time"
	} else {
	    continue
	}
    }
}

set MDLIVEVIEW_CSS "
pre \{
    font-family: \"Courier 10 Pitch\", Courier, monospace;
    font-size: 95%;
    line-height: 140%;
    white-space: pre;
    white-space: pre-wrap;
    white-space: -moz-pre-wrap;
    white-space: -o-pre-wrap;

    height:1%;
    width: auto;
    display: block;
    clear: both;
    color: #555555;
    padding: 1em 1em;
    margin: auto 40px auto 40px;
    background: #f4f4f4;
    border: solid 1px #e1e1e1
\}

code \{
    font-family: Monaco, Consolas, \"Andale Mono\", \"DejaVu Sans Mono\", monospace;
    font-size: 95%;
    line-height: 140%;
    white-space: pre;
    white-space: pre-wrap;
    white-space: -moz-pre-wrap;
    white-space: -o-pre-wrap;
\}

\#content code \{
    display: block;
    padding: 0.5em 1em;
    border: 1px solid #bebab0;
\}
"

main
