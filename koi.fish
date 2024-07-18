#!/usr/bin/env fish
# koi creates functions from one-liners
# and has "workspaces" to organize them

# :a [function_name] [description] -- add last executed command to koi functions
# koi [command] [args...] -- execute a koi command

function _koi_help -d "get help with koi"
	echo " :a <name> <description>  : convert last executed command into function"
	echo " koi ws [name]            : create/switch workspace"
	echo " koi ls                   : list functions"
	echo " koi lsws                 : list workspaces"
	echo " koi cat  <function>      : display function source"
	echo " koi ed   <function>      : edit a function file"
	echo " koi rm   <function>      : delete a function"
	echo " koi rmws <workspace>     : delete entire workspace"
	echo " koi help                 : show this text"
	echo " koi man                  : verbose guide"
	echo 
	echo " koi collect <outfile> [entry_function] : collect ws into single file"
	echo 
	echo " current workspace: $KOI_FUNCTION_DIR"
end

function _koi_watch_cmd --on-event fish_postexec -d "watch the command line executions"
	set -gx KOI_LAST_COMMAND "$argv[1]"
end

function _koi_cat -d "_koi_cat <funcname> show the source for a custom function"
	if test -z "$argv[1]"
		echo I need a func name
	else
		_koi_startup
		cat "$KOI_FUNCTION_DIR"/"$argv[1]".fish
	end
end

function _koi_ed -d "_koi_ed <funcname> edit a function using $EDITOR"
	set -l ED "pico"

	if test -z "$argv[1]"
		echo what function?
		return -1
	end
	if test -n "$VISUAL"
		set  ED $VISUAL
	else if test -n "$EDITOR"
		set  ED $EDITOR
	end

	set fn "$KOI_FUNCTION_DIR"/"$argv[1]".fish
	$ED $fn
	source $fn
end

function _koi_rm -d "_koi_rm <funcname> delete a function"
	_koi_startup 
	if test -z "$argv[1]"
		echo I need a function to delete
	else
		if rm "$KOI_FUNCTION_DIR"/"$argv[1]".fish
			functions -e $argv[1]
			echo function $argv[1] deleted
		end
	end
end

