## Get started developing web applications

### Requirements
Isomorfeus works on any of the following operating systems:
- Linux
- macOS

Further are required:
- ruby >= 2.6.5 with bundler
- node >= 12 with yarn

### Installation
```shell script
$ gem install isomorfeus -v 1.0.0.zeta19
```

### Creating a project
Please choose a name in small letters with underscores for your project: 
```shell script
$ isomorfeus new my_project
```
The installer will set up the project structure and create several example files to start with, install gems and npm packages.

### Starting the development environment
Cd into the projects folder:
```shell script
$ cd my_project
$ foreman start -f ProcfileDev
```
and start the application with foreman as shown above.
It will compile assets and once its ready, continue below with section "Editing your first component"

### Starting the development environment using Docker
Make sure have Docker and Docker Compose installed.

Cd into the projects folder:
```shell script
$ cd my_project
$ docker-compose up
```
and start the build of the containers (takes a while) and after that the containers themselves.
Once the container are started continue below.

If your are on macOS, be aware that the container generated node_modules directory in the project root works for the containers only.
If you want to work without using containers on macOS again, you must delete the node_modules directory and execute `yarn install` again.  

### Editing your first component
Then open browser at [http://localhost:5000](http://localhost:5000).
By default you will see a simple WelcomeComponent.
The component is located in the file `my_project/app/components/welcome_component.rb`.
Open the File your favorite ruby editor or IDE and change the text. After saving, the changed text should appear instantly in the Browser.

Understand the generic project structure [here](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/docs/project_structure.md)
and to learn more about components may have a look at the
[isomorfeus-react documentation](https://github.com/isomorfeus/isomorfeus-react/blob/master/ruby/README.md).
