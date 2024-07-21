# Koi
Koi turns your one-liners into functions. 

It's a fish shell script.

## Install
```
cp koi.fish ~/.config/fish/functions/
```

## Use
To activate koi in your current shell:
```
> koi
```

To create a function, first execute your one-liner, like this:
```
> echo Hello World!
```

Then make it a function with the `:a` command:
``` 
> :a hello_world "say hello to the world"
```

Finally, use your new function:
```
> hello_world
Hello World!
```

Your one-liner can be comprised of however many commands you like, including other functions. You can use control flow, etc. Anything you might do in a script.
```
> hello_world ; set hour ( date "+%H" ) ; if test $hour -gt 21 ; echo GET SOME SLEEP ; sleep 2 ; clear ; end
> :a self_care "say hello and perform some self-care."
```

`:a` is the command you will be using the most. It has a weird name to avoid conflicts and to be quick to type. "a" means "add function."

> Despite my calling them "one-liners" you can actually use mutliple lines to write your function, as long as it registers as a single fish command.

### What It Does
Koi keeps track of your last executed command (with an event handler). When you use `:a`, your latest command is wrapped in a function and saved inside the current workspace (by default : `~/.config/koi/functions/default` ).

For more help, type `koi help`, or if you're an avid reader: `koi man`.

### About $argv
Your one-liner can accept arguments, but only after it becomes a function. So you'll have to get a little hacky and manually `set argv` while you test your one-liner:

```
> set argv Jiminy Cricket
> echo Hello, $argv\!
Hello, Jiminy Cricket!
> :a say_hi "say_hi <name> say hi to someone"
```
but after it becomes a function, it recognizes any argument:
```
> say_hi Pinocchio
Hello, Pinocchio!
```

## Workspaces
Koi's optional workspaces are meant to reduce the (extreme) clutter of saving a bunch of one-liners into `~/.config/fish/functions`. Each new function is instead saved into the active koi workspace, e.g. `~/.config/koi/functions/my_workspace`.

This allows you to work on ad-hoc projects without worry — just delete the workspace when you're done.

For convenience, you can use `koi collect` to build a stand-alone script from the current workspace. `koi collect` concatenates all of your workspace functions into an executable script that calls whatever entry point you specify.

For example, to build a stand-alone script file `./mytools/search` that calls the function `search_db` (which possibly accepts arguments):
```
> koi collect ./mytools/search search_db
```

Now the script `search` can be moved anywhere, provided it doesn't rely on functions outside the current workspace.

#### The `global` Workspace
Any function added to workspace `global` will be available all the time. Currently global functions are not included during a `koi collect`.

That's it, have fun!
