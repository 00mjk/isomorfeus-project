## Get started developing web applications with Isomorfeus
### Requirements
Isomorfeus works on any of the following operating systems:
- Linux
- macOS
- Windows

Further are required:
- ruby >= 3.0.0 with bundler
- node with at least current LTS version
### Installation
Linux:
make sure ruby >= 3 is installed. Then in a shell:
```shell script
$ gem install isomorfeus
```

macOS:
make sure ruby >= 3 is installed. Then in a shell:
```shell script
$ gem install isomorfeus
```

Windows:
make sure ruby is installed. You may get ruby from [https://rubyinstaller.org/](https://rubyinstaller.org/). Then in a cmd window:
```cmd script
C:\Users\Jan> gem install isomorfeus
```
### Create a project
Please choose a name in small letters with underscores for your project:
```shell script
$ isomorfeus new my_project
```
The installer will set up the project structure and create several example files to start with, install gems and npm packages.

### Starting the development environment
Cd into the projects folder:
```shell script
$ cd my_project
$ bundle exec iodine
```
and start the application as shown above.

### Editing your first component
Then open a browser at [http://localhost:3000](http://localhost:3000).
By default you will see a simple WelcomeComponent.
The component is located in the file `my_project/app/components/welcome_component.rb`.
Open the file in your favorite ruby editor or IDE and change the text. After saving, the changed text should appear instantly in the Browser.

Understand the generic project structure [here](project_structure.md) and to learn more about components have a look at the Isomorfeus Preact documentation.
