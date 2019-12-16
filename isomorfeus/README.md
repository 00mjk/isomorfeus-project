# Isomorfeus Framework Installer

Create new isomorfeus applications with ease.

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

#### Supported Isomorfeus modules
- isomorfeus-react
- isomorfeus-redux

#### Supported asset bundlers
- webpack with opal-webpack-loader

## Installation
```bash
gem install isomorfeus
```

## Creating new applications
To create a new application execute:
```bash
isomorfeus new my_application
```

### Options
```bash
isomorfeus help
```

```
Commands:
  isomorfeus help [COMMAND]    # Describe available commands or one specific command
  isomorfeus new project_name  # create a new isomorfeus project with project_name
```

```
Available options for the command 'new':
  -y, [--yarn-and-bundle], [--no-yarn-and-bundle]  # Execute yarn install and bundle install. (optional)
                                                   # Default: true
```

### Yandle
There is a convenience command to execute yarn and bundle: `yandle`:
- `yandle` - will execute `yarn install` followed by `bundle install`
- `yandle update` or `yandle upgrade` - will execute `yarn upgrade` followed by `bundle update`
