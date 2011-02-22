Spec::Matchers.define :smart_match do |expected|
  def regexp?
    /^\/.*\/?$/
  end

  def quoted?
    /^".*"$/
  end

  match do |actual|
    case expected
    when regexp?
      actual =~ eval(expected)
    when quoted?
      actual.index(eval(expected))
    else # multi-line string
      actual.index(expected)
    end
  end

  failure_message_for_should do |actual|
    <<-MESSAGE
#{'*'*50}
got:
#{'*'*30}
#{actual}
#{'*'*50}
MESSAGE
  end
end

