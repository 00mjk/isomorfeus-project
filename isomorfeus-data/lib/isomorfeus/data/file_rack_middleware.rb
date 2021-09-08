# frozen_string_literal: true

module Isomorfeus
  module Data
    class FileRackMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        if env['REQUEST_METHOD'] == 'GET' && env['PATH_INFO'].start_with?(Isomorfeus.file_request_path)
          user = nil
          cookies = env['HTTP_COOKIE']
          if cookies
            cookies = cookies.split('; ')
            cookie = cookies.detect { |c| c.start_with?('session=') }
            if cookie
              session_id = cookie[8..-1]
              user = Isomorfeus.session_store.get_user(session_id: session_id)
            end
          end
          user = Anonymous.new unless user

          path = env['PATH_INFO'][Isomorfeus.file_request_path.length..-1]
          path = path[1..-1] if path.start_with?('/')
          type_class_name, derivative, key = path.split('/')
          unless key
            key = derivative
            derivative = :default
          end
          
          if Isomorfeus.valid_file_class_name?(type_class_name)
            type_class = Isomorfeus.cached_file_class(type_class_name)
            if type_class
              # 'Isomorfeus::Data::Handler::File', self.name, :load, key: key
              props = { derivative: derivative, key: key }
              if user.authorized?(type_class, :load, { derivative: derivative, key: key })
                loaded_type = type_class.load(**props)
                if loaded_type
                  # TODO get last modified
                  # last_modified = ::File.mtime(path).httpdate
                  # return [304, {}, []] if request.get_header('HTTP_IF_MODIFIED_SINCE') == last_modified
                  #
                  headers = { }
                  return [200, headers, body]
                else
                  # TODO
                  return [404, {}, '']
                end
              else
                # TODO
                return [401, {}, '']
              end
            end
          end
          return [404, {}, '']
        else
          @app.call(env)
        end
      rescue Exception => e
        # TODO
        Isomorfeus.raise_error(error: e)
        return [500, {}, '']
      end
    end
  end
end
