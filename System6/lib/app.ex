# Rishabh Jain(rj2315)
defmodule App do
    def start(my_num, max_messages, timeout) do
        IO.puts ["      App at ", DNS.my_ip_addr()]
        receive do
            {:broadcast, rb, peer_pl_list} ->
                peer_data = for {peer, _} <- peer_pl_list, do: {peer, {0,0}}
                broadcast(peer_data, max_messages, cur_time() + timeout, my_num, rb)
        end
    end

    defp broadcast(peer_data, broadcasts_left, end_time, my_num, rb) do
        cond do
            cur_time() >= end_time ->
                stop_broadcasting(my_num, peer_data)
            broadcasts_left > 0 ->
                receive do
                    {:rb_deliver, peer_from} ->
                        peer_data = receive_broadcast(peer_from, peer_data)
                        broadcast(peer_data, broadcasts_left, end_time, my_num, rb)
                after
                    # Incase nothing to be received
                    0 ->
                        send rb, {:rb_broadcast}
                        peer_data = send_broadcast(peer_data)
                        broadcast(peer_data, broadcasts_left - 1, end_time, my_num, rb)
                end
            true ->
                receive do
                    {:rb_deliver, peer_from} ->
                        peer_data = receive_broadcast(peer_from, peer_data)
                        broadcast(peer_data, broadcasts_left, end_time, my_num, rb)
                after
                    # Recursive call to recheck timeout
                    0 -> broadcast(peer_data, broadcasts_left, end_time, my_num, rb)
                end
        end
    end

    defp stop_broadcasting(num, peer_data) do
        # Display results
        str = for {_, stats} <- peer_data do
            " #{inspect(stats)}"
        end
        str = ["#{num}:"] ++ str
        IO.puts str
    end

    defp send_broadcast(peer_data) do
        for {peer, {num_sent, num_received}} <- peer_data do
            {peer, {num_sent + 1, num_received}}
        end
    end

    defp receive_broadcast(peer_from, peer_data) do
        {_, {num_sent, num_received}} = List.keyfind(peer_data, peer_from, 0, nil)
        List.keyreplace(
            peer_data, peer_from, 0, {peer_from, {num_sent, num_received + 1}})
    end

    # Returns current time in milliseconds
    defp cur_time() do
        :os.system_time(:millisecond)
    end
end # module -----------------------
