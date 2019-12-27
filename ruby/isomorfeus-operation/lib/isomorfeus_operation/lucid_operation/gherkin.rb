module LucidOperation
  module Gherkin
    FIRST_EXCEPTION = "First must be the first one that is used and can only used once!"
    FINALLY_EXCEPTION = "Finally, except for Ensure and Failed, must be the last one to be used and can only be used once!"

    NEWLINE = /\r?\n/
    OPERATION = /^\s*Operation: (.*)$/
    PROCEDURE = /^\s*Procedure: (.*)$/
    STAR = /^\s*\* (.*)$/
    GIVEN = /^\s*Given (.*)$/
    WHEN = /^\s*When (.*)$/
    THEN = /^\s*Then (.*)$/
    AND = /^\s*And (.*)$/
    FIRST = /^\s*First (.*)$/
    ENSURE = /^\s*Ensure (.*)$/
    FINALLY = /^\s*Finally (.*)$/
    IW_FAILING = /^\s*(?:When|If) failing (.*)$/
    IF_ITT_FAILED = /^\s*If (?:that|this|it) failed (.*)$/
    FAILED = /^\s*Failed (.*)$/
    COMMENT = /^\s*# (.*)$/
    WHITE_SPACE = /^\s*$/

    def self.parse(gherkin_text)
      operation = { operation: '', procedure: '', steps: [], failure: [], ensure: [] }
      has_finally = false
      lines = gherkin_text.split(NEWLINE)

      lines.each do |line|
        case line
        when STAR, GIVEN, WHEN, THEN, AND
          raise FINALLY_EXCEPTION if has_finally
          operation[:steps] << $1.strip
        when ENSURE
          operation[:ensure] << $1.strip
        when IW_FAILING, IF_ITT_FAILED, FAILED
          operation[:failure] << $1.strip
        when FIRST
          raise FIRST_EXCEPTION if operation[:steps].size > 0
          operation[:steps] << $1.strip
        when FINALLY
          raise FINALLY_EXCEPTION if has_finally
          operation[:steps] << $1.strip
          has_finally = true
        when PROCEDURE
          raise 'No Operation defined!' if operation[:operation].empty?
          raise 'Procedure already defined!' unless operation[:procedure].empty?
          operation[:procedure] = $1.strip
        when OPERATION
          raise 'Operation already defined!' unless operation[:operation].empty?
          operation[:operation] = $1.strip
        when WHITE_SPACE, COMMENT
          # nothing, just skip
        else
          raise "Unknown key word(s) at the beginning of the line: #{line}" unless operation[:procedure].empty?
          operation[:description] = [] unless operation.key?(:description)
          operation[:description] << line.strip
        end
      end

      operation
    end
  end
end
