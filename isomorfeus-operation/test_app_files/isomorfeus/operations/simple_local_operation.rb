class SimpleLocalOperation < LucidLocalOperation::Base
  procedure <<~TEXT
     Given a bird
  TEXT

  Given /a bird/ do
    'a bird'
  end
end