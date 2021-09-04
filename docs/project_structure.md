## Project Structure

### Project root directory
- app - the directory for all application files, components, data classes, etc.
- app_loader.rb - used by the app and asset builder internally to set up load paths and load gems
- config - directory for all application related configuration
- config.ru - start up file for Rack
- Gemfile - for bundler to install and load gems
- Procfile - for starting the app in production mode
- ProcfileDebug - for starting the app in debug mode
- ProcfileDev - for starting the app in development mode
- public - directory for public files and assets
- spec - directory for rspec files
- webpack - directory for webpack configuration 

optional:
- node_modules - directory for additional node modules used by the app
- package.json - for npm to install and load additional npm packages


my_project_app.rb - The server side main application entry file, a roda app. Named after the projects name given when installing.

There are additional files, generated and required by various ruby or npm modules used by the system.

### Project app directory
my_project/app:
- channels - for Channel classes, pubsub
- components - for Components
- data - for Data classes
- locales - for i18n locale files
- mail_components - for Components that are used as mail templates
- operations - for Business Operations 
- policies - for Policies
- server - Classes and modules only available on the server
- styles - for CSS styles

- isomorfeus_loader.rb - client side ruby entry point, loading starting the application 
- mail_components_loader.rb - loader for mail Components

optional:
- imports - javascript entry files, importing additional javascripts modules and styles

### Project app/components
my_project/app/components contains all application components and by default has:
- hello_component.rb - a very simple component
- navigation_links.rb - a component showing the use Preact Wouter Link
- not_found_404_component.rb - a component thats rendered when no route matches
- test_project_app.rb - the main application component which contains all routes
- welcome_component.rb - another simple component

### Project app/imports (optional)
my_project/app/imports may contain optional, additional javascript imports:
web.js - imports used on the browser
ssr.js - imports used in server side rendering
stylesheets.css - optional style sheets
mail.js - imports used for Mail Components

### Project app/policy
my_project/app/policies:
anonymous_policy.rb - the default policy for Anonymous users

### Project config directory
my_project/config contains configuration files for the server and its services:
- iodine_config.rb - parameters for iodine rack server 
