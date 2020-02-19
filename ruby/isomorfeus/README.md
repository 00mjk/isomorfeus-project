# Isomorfeus Framework Installer

Create new isomorfeus applications with ease.

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

## Installation
```shell script
gem install isomorfeus
```

## Creating new applications
To create a new application execute:
```shell script
isomorfeus new my_application
```

### Commands
```shell script
$ isomorfeus help
Commands:
    isomorfeus console                       # Open console for current project.
    isomorfeus help [COMMAND]                # Describe available commands or one specific command
    isomorfeus new project_name              # Create a new isomorfeus project with project_name.
```

### Yandle
There is a convenience command to execute yarn and bundle: `yandle`:
- `yandle` - will execute `yarn install` followed by `bundle install`
- `yandle update` or `yandle upgrade` - will execute `yarn upgrade` followed by `bundle update`
