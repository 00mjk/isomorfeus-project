/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './app/imports/native';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
