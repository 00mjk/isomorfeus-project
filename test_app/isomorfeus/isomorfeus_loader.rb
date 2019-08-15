require 'opal'
app_start = Time.now
require 'opal-autoloader'
require 'isomorfeus-redux'
require 'isomorfeus-react'
require 'isomorfeus-react-material-ui'
require 'isomorfeus-transport'
require 'isomorfeus-i18n'
start = Time.now
require 'isomorfeus-policy'

ID_REQUIRE_TIME = (Time.now - start) * 1000
%x{
  class NativeComponent extends Opal.global.React.Component {
    constructor(props) {
      super(props);
    }
    render() {
      return Opal.global.React.createElement('div', null, 'A');
    }
  }
  Opal.global.NativeComponent = NativeComponent;

  class TopNativeComponent extends Opal.global.React.Component {
    constructor(props) {
      super(props);
    }
    render() {
      return Opal.global.React.createElement('div', null, 'TopNativeComponent');
    }
  }
  Opal.global.TopNativeComponent = TopNativeComponent;

  Opal.global.NestedNative = {};
  class AnotherComponent extends Opal.global.React.Component {
    constructor(props) {
      super(props);
    }
    render() {
      return Opal.global.React.createElement('div', null, 'NestedNative.AnotherComponent');
    }
  }
  Opal.global.NestedNative.AnotherComponent = AnotherComponent;
}

require_tree 'components'
require_tree 'policies'

Isomorfeus.start_app!
APP_LOAD_TIME = (Time.now - app_start) * 1000