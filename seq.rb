def seq(*args, &proc)
  sequence(*args) {|*e|
    proc.call(*e) if proc
    e.join
  }
end

