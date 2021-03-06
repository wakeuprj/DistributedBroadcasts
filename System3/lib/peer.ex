# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule Peer do

def start(num, system, max_messages, timeout) do
    IO.puts ["      Peer at ", DNS.my_ip_addr()]
    app = spawn(App, :start, [num, max_messages, timeout])
    beb = spawn(BEB, :start, [app])
    pl = spawn(PL, :start, [self(), beb])
    send system, {:pl, self(), pl}
end
end # module -----------------------
