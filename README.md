# Koi
Koi turns your one-liners into functions. 

It's a fish shell script.

## Install
```
cp koi.fish ~/.config/fish/functions/
```

## Use
Basic:

First, execute your one-liner, like:
```
> echo Hello World!
```

Convert it into a function with your next command:
``` 
> :a hello_world "say hello to the world"
```

Then use your new function:
```
> hello_world
Hello World!
```

`:a` is the command you will be using the most. It's weirdly named so as not to conflict with other possible names, and has an "a" meaning "add function."

The magic is that koi takes your last executed line from `history` and crams it inside a file wrapped up in a function. So **you cannot have "two liners", your command must exist on ONE (possibly huge) line**. 

> For more help, type `koi help`, or if you're an avid reader: `koi man`.

## Workspaces
Koi has "workspaces" to organize your functions (`koi ws`, `koi lsws`, etc.) . This also allows you to  build a stand-alone script from all your accumulated functions ( `koi collect` ).

Koi uses a special workspace, `global`, where you can put any function you'd like to have available from everywhere.

### argv
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

That's it, have fun!
