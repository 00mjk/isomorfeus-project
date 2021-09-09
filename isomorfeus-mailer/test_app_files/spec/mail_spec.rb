require 'spec_helper'

RSpec.describe 'LucidMail' do
  context 'on server' do
    it 'can create a mail' do
      result = on_server do
        mail = LucidMail.new(component: 'EmailComponent', props: { name: 'Werner' }, from: 'me@test.com', to: 'you@test.com', subject: 'Welcome')
        mail.build
        mail.rendered_component
      end
      expect(result).to include 'Welcome Werner!'
    end

    it 'asset imports are ok' do
      result = Isomorfeus.assets['mail.js'].to_s
      expect(result).to eq <<~JAVASCRIPT
      import * as Redux from "redux";
      global.Redux = Redux;
      
      import * as Preact from "preact";
      global.Preact = Preact;
      
      import * as PreactHooks from "preact/hooks";
      global.PreactHooks = PreactHooks;
      
      import { Router, Link, Redirect, Route, Switch } from "wouter-preact";
      global.Router = Router;
      global.Link = Link;
      global.Redirect = Redirect;
      global.Route = Route;
      global.Switch = Switch;
      
      import * as NanoCSS from "nano-css";
      global.NanoCSS = NanoCSS;
      
      import { addon as NanoCSSAddons_rule } from "nano-css/addon/rule";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.rule = NanoCSSAddons_rule;
      
      import { addon as NanoCSSAddons_sheet } from "nano-css/addon/sheet";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.sheet = NanoCSSAddons_sheet;
      
      import { addon as NanoCSSAddons_nesting } from "nano-css/addon/nesting";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.nesting = NanoCSSAddons_nesting;
      
      import { addon as NanoCSSAddons_hydrate } from "nano-css/addon/hydrate";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.hydrate = NanoCSSAddons_hydrate;
      
      import { addon as NanoCSSAddons_unitless } from "nano-css/addon/unitless";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.unitless = NanoCSSAddons_unitless;
      
      import { addon as NanoCSSAddons_global } from "nano-css/addon/global";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.global = NanoCSSAddons_global;
      
      import { addon as NanoCSSAddons_keyframes } from "nano-css/addon/keyframes";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.keyframes = NanoCSSAddons_keyframes;
      
      import { addon as NanoCSSAddons_fadeIn } from "nano-css/addon/animate/fadeIn";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.fadeIn = NanoCSSAddons_fadeIn;
      
      import { addon as NanoCSSAddons_fadeOut } from "nano-css/addon/animate/fadeOut";
      if (!global.NanoCSSAddons) { global.NanoCSSAddons = {}; }
      global.NanoCSSAddons.fadeOut = NanoCSSAddons_fadeOut;
      
      import { render } from "preact-render-to-string";
      global.Preact.renderToString = render;
      
      import staticLocationHook from "wouter-preact/static-location";
      global.staticLocationHook = staticLocationHook;
      
      import WebSocket from "ws";
      global.WebSocket = WebSocket;
      
      import("./mail_loader.js");
      JAVASCRIPT
    end
  end
end
