class RubyStyle
  @@content = "If we go to <a href=/nodestyle>/nodestyle</a> then we'll get a node style calling convention"
  def call(env)
    [ 200, {
        'Content-Type' => 'text/html',
        'Content-Length' => @@content.length.to_s
      }, 
      @@content
    ]
  end
end
