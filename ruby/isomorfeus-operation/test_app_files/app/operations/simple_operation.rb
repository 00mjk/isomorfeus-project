class SimpleOperation < LucidOperation::Base
  procedure <<~TEXT
     Given a bird
  TEXT

  Given /a bird/ do
    'a bird'
  end
end