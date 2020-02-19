## Project Structure

### Project root directory
- app - the directory for all application files, components, data classes, etc.
- app_loader.rb - used by the app and asset builder internally to set up load paths and load gems
- config - directory for all application related configuration
- config.ru - start up file for Rack
- Gemfile - for bundler to install and load gems
- node_modules - directory for all node modules used by the app
- package.json - for yarn to install and load npm packages
- Procfile - for starting the app in production mode
- ProcfileDebug - for starting the app in debug mode
- ProcfileDev - for starting the app in development mode
- public - directory for public files and assets
- spec - directory for rspec files
- webpack - directory for webpack configuration 

my_project_app.rb - The server side main application entry file, a roda app. Named after the projects name given when installing.

There are additional files, generated and required by various ruby or npm modules used by the system.

### Project app directory
my_project/app:
- channels - for Channel classes, pubsub
- components - for Components
- data - for Data classes
- imports - javascript entry files, importing all javascripts modules and styles and executing the isomorfeus loaders
- locales - for i18n locale files
- mail_components - for Components that are used as mail templates
- operations - for Business Operations 
- policies - for Policies
- server - Classes and modules only available on the server
- styles - for CSS styles

- isomorfeus_loader.rb - client side ruby entry point, loading starting the application 
- mail_components_loader.rb - loader for mail Components

### Project app/components
my_project/app/components contains all application components and by default has:
- hello_component.rb - a very simple component
- navigation_links.rb - a component showing the use React Router Link
- not_found_404_component.rb - a component thats rendered when no route matches
- test_project_app.rb - the main application component which contains all routes
- welcome_component.rb - another simple component

### Project app/imports
my_project/app/imports contains all javascript imports and loads the ruby loaders:
application_common.js - common application imports used on the browser and in server side rendering
application.js - imports only used on the browser
application_ssr.js - imports only used in server side rendering
mail_components.js - imports used for Mail Components

### Project app/policy
my_project/app/policies:
anonymous_policy.rb - the default policy for Anonymous users

### Project config directory
my_project/config contains configuration files for the server and its services:
- arango_config.rb - how to connect to arango db
- iodine_config.rb - parameters for iodine rack server 
- owl_init.rb - configuration for opal-webpack-loader asset helpers
