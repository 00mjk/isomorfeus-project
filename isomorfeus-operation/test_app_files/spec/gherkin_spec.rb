require 'spec_helper'
require 'benchmark'

EXAMPLE_ONE = <<~TEXT
Operation: Can drink beer when thirsty

  Procedure: Can take a single beer
    Given 100 bottles of beer on the wall
    When a bottle is taken down
    Then there are 99 bottles of beer on the wall
TEXT

RESULT_ONE = { operation: 'Can drink beer when thirsty',
               procedure: 'Can take a single beer',
               ensure: [],
               failure: [],
               steps: [ '100 bottles of beer on the wall',
                        'a bottle is taken down',
                        'there are 99 bottles of beer on the wall' ]}

EXAMPLE_TWO = <<~TEXT
Operation: Can drink beer when thirsty
  As a drinker
  I want to take beer off the wall
  In order to satisfy my thirst

  Procedure: Ghosts can drink
    Given 100 bottles of beer on the wall
    And there is nobody in the room

    When 5 bottles are taken down
    # And they are floating in the air
    Then there are 95 bottles of beer on the wall
    Finally there are ghosts in the room
    If it failed there are no ghosts in the room
    Ensure there is nobody else in the room

TEXT

RESULT_TWO = { operation: "Can drink beer when thirsty",
               description: [ "As a drinker",
                              "I want to take beer off the wall",
                              "In order to satisfy my thirst"],
               procedure: "Ghosts can drink",
               ensure: [ "there is nobody else in the room" ],
               failure: [ "there are no ghosts in the room" ],
               steps: [ "100 bottles of beer on the wall",
                        "there is nobody in the room",
                        "5 bottles are taken down",
                        # "they are floating in the air",
                        "there are 95 bottles of beer on the wall",
                        "there are ghosts in the room"]}
RSpec.describe 'Isomorfeus::Gherkin' do
  it 'can parse example one' do
    result = LucidOperation::Gherkin.parse(EXAMPLE_ONE)
    expect(result).to eq(RESULT_ONE)
  end

  it 'can parse example two' do
    result = LucidOperation::Gherkin.parse(EXAMPLE_TWO)
    expect(result).to eq(RESULT_TWO)
  end

  context 'benchmark' do
    it 'local benchmark 1000 executions' do
      result = nil
      mark = Benchmark.measure do
        1000.times do
          result = LucidOperation::Gherkin.parse(EXAMPLE_TWO)
        end
      end
      STDERR.puts mark
      expect(result).to eq(RESULT_TWO)
    end

    it 'client benchmark 1000 executions' do
      doc = visit('/')
      time, result = doc.evaluate_ruby do
        EXAMPLE_TWO = <<~TEXT
Operation: Can drink beer when thirsty
  As a drinker
  I want to take beer off the wall
  In order to satisfy my thirst

  Procedure: Ghosts can drink
    Given 100 bottles of beer on the wall
    And there is nobody in the room

    When 5 bottles are taken down
    # And they are floating in the air
    Then there are 95 bottles of beer on the wall
    Finally there are ghosts in the room
    If it failed there are no ghosts in the room
    Ensure there is nobody else in the room

        TEXT
        result = nil
        start = Time.now
        1000.times do
          result = LucidOperation::Gherkin.parse(EXAMPLE_TWO)
        end
        final = Time.now - start
        [final, result.to_n]
      end
      STDERR.puts time
      expect(result).to eq(RESULT_TWO.transform_keys(&:to_s))
    end
  end
end
