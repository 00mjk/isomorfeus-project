# frozen_string_literal: true

module Isomorfeus
  module I18n
    module Handler
      class LocaleHandler < LucidHandler::Base
        include FastGettext::Translation
        include FastGettext::TranslationMultidomain

        on_request do |pub_sub_client, current_user, request, response|
          Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
          result = {}
          # promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, method, [args])
          request.each_key do |domain|
            if domain == 'init'
              locale = request[domain]
              result['data'] = { 'available_locales' => FastGettext.available_locales,
                                 'domain' => FastGettext.text_domain }
              result['data']['locale'] = if Isomorfeus.available_locales.include?(locale)
                                           locale
                                         else
                                           FastGettext.locale
                                         end
            else
              result[domain] = {}
              begin
                FastGettext.with_domain(domain) do
                  request[domain].each_key do |locale|
                    result[domain][locale] = {}
                    raise "Locale #{locale} not available!" unless Isomorfeus.available_locales.include?(locale)
                    FastGettext.with_locale(locale) do
                      request[domain][locale].each_key do |locale_method|
                        method_args = request[domain][locale][locale_method]
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
                                          raise "No such locale method #{locale_method}"
                                        end
                        result[domain][locale].deep_merge!(locale_method => { Oj.dump(method_args, mode: :strict) => method_result })
                      end
                    end
                  end
                end
              rescue Exception => e
                result = if Isomorfeus.production?
                           { error: 'No such thing!' }
                         else
                           { error: "Isomorfeus::I18n::Handler::LocaleHandler: #{e.message}" }
                         end
              end
            end
          end
          result
        end
      end
    end
  end
end
