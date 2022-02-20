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
      result = Isomorfeus.assets['mail.js'].generate_entry('mail')
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

      import { render } from "preact-render-to-string";
      global.Preact.renderToString = render;

      import staticLocationHook from "wouter-preact/static-location";
      global.staticLocationHook = staticLocationHook;

      import WebSocket from "ws";
      global.WebSocket = WebSocket;
      import("./mail/mail_loader.rb.js");
      JAVASCRIPT
    end
  end
end
