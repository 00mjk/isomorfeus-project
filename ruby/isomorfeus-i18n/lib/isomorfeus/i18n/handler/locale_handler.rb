# frozen_string_literal: true

module Isomorfeus
  module I18n
    module Handler
      class LocaleHandler < LucidHandler::Base
        include FastGettext::Translation
        include FastGettext::TranslationMultidomain

        on_request do |response_agent|
          Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
          response_agent.agent_result = {}
          # promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, method, [args])
          response_agent.request.each_key do |domain|
            if domain == 'init'
              locale = response_agent.request[domain]
              response_agent.agent_result['data'] = { 'available_locales' => FastGettext.available_locales,
                                                      'domain' => FastGettext.text_domain }
              response_agent.agent_result['data']['locale'] = if Isomorfeus.available_locales.include?(locale)
                                                                locale
                                                             else
                                                               FastGettext.locale
                                                             end
            else
              response_agent.agent_result[domain] = {}
              begin
                FastGettext.with_domain(domain) do
                  response_agent.request[domain].each_key do |locale|
                    response_agent.agent_result[domain][locale] = {}
                    Isomorfeus.raise_error(message: "Locale #{locale} not available!") unless Isomorfeus.available_locales.include?(locale)
                    FastGettext.with_locale(locale) do
                      response_agent.request[domain][locale].each_key do |locale_method|
                        method_args = response_agent.request[domain][locale][locale_method]
                        method_result = case locale_method
                                        when '_' then _(*method_args)
                                        when 'n_' then n_(*method_args)
                                        when 'np_' then np_(*method_args)
                                        when 'ns_' then ns_(*method_args)
                                        when 'p_' then p_(*method_args)
                                        when 's_' then s_(*method_args)
                                        when 'N_' then N_(*method_args)
                                        when 'Nn_' then Nn_(*method_args)
                                        when 'd_' then d_(*method_args)
                                        when 'dn_' then dn_(*method_args)
                                        when 'dnp_' then dnp_(*method_args)
                                        when 'dns_' then dns_(*method_args)
                                        when 'dp_' then dp_(*method_args)
                                        when 'ds_' then ds_(*method_args)
                                        when 'D_' then D_(*method_args)
                                        when 'Dn_' then Dn_(*method_args)
                                        when 'Dnp_' then Dnp_(*method_args)
                                        when 'Dns_' then Dns_(*method_args)
                                        when 'Dp_' then Dp_(*method_args)
                                        when 'Ds_' then Ds_(*method_args)
                                        else
                                          Isomorfeus.raise_error(message: "No such locale method #{locale_method}")
                                        end
                        response_agent.agent_result[domain][locale].deep_merge!(locale_method => { Oj.dump(method_args, mode: :strict) => method_result })
                      end
                    end
                  end
                end
              rescue Exception => e
                response_agent.error = if Isomorfeus.production?
                                         { error: 'No such thing!' }
                                       else
                                         { error: "Isomorfeus::I18n::Handler::LocaleHandler: #{e.message}" }
                                       end
              end
            end
          end
        end
      end
    end
  end
end