function _koi_rmws -d "_koi_rmws [name] remove a workspace"
	if test -z "$argv[1]"
		echo no workspace name provided
	else
		set dir ~/.config/koi/functions/$argv[1]
		if test -e $dir
			set files "$dir"/*
			if test -n "$files"
				read -P "delete all files in $argv (y/n) ? " answer 
				if test $answer = 'y'
					rm -rf "$dir"
					echo "workspace $argv[1] removed"
				else
					echo "aborted."
				end
			else
				rmdir $dir
				echo "workspace $argv[1] removed"
			end
		else
			echo workspace "$argv[1]" doesn\'t exist.
		end
	end
end

function _koi_ls -d "list custom functions"
	for func in "$KOI_FUNCTION_DIR"/*.fish
		cat $func | grep -E '^function' | sed -e 's/^function//g'
	end
end

function _koi_lsws -d "list workspaces"
	for dir in ~/.config/koi/functions/*
		if test -d $dir
			echo " " (basename $dir)
		end
	end
end

function _koi_startup -d "startup koi by setting defaults if necessary"
	if test -z "$KOI_FUNCTION_DIR"
		_koi_ws default
	end
end

function _koi_source_global -d "source all files in ~/.config/koi/functions/global"
	mkdir -p ~/.config/koi/functions/global
	for file in ~/.config/koi/functions/global/*.fish
		source "$file"
	end
end

function _koi_ws -d "_koi_ws [name] set the current workspace"
	if test -n "$argv[1]"
		set -gx KOI_WORKSPACE $argv[1]
		set -gx KOI_FUNCTION_DIR ~/.config/koi/functions/"$argv[1]"
		mkdir -p "$KOI_FUNCTION_DIR"
		_koi_source_global
		for file in "$KOI_FUNCTION_DIR"/*.fish
			source "$file"
		end
	end 
	echo $KOI_FUNCTION_DIR
end

function _koi_collect -d "_koi_collect <outfile> [entry] collect all workspace functions into outfile and set entry function to entry"
	_koi_startup
	if test -z "$argv[1]"
		echo I need at least an outfile.
	else
		if test -z ( ls "$KOI_FUNCTION_DIR" | grep \.fish\$ | string collect )
			echo "nothing to collect in $KOI_FUNCTION_DIR"
		else
			echo "#!/usr/bin/env fish" > "$argv[1]" &&
			for f in "$KOI_FUNCTION_DIR"/*.fish
				echo >> "$argv[1]" && cat "$f" >> "$argv[1]"
			end && 
			if test -n "$argv[2]"
				echo \n"$argv[2] \$argv" >> "$argv[1]"
				chmod +x "$argv[1]"
			end
		end
	end
end

function _koi_koi -d "koi [command] [args...] execute a koi command"
_koi_startup
	switch $argv[1]
		case ls
			_koi_ls $argv[2..]
		case lsws
			_koi_lsws $argv[2..]
		case cat
			_koi_cat $argv[2..]
		case ed
			_koi_ed $argv[2..]
		case rm
			_koi_rm $argv[2..]
		case rmws
			_koi_rmws $argv[2..]
		case ws
			_koi_ws $argv[2..] 
		case collect
			_koi_collect $argv[2..]
		case help
			_koi_help $argv[2..]
		case man
			_koi_man $argv[2..]
		case ''
			_koi_help $argv[2..]
		case '*'
			echo unknown command \"$argv[1]\"
		end
end

function koi -d "koi [command] [args...] execute a koi command"
	_koi_koi $argv
end

# ":a" is the command to add your last executed command as a function
function :a -d ":a <funcname> <description> | add the last executed command to fish functions"
	_koi_startup
	set filen "$KOI_FUNCTION_DIR/$argv[1].fish"

	echo creating function

	echo function $argv[1] -d \"(echo $argv[2..-1])\" > $filen
	
	echo "$KOI_LAST_COMMAND" >> $filen
	echo end >> $filen

	echo saving function $argv[1] into $filen

	cat $filen | source

	cat $filen 1>&2 

end

function _koi_man -d "verbose help"
	set s "
	KOI GUIDE
	koi has two relevant commands:
	koi -- execute koi commands
	:a  -- create a function
	
	CONVERT ONE-LINERS TO FUNCTIONS
	:a <function_name> \"description\"
	
	This plucks the last line you executed and
	wraps it in a function called function_name with
	description \"description\".

	After that, you can simply type

	> function_name

	to execute your one-liner.

	You can then use your new function in
	later functions, and so on.

	Since one-liners don't actually accept 
	command line arguments until they become
	actual functions, you can fake an argv
	by modifying the environment variable
	during testing:

	> set argv Jiminy Cricket
	> echo Hello, \"\$argv\"!
	Hello, Jiminy Cricket!
	> :a sayhi \"sayhi [your name] say hello with name\"
	> sayhi Pinocchio
	Hello, Pinocchio!

	WORKSPACES
	Because assembling a lot of small functions can get
	complicated, koi provides workspaces.

	To create or change to a workspace:

	> koi ws my_workspace_name

	This creates a new folder called
	
	~/.config/koi/functions/my_workspace_name

	where all your newly created functions  will be stored.

	To list workspaces:
	> koi lsws

	A special workspace, \"global\", which exists 
	as \"~/.config/koi/functions/global\", 
	holds functions that are always ready to run
	regardless of workspace. 

	This allows you create tools that are generally useful.
	
	COLLECTING
	When you are ready to \"bundle\" all your functions into
	a single script:
	> koi collect script_filename my_entry_function

	This creates the file \"script_filename\" in the current
	directory (or path if provided) and inserts this text at 
	the end of the file:

	my_entry_function \$argv

	The end result is that my_entry_function becomes the first
	function to run when you execute the script.

	If you do not specify my_entry_function, the script will
	act more like a library of functions rather than an 
	executable script.

	NOTE: functions from the \"global\" workspace are NOT
	included in your collected script.
	"
	echo $s | less
end
