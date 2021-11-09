## Project Structure

### Project root directory
- app - the directory for all application files, components, data classes, etc.
- app_loader.rb - used by the app internally to set up load paths and load gems
- config.ru - start up file for Rack
- data - directory for documents, objects, indices and other data
- Gemfile - for bundler to install and load gems
- public - directory for public files and assets
- spec - directory for rspec files

optional:
- config - directory for *.rb files to be loaded before application start, usually used to configure various things
- node_modules - directory for additional node modules used by the app
- package.json - for npm to install and load additional npm packages

### Project app directory
my_project/app:
- channels - for Channel classes, pubsub
- components - for Components
- data - for Data classes
- layouts - mustache templates used as layouts
- locales - for i18n locale files
- mail_components - for Components that are used as mail templates
- operations - for Business Operations
- policies - for Policies
- server - Classes and modules only available on the server
- isomorfeus_loader.rb - client side ruby entry point, loading starting the application
- mail_loader.rb - loader for mail Components

optional:
- imports - javascript entry files, importing additional javascripts modules and styles

### Project app/components
my_project/app/components contains all application components and by default has:
- hello_component.rb - a very simple component
- navigation_links.rb - a component showing the use Preact Wouter Link
- not_found_404_component.rb - a component thats rendered when no route matches
- my_project_app.rb - the main application component which contains all routes, named after the projects name given when creating the project
- welcome_component.rb - another simple component

### Project app/imports (optional)
my_project/app/imports may contain optional, additional javascript imports:
common.js - imports used on the browser and in server side rendering
web.js - imports used on the browser
ssr.js - imports used in server side rendering

### Project app/policy
my_project/app/policies:
anonymous_policy.rb - the default policy for Anonymous users
