class SimpleOperation < LucidOperation::Base
  prop :fail_op, required: false

  procedure <<~TEXT
     Given a bird
  TEXT

  Given /a bird/ do
    raise 'failure' if props.fail_op
    'a bird'
  end
end
