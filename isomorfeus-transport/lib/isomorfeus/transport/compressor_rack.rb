# frozen_string_literal: true

module Isomorfeus
  module Transport
    class CompressorRack
      C_ENCODINGS = %w[br gzip identity].freeze

      def initialize(app, options = {})
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        headers = Rack::Utils::HeaderHash[headers]


        unless should_deflate?(env, status, headers, body)
          return [status, headers, body]
        end

        request = Rack::Request.new(env)

        encoding = Rack::Utils.select_best_encoding(C_ENCODINGS,
                                              request.accept_encoding)

        vary = headers["Vary"].to_s.split(",").map(&:strip)
        unless vary.include?("*") || vary.include?("Accept-Encoding")
          headers["Vary"] = vary.push("Accept-Encoding").join(",")
        end

        case encoding
        when "br"
          headers['Content-Encoding'] = "br"
          headers.delete(Rack::CONTENT_LENGTH)
          [status, headers, BrotliStream.new(body, @sync)]
        when "gzip"
          headers['Content-Encoding'] = "gzip"
          headers.delete(Rack::CONTENT_LENGTH)
          mtime = headers["Last-Modified"]
          mtime = Time.httpdate(mtime).to_i if mtime
          [status, headers, GzipStream.new(body, mtime, @sync)]
        when "identity"
          [status, headers, body]
        when nil
          message = "An acceptable encoding for the requested resource #{request.fullpath} could not be found."
          bp = Rack::BodyProxy.new([message]) { body.close if body.respond_to?(:close) }
          [406, { CONTENT_TYPE => "text/plain", CONTENT_LENGTH => message.length.to_s }, bp]
        end
      end

      class BrotliStream
        BUFFER_LENGTH = 128 * 1_024

        def initialize(body, sync)
          @body = body
          @sync
        end

        def each(&block)
          @writer = block
          brotli = ::Brotli::Writer.new(self, quality: 5)

          if @body.is_a? ::File
            while part = @body.read(BUFFER_LENGTH)
              brotli.write(part)
              brotli.flush if @sync
            end
          else
            @body.each do |part|
              next if part.empty?
              brotli.write(part)
              brotli.flush if @sync
            end
          end
        ensure
          brotli.close
        end

        def write(data)
          @writer.call(data)
        end

        def close
          @body.close if @body.respond_to?(:close)
        end
      end

      class GzipStream
        BUFFER_LENGTH = 128 * 1_024

        def initialize(body, mtime, sync)
          @body = body
          @mtime = mtime
          @sync = sync
        end

        def each(&block)
          @writer = block
          gzip = ::Zlib::GzipWriter.new(self)
          gzip.mtime = @mtime if @mtime

          if @body.is_a? ::File
            while part = @body.read(BUFFER_LENGTH)
              gzip.write(part)
              gzip.flush if @sync
            end
          else
            @body.each do |part|
              next if part.empty?
              gzip.write(part)
              gzip.flush if @sync
            end
          end
        ensure
          gzip.close
        end

        def write(data)
          @writer.call(data)
        end

        def close
          @body.close if @body.respond_to?(:close)
        end
      end

      private

      def should_deflate?(env, status, headers, body)
        if Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.key?(status.to_i) ||
            /\bno-transform\b/.match?(headers['Cache-Control'].to_s) ||
            headers['Content-Encoding']&.!~(/\bidentity\b/)
          return false
        end
        return false if headers[Rack::CONTENT_LENGTH] == '0'
        true
      end
    end
  end
end
