class ActiveSupport::BufferedLogger
  def p(*args)
    info "\033[1;37;40m\n\n" << args.join(" ") << "\033[0m\n\n\n"
  end
end
