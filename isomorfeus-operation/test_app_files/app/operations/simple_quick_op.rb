class SimpleQuickOp < LucidQuickOp::Base
  prop :fail_op, required: false

  op do
    raise 'failure' if props.fail_op
    'a bird'
  end
end
