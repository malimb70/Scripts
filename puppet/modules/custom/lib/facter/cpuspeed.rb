Facter.add("maxcpuspeed") do
    setcode do
        freqs = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
        if File.exist?(freqs) then
             maxfreq = IO.read(freqs).split(/ /)[0]
             if maxfreq.to_i > 1600000 then
                 maxfreq
             else
                 "0"
             end
        else
             "0"
        end
    end
end

